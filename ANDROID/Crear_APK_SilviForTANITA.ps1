$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$apk = Join-Path $root "APK\app\build\outputs\apk\debug\app-debug.apk"
$easyApk = Join-Path $root "APK\SilviForTANITA-debug.apk"

function Show-Message {
  param([string] $Message)
  try {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($Message, "SilviForTANITA APK") | Out-Null
  } catch {
    Write-Host $Message
  }
}

function Require-Command {
  param([string] $Name, [string] $Help)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Show-Message $Help
    exit 1
  }
}

function Find-FirstPath {
  param([string[]] $Paths)
  foreach ($path in $Paths) {
    if ($path -and (Test-Path -LiteralPath $path)) {
      return $path
    }
  }
  return ""
}

Set-Location $root

Require-Command "npm.cmd" "No encuentro Node/npm. Instala Node.js para preparar la app movil."

if (-not $env:JAVA_HOME) {
  $env:JAVA_HOME = Find-FirstPath @(
    "C:\Program Files\Android\Android Studio\jbr",
    "C:\Program Files\Android\Android Studio\jre",
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Java"
  )
}

if ($env:JAVA_HOME) {
  $env:Path = "$env:JAVA_HOME\bin;$env:Path"
}

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
  Show-Message "No encuentro Java/JDK. Para crear la APK instala Android Studio o un JDK, y despues vuelve a ejecutar este archivo."
  exit 1
}

if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT) {
  $sdk = Find-FirstPath @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "C:\Android\Sdk"
  )
  if ($sdk) {
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
  }
}

if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT) {
  Show-Message "No encuentro ANDROID_HOME ni ANDROID_SDK_ROOT. Instala Android Studio y abre el proyecto APK una vez para configurar el SDK."
  exit 1
}

$androidSdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { $env:ANDROID_SDK_ROOT }
$env:Path = "$androidSdk\platform-tools;$androidSdk\cmdline-tools\latest\bin;$env:Path"

npm.cmd run android:build:debug

if (Test-Path -LiteralPath $apk) {
  Copy-Item -LiteralPath $apk -Destination $easyApk -Force
  Show-Message "APK creada correctamente:`n$easyApk"
  Start-Process explorer.exe -ArgumentList "/select,`"$easyApk`""
} else {
  Show-Message "Gradle termino, pero no encuentro la APK esperada:`n$apk"
}
