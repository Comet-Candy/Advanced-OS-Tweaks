# ============================================
# Open-Shell: Import XML + Custom Button + Theme
# ============================================

$dl = "$env:USERPROFILE\Downloads"
$xmlPath = "$dl\openshell_settings.xml"
$btnPath = "$dl\startbutton_animated.png"
$regFile = "$dl\Pitch Black Theme.reg"
$batPath = "$env:TEMP\openshell_import.bat"

# --- Download ---
Write-Host "Downloading..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Comet-Candy/Tweaks/main/CoolStartMenu/Classic-Shell_or_Open-Shell_StartMenu_optimized_settings.xml" -OutFile $xmlPath
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Comet-Candy/Tweaks/main/CoolStartMenu/startbutton.png" -OutFile $btnPath
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Comet-Candy/Tweaks/main/CoolStartMenu/.%20Pitch%20Black%20Theme.reg" -OutFile $regFile
Write-Host "Downloaded." -ForegroundColor Green

# --- Import XML (silent CMD) ---
Write-Host "Importing XML..." -ForegroundColor Cyan
$bat = @"
@echo off
"C:\Program Files\Open-Shell\StartMenu.exe" -xml "$xmlPath"
"@
Set-Content -Path $batPath -Value $bat
Start-Process cmd -ArgumentList "/c `"$batPath`"" -WindowStyle Hidden -Wait
Remove-Item $batPath -Force
Write-Host "XML imported." -ForegroundColor Green

# --- Override button to custom PNG ---
Write-Host "Setting custom button..." -ForegroundColor Cyan
$reg = "HKCU:\Software\OpenShell\StartMenu\Settings"
Set-ItemProperty -Path $reg -Name "StartButtonType" -Value "CustomButton" -Type String -Force
Set-ItemProperty -Path $reg -Name "StartButtonPath" -Value $btnPath -Type String -Force
Write-Host "Button set." -ForegroundColor Green

# --- Apply Pitch Black Theme ---
Write-Host "Applying Pitch Black Theme..." -ForegroundColor Cyan
Start-Process regedit -ArgumentList "/s `"$regFile`"" -Wait -WindowStyle Hidden
Write-Host "Theme applied." -ForegroundColor Green

# --- Reload Open-Shell ---
Write-Host "Reloading..." -ForegroundColor Cyan
Start-Process "C:\Program Files\Open-Shell\StartMenu.exe" -ArgumentList "-reloadsettings" -WindowStyle Hidden
Write-Host "Done." -ForegroundColor Green   
