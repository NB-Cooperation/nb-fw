@echo off

:: --------------------------------------------------
:: Batch-Script: Download, Ausführen und Cleanup ohne Admin-Rechte
:: --------------------------------------------------

:: 1. Ordner C:\Temp erstellen, falls nicht vorhanden
if not exist "C:\Temp" mkdir "C:\Temp"

:: 2. Powershell-Script herunterladen
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/deployment/client-deployment.ps1' -OutFile 'C:\Temp\client-deployment.ps1'"

:: 3. Script ausführen und auf Beendigung warten
powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Temp\client-deployment.ps1"

:: 4. Aufräumen: Script und Ordner wieder löschen
rd /s /q "C:\Temp"

exit /b
