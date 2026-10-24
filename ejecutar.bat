@echo off
title PoliMusic - Despliegue en IIS
echo.
echo  Publicando PoliMusic en IIS...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
if errorlevel 1 (
    echo.
    echo  Ocurrio un error. Revisa el mensaje de arriba.
    pause
)
