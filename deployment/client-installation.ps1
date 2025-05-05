$ErrorActionPreference= 'silentlycontinue'

# Run as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    $scriptUrl = "https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/deployment/client-installation.ps1"
    
    $arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"irm $scriptUrl | iex`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

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


$rdver = ((Get-ItemProperty  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk\").Version)
$version = [regex]::Match($RustDeskOnGitHub.browser_download_url, "\d+\.\d+\.\d+").Value
if ($rdver -eq $version)
{
    Write-Output "RustDesk $rdver is the newest version."
    Exit
}

if (!(Test-Path C:\Temp))
{
    New-Item -ItemType Directory -Force -Path C:\Temp | Out-Null
}
Set-Location C:\Temp

Start-BitsTransfer -Source $RustDeskOnGitHub.browser_download_url -Destination "rustdesk.exe"

Start-Process .\rustdesk.exe --silent-install
Start-Sleep -seconds 20

Set-Location "$($env:ProgramFiles)\RustDesk"

$ServiceName = 'Rustdesk'
$arrService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

while ($arrService -ne $null)
{
    Start-Process .\rustdesk.exe --uninstall-service
    Start-Sleep -seconds 10
}

Write-Output "Installing config file"
$filepath = Join-Path $env:APPDATA "Rustdesk\config\RustDesk2.toml"
Remove-Item -Path $filepath -Force
Invoke-WebRequest "https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/config" -OutFile $filePath
Start-Sleep -seconds 5

if ($arrService -eq $null)
{
    Write-Output "Installing service"
    Start-Process .\rustdesk.exe --install-service
    Start-Sleep -seconds 20
    $arrService = Get-Service -Name $ServiceName
}




while ($arrService.Status -ne 'Running')
{
    Start-Service $ServiceName
    Start-Sleep -seconds 5
    $arrService.Refresh()
}
