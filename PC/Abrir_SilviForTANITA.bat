@echo off
setlocal
set "SCRIPT=%~dp0Abrir_SilviForTANITA.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

if errorlevel 1 (
  echo.
  echo No se pudo abrir SilviForTANITA. Comprueba que Python este instalado.
  pause
)
