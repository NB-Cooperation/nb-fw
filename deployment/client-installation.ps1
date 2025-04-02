$ErrorActionPreference= 'silentlycontinue'

# Run as administrator and stays in the current directory
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000)
    {
        Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
        Exit;
    }
}

# This function will return the latest version and download link
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

if (-not (Test-Path "$env:APPDATA\RustDesk\config\RustDesk2.toml")) {
    New-Item -Path "$env:APPDATA\RustDesk\config" -ItemType Directory -Force
    Invoke-WebRequest "https://raw.githubusercontent.com/NB-Cooperation/nb-fw/refs/heads/main/config" -OutFile "$env:APPDATA\RustDesk\config\RustDesk2.toml"
}

$rdver = ((Get-ItemProperty  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RustDesk\").Version)

if ($rdver -eq $RustDeskOnGitHub.Version)
{
    Write-Output "RustDesk $rdver is the newest version."
    Exit
}

if (!(Test-Path C:\Temp))
{
    New-Item -ItemType Directory -Force -Path C:\Temp | Out-Null
}

cd C:\Temp

Start-BitsTransfer -Source $RustDeskOnGitHub.browser_download_url -Destination "rustdesk.exe"
Start-Process .\rustdesk.exe --silent-install
Start-Sleep -seconds 20

$ServiceName = 'Rustdesk'
$arrService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($arrService -eq $null)
{
    Write-Output "Installing service"
    cd $env:ProgramFiles\RustDesk
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

