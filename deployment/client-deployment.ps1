$ErrorActionPreference= 'silentlycontinue'

function getLatest()
{
    # Get the latest release
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest"
    
    # Find the x86_64.exe asset
    $asset = $latestRelease.assets | Where-Object { $_.name -like "*x86_64.exe" } | Select-Object -First 1
    
    if (-not $asset) {
        Write-Error "x86_64.exe file not found in latest release!"
        exit 1
    }

    return($asset)
}

$RustDeskOnGitHub = getLatest

New-Item -Path "$env:APPDATA\RustDesk\config" -ItemType Directory -Force
Invoke-WebRequest "https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/config" -OutFile "$env:APPDATA\RustDesk\config\RustDesk2.toml"

Set-Location $env:USERPROFILE\Downloads

Start-BitsTransfer -Source $RustDeskOnGitHub.browser_download_url -Destination $RustDeskOnGitHub.name
(Get-Item $RustDeskOnGitHub.name).LastWriteTime = Get-Date

.\rustdesk.exe 
Start-Sleep -seconds 2
