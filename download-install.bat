@echo off

:: --------------------------------------------------
:: Batch-Script: Download, Ausführen und Cleanup
:: --------------------------------------------------

:: 1. Als Administrator neu starten, falls nicht bereits erhöht
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Starte mit Administrator-Rechten...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb runAs"
    exit /b
)

:: 2. Ordner C:\Temp erstellen, falls nicht vorhanden
if not exist "C:\Temp" mkdir "C:\Temp"

:: 3. Powershell-Script herunterladen
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/deployment/client-installation.ps1' -OutFile 'C:\Temp\client-installation.ps1'"

:: 4. Script als Admin ausführen und auf Beendigung warten
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Temp\client-installation.ps1"

:: 5. Aufräumen: Script und Ordner wieder löschen
rd /s /q "C:\Temp"

exit /b
