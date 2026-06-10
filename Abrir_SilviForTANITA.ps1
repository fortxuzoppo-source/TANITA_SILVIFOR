$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$url = "http://127.0.0.1:8765/SilviForTANITA/"
$api = "http://127.0.0.1:8765/api/state"
$server = Join-Path $root "server.py"
$outLog = Join-Path $env:TEMP "silvifortanita_server.out.log"
$errLog = Join-Path $env:TEMP "silvifortanita_server.err.log"

function Test-SilviServer {
  try {
    Invoke-WebRequest -Uri $api -UseBasicParsing -TimeoutSec 1 | Out-Null
    return $true
  } catch {
    return $false
  }
}

function Show-ErrorMessage {
  param([string] $Message)
  try {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($Message, "SilviForTANITA") | Out-Null
  } catch {
    Write-Host $Message
  }
}

$ready = Test-SilviServer

if (-not $ready) {
  $listeners = Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue
  foreach ($listener in $listeners) {
    Stop-Process -Id $listener.OwningProcess -Force -ErrorAction SilentlyContinue
  }

  $python = (Get-Command python -ErrorAction SilentlyContinue).Source
  if (-not $python) {
    $python = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
  }
  if (-not $python) {
    Show-ErrorMessage "No encuentro Python en este equipo."
    exit 1
  }

  Remove-Item $outLog, $errLog -ErrorAction SilentlyContinue
  $serverArg = '"' + $server.Replace('"', '\"') + '"'
  $arguments = "$serverArg --host 127.0.0.1 --port 8765"
  Start-Process `
    -FilePath $python `
    -ArgumentList $arguments `
    -WorkingDirectory $root `
    -WindowStyle Hidden `
    -RedirectStandardOutput $outLog `
    -RedirectStandardError $errLog

  for ($i = 0; $i -lt 30; $i += 1) {
    Start-Sleep -Milliseconds 250
    if (Test-SilviServer) {
      $ready = $true
      break
    }
  }
}

if (-not $ready) {
  $detail = ""
  if (Test-Path $errLog) {
    $detail = (Get-Content $errLog -Raw).Trim()
  }
  if (-not $detail) {
    $detail = "No se pudo arrancar el servidor local."
  }
  Show-ErrorMessage $detail
  exit 1
}

Start-Process $url
