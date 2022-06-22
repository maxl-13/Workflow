function install-devpack ($version, $location) {
    Write-Host ".NET Framework $($version) Developer Pack..." -ForegroundColor Cyan
    Write-Host "Downloading..."
    $exePath = "$env:TEMP\$($version)-devpack.exe"
    (New-Object Net.WebClient).DownloadFile($location, $exePath)
    Write-Host "Installing..."
    cmd /c start /wait "$exePath" /log report.log /quiet /norestart
    Remove-Item $exePath -Force -ErrorAction Ignore
    Write-Host "Installed" -ForegroundColor Green
}

install-devpack -version "4.8" -location "https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c8c829444416e811be84c5765ede6148/ndp48-devpack-enu.exe"
