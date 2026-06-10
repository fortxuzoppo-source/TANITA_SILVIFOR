$ErrorActionPreference = "Stop"

$ruleName = "SilviForTANITA puerto 8765"
$port = 8765

function Test-IsAdmin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
  $scriptPath = $PSCommandPath
  Start-Process `
    -FilePath "powershell" `
    -Verb RunAs `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
  exit 0
}

$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if (-not $existing) {
  New-NetFirewallRule `
    -DisplayName $ruleName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort $port `
    -Profile Private,Domain | Out-Null
}

Write-Host ""
Write-Host "Firewall preparado para SilviForTANITA en el puerto $port."
Write-Host "Ya puedes volver a abrir Abrir_SilviForTANITA_Movil.bat."
Write-Host ""
Read-Host "Pulsa ENTER para cerrar"
