@echo off
setlocal
set "SCRIPT=%~dp0Abrir_SilviForTANITA_Movil.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

if errorlevel 1 (
  echo.
  echo No se pudo preparar SilviForTANITA para el movil.
  echo Comprueba que Python este instalado y que Windows no bloquee el puerto 8765.
  pause
)
