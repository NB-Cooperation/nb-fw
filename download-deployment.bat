@echo off
setlocal

REM Zielverzeichnis
set "tempDir=C:\Temp"
set "scriptFile=%tempDir%\client-installation.ps1"

REM Verzeichnis erstellen, falls es nicht existiert
if not exist "%tempDir%" (
    mkdir "%tempDir%"
)

REM PowerShell-Skript herunterladen
powershell -NoProfile -Command ^
    "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/deployment/client-installation.ps1' -OutFile '%scriptFile%'"

REM PowerShell-Prozess starten und auf dessen Ende warten
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptFile%"
if errorlevel 1 (
    echo [Fehler] PowerShell-Skript hat mit Fehlercode %errorlevel% beendet.
) else (
    echo [Info] PowerShell-Skript erfolgreich abgeschlossen.
)

REM Warten kurz zur Sicherheit (optional, kann entfernt werden)
timeout /t 2 /nobreak >nul

REM Aufräumen: Skript und Verzeichnis löschen
del /f /q "%scriptFile%"
rmdir /s /q "%tempDir%"

endlocal
