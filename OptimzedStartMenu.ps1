# Import Open-Shell settings from gist and restart to apply cold settings

$openShellPath = "C:\Program Files\Open-Shell\StartMenu.exe"
$gistUrl = "https://gist.githubusercontent.com/AveYo/f2add193abfb2ddc5963e11273df083b/raw/284b514959351d952f26edbda9b93d4e0a7ac814/Classic-Shell_or_Open-Shell_StartMenu_optimized_settings.xml"
$tempXml = Join-Path $env:TEMP "OpenShellSettings.xml"

# Download settings
Write-Host "Downloading settings..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $gistUrl -OutFile $tempXml

# Import settings
Write-Host "Importing settings..." -ForegroundColor Cyan
& $openShellPath -xml $tempXml

# Restart Open-Shell to apply cold settings
Write-Host "Restarting Open-Shell to apply all settings..." -ForegroundColor Cyan
& $openShellPath -exit
Start-Sleep -Seconds 2
& $openShellPath -startup

# Cleanup
Remove-Item $tempXml -Force

Write-Host "Done. Settings applied." -ForegroundColor Green   
