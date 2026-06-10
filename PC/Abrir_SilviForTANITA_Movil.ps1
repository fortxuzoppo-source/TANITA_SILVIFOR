$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$port = 8765
$localUrl = "http://127.0.0.1:$port/SilviForTANITA/"
$health = "http://127.0.0.1:$port/api/health"
$server = Join-Path $root "server.py"
$outLog = Join-Path $env:TEMP "silvifortanita_server.out.log"
$errLog = Join-Path $env:TEMP "silvifortanita_server.err.log"
$helpFile = Join-Path $env:TEMP "SilviForTANITA_movil.html"

function Get-NormalizedPath {
  param([string] $Path)
  return [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
}

function Test-SilviMobileServer {
  try {
    $payload = Invoke-RestMethod -Uri $health -TimeoutSec 1
    if (-not $payload.ok) {
      return $false
    }

    $serverRoot = Get-NormalizedPath ([string] $payload.root)
    $expectedRoot = Get-NormalizedPath $root
    if (-not [string]::Equals($serverRoot, $expectedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      return $false
    }

    $listenHost = [string] $payload.listenHost
    return ($listenHost -eq "0.0.0.0" -or $listenHost -eq "::")
  } catch {
    return $false
  }
}

function Stop-PortListeners {
  $listeners = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
  foreach ($listener in $listeners) {
    Stop-Process -Id $listener.OwningProcess -Force -ErrorAction SilentlyContinue
  }
}

function Resolve-Python {
  $python = (Get-Command python -ErrorAction SilentlyContinue).Source
  if (-not $python) {
    $python = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
  }
  return $python
}

function Add-LanAddress {
  param(
    [System.Collections.Generic.List[string]] $Addresses,
    [string] $Ip
  )
  if (-not $Ip) {
    return
  }
  if ($Ip -notmatch '^\d{1,3}(\.\d{1,3}){3}$') {
    return
  }
  if ($Ip -match '^(127\.|169\.254\.|0\.|255\.)') {
    return
  }
  if (-not $Addresses.Contains($Ip)) {
    $Addresses.Add($Ip) | Out-Null
  }
}

function Get-LanAddresses {
  $addresses = [System.Collections.Generic.List[string]]::new()

  try {
    $configs = Get-NetIPConfiguration -ErrorAction Stop | Where-Object { $_.IPv4DefaultGateway -and $_.IPv4Address }
    foreach ($config in $configs) {
      foreach ($addr in $config.IPv4Address) {
        Add-LanAddress $addresses ([string] $addr.IPAddress)
      }
    }
  } catch {
    # Fallback below.
  }

  if ($addresses.Count -eq 0) {
    try {
      $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
        Where-Object { $_.IPAddress -and $_.InterfaceOperationalStatus -eq "Up" } |
        Sort-Object InterfaceMetric, InterfaceIndex
      foreach ($ip in $ips) {
        Add-LanAddress $addresses ([string] $ip.IPAddress)
      }
    } catch {
      # No network cmdlets available.
    }
  }

  return $addresses.ToArray()
}

function Try-EnsureFirewallRule {
  $ruleName = "SilviForTANITA puerto 8765"
  try {
    $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($existing) {
      return "Firewall: regla ya existente."
    }
    New-NetFirewallRule `
      -DisplayName $ruleName `
      -Direction Inbound `
      -Action Allow `
      -Protocol TCP `
      -LocalPort $port `
      -Profile Private,Domain `
      -ErrorAction Stop | Out-Null
    return "Firewall: regla creada para redes privadas/de dominio."
  } catch {
    return "Firewall: si el movil no conecta, ejecuta Permitir_Firewall_SilviForTANITA.bat como administrador."
  }
}

function Html {
  param([string] $Text)
  return [System.Net.WebUtility]::HtmlEncode($Text)
}

if (-not (Test-SilviMobileServer)) {
  Stop-PortListeners

  $python = Resolve-Python
  if (-not $python) {
    throw "No encuentro Python en este equipo."
  }

  Remove-Item $outLog, $errLog -ErrorAction SilentlyContinue
  $serverArg = '"' + $server.Replace('"', '\"') + '"'
  $arguments = "$serverArg --host 0.0.0.0 --port $port"
  Start-Process `
    -FilePath $python `
    -ArgumentList $arguments `
    -WorkingDirectory $root `
    -WindowStyle Hidden `
    -RedirectStandardOutput $outLog `
    -RedirectStandardError $errLog

  $ready = $false
  for ($i = 0; $i -lt 30; $i += 1) {
    Start-Sleep -Milliseconds 250
    if (Test-SilviMobileServer) {
      $ready = $true
      break
    }
  }

  if (-not $ready) {
    $detail = ""
    if (Test-Path $errLog) {
      $detail = (Get-Content $errLog -Raw).Trim()
    }
    if (-not $detail) {
      $detail = "No se pudo arrancar el servidor local para movil."
    }
    throw $detail
  }
}

$firewallMessage = Try-EnsureFirewallRule
$lanAddresses = Get-LanAddresses
$mobileUrls = @($lanAddresses | ForEach-Object { "http://$($_):$port/SilviForTANITA/" })

$primaryUrl = "No encuentro una IP de red local en este PC."
if ($mobileUrls.Count -gt 0) {
  $primaryUrl = $mobileUrls[0]
  try {
    Set-Clipboard -Value $primaryUrl
  } catch {
    # Clipboard is optional.
  }
}

$urlItems = ""
foreach ($mobileUrl in $mobileUrls) {
  $safeUrl = Html $mobileUrl
  $urlItems += "<li><a href=`"$safeUrl`">$safeUrl</a></li>`n"
}
if (-not $urlItems) {
  $urlItems = "<li>No se detecto una IP valida. Conecta el PC a la misma WiFi que el iPhone.</li>"
}

$safePrimary = Html $primaryUrl
$safeLocal = Html $localUrl
$safeFirewall = Html $firewallMessage

$html = @"
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SilviForTANITA movil</title>
  <style>
    :root { color-scheme: light dark; font-family: Segoe UI, Arial, sans-serif; }
    body { margin: 0; background: #eef3f6; color: #102027; }
    main { max-width: 980px; margin: 0 auto; padding: 34px 20px; }
    .panel { background: #fff; border: 1px solid #d5e0e7; border-radius: 8px; padding: 26px; box-shadow: 0 10px 30px rgba(16, 32, 39, .08); }
    h1 { margin: 0 0 10px; font-size: 30px; }
    p { line-height: 1.5; }
    .url { margin: 18px 0; padding: 18px; border: 2px solid #0b8291; border-radius: 8px; background: #f6fbfc; font-size: 24px; font-weight: 700; word-break: break-all; }
    a { color: #0b7285; font-weight: 700; }
    ol, ul { line-height: 1.7; }
    .note { margin-top: 18px; padding: 14px 16px; border-left: 4px solid #0b8291; background: #f8fbfc; }
    @media (prefers-color-scheme: dark) {
      body { background: #101719; color: #edf5f7; }
      .panel { background: #182326; border-color: #314247; }
      .url, .note { background: #122024; }
      a { color: #55d4e7; }
    }
  </style>
</head>
<body>
  <main>
    <section class="panel">
      <h1>SilviForTANITA para movil</h1>
      <p>Abre esta direccion en Safari o Chrome del iPhone. El PC y el iPhone tienen que estar en la misma WiFi.</p>
      <div class="url">$safePrimary</div>
      <p>La direccion principal se ha copiado al portapapeles de Windows si el sistema lo permite.</p>
      <h2>Otras direcciones detectadas</h2>
      <ul>
        $urlItems
      </ul>
      <h2>Pasos</h2>
      <ol>
        <li>Deja esta ventana abierta y no apagues el PC.</li>
        <li>Conecta el iPhone a la misma WiFi que el PC.</li>
        <li>Escribe la direccion grande en el navegador del iPhone.</li>
        <li>Si Windows pregunta por Python o SilviForTANITA, pulsa Permitir acceso.</li>
      </ol>
      <div class="note">$safeFirewall</div>
      <p><a href="$safeLocal">Abrir la app en este PC</a></p>
    </section>
  </main>
</body>
</html>
"@

Set-Content -LiteralPath $helpFile -Value $html -Encoding UTF8
Start-Process $helpFile
