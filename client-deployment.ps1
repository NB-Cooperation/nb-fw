$ErrorActionPreference= 'silentlycontinue'

# Get your config string from your Web portal and Fill Below
$rustdesk_cfg="Qfi0zawREShBnaPFUTQxUT1dFZP5GVvpVc0RnaGJWckVnR24WbUxmNGFnYOZ2ViojI5V2aiwiIiojIpBXYiwiIlRmLu9Wa0FmclB3bvNWLi5mLrNXZkR3c1JnI6ISehxWZyJCLiUGZu42bpRXYyVGcv92YtImbus2clRGdzVnciojI0N3boJye"

################################### Please Do Not Edit Below This Line #########################################

# This function will return the latest version and download link as an object
function getLatest()
{
    $Page = Invoke-WebRequest -Uri 'https://github.com/rustdesk/rustdesk/releases/latest' -UseBasicParsing
    $HTML = New-Object -Com "HTMLFile"
    try
    {
        $HTML.IHTMLDocument2_write($Page.Content)
    }
    catch
    {
        $src = [System.Text.Encoding]::Unicode.GetBytes($Page.Content)
        $HTML.write($src)
    }

    # Current example link: https://github.com/rustdesk/rustdesk/releases/download/1.2.6/rustdesk-1.2.6-x86_64.exe
    $Downloadlink = ($HTML.Links | Where {$_.href -match '(.)+\/rustdesk\/rustdesk\/releases\/download\/\d{1}.\d{1,2}.\d{1,2}(.{0,3})\/rustdesk(.)+x86_64.exe'} | select -first 1).href

    # bugfix - sometimes you need to replace "about:"
    $Downloadlink = $Downloadlink.Replace('about:', 'https://github.com')

    $Version = "unknown"
    if ($Downloadlink -match './rustdesk/rustdesk/releases/download/(?<content>.*)/rustdesk-(.)+x86_64.exe')
    {
        $Version = $matches['content']
    }

    if ($Version -eq "unknown" -or $Downloadlink -eq "")
    {
        Write-Output "ERROR: Version or download link not found."
        Exit
    }

    # Create object to return
    $params += @{Version = $Version}
    $params += @{Downloadlink = $Downloadlink}
    $Result = New-Object PSObject -Property $params

    return($Result)
}

$RustDeskOnGitHub = getLatest

cd $env:USERPROFILE\Downloads

Invoke-WebRequest $RustDeskOnGitHub.Downloadlink -Outfile "rustdesk.exe"
.\rustdesk.exe 
Start-Sleep -seconds 2
.\rustdesk.exe -config $rustdesk_cfg
