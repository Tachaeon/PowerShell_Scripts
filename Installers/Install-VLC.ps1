if (-Not (Test-Path -Path 'C:\Install')) { New-Item -Path 'C:\Install' -ItemType Directory }
$LogPath = "C:\Install\IntuneAppInstall.log"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $entry
}

Write-Log "---- Starting VLC Install ----"

try {
    $baseListingUrl = "https://get.videolan.org/vlc/last/win64/"
    $html = Invoke-WebRequest -Uri $baseListingUrl

    $regexPattern = "vlc-(\d+\.\d+\.\d+)-win64\.exe"
    $match = [regex]::Match($html.Content, $regexPattern)

    if (-not $match.Success) {
        Write-Host "Failed to extract version number." -ForegroundColor Red
        #exit 1
    }

    $version = $match.Groups[1].Value
    Write-Log "Latest VLC version detected: $version" -ForegroundColor Green

    $mirrorUrl = "https://mirrors.rda.run/videolan/vlc/$version/win64/vlc-$version-win64.exe"
    $localInstallerPath = "$env:TEMP\vlc-$version-win64.exe"

    Write-Log "Downloading from mirror: $mirrorUrl" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $mirrorUrl -OutFile $localInstallerPath

    Write-Log "Installing VLC version $version..." -ForegroundColor Cyan
    Start-Process -FilePath $localInstallerPath -ArgumentList "/S" -Wait

    Write-Log "VLC $version installation complete!" -ForegroundColor Green
}
catch {
    Write-Log "Exception occurred during install: $($_.Exception.Message)" "ERROR"
}
