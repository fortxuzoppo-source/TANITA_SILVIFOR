@echo off
setlocal
set "SCRIPT=%~dp0Permitir_Firewall_SilviForTANITA.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
