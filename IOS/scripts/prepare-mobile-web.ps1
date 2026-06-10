$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectRoot = Split-Path -Parent $root
$source = Join-Path $projectRoot "PC\SilviForTANITA"
$target = Join-Path $root "mobile-www"

if (-not (Test-Path -LiteralPath $source)) {
  throw "No encuentro la carpeta web PC\SilviForTANITA."
}

if (Test-Path -LiteralPath $target) {
  $resolvedRoot = (Resolve-Path -LiteralPath $root).Path
  $resolvedTarget = (Resolve-Path -LiteralPath $target).Path
  if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "La carpeta mobile-www no esta dentro del proyecto iOS."
  }
  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}

New-Item -ItemType Directory -Path $target | Out-Null
Copy-Item -LiteralPath (Join-Path $source "index.html") -Destination $target
Copy-Item -LiteralPath (Join-Path $source "README.md") -Destination $target
Copy-Item -LiteralPath (Join-Path $source "assets") -Destination $target -Recurse

Write-Host "Preparada carpeta movil iOS limpia: $target"
