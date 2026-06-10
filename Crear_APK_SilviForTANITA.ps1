$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$apk = Join-Path $root "APK\app\build\outputs\apk\debug\app-debug.apk"

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

Set-Location $root

Require-Command "npm.cmd" "No encuentro Node/npm. Instala Node.js para preparar la app movil."

if (-not (Get-Command java -ErrorAction SilentlyContinue) -and -not $env:JAVA_HOME) {
  Show-Message "No encuentro Java/JDK. Para crear la APK instala Android Studio o un JDK, y despues vuelve a ejecutar este archivo."
  exit 1
}

if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT) {
  Show-Message "No encuentro ANDROID_HOME ni ANDROID_SDK_ROOT. Instala Android Studio y abre el proyecto APK una vez para configurar el SDK."
  exit 1
}

npm.cmd run android:build:debug

if (Test-Path -LiteralPath $apk) {
  Show-Message "APK creada correctamente:`n$apk"
  Start-Process explorer.exe -ArgumentList "/select,`"$apk`""
} else {
  Show-Message "Gradle termino, pero no encuentro la APK esperada:`n$apk"
}
