# --- Night Light ---
$modulePath = "$env:TEMP\Switch-NightLight.psm1"
if (-not (Test-Path $modulePath)) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nathanbabcock/nightlight-cli/main/src/Switch-NightLight.psm1" -OutFile $modulePath
}
Import-Module $modulePath -Force
Enable-NightLight
Set-NightLightStrength -Percentage 80

# --- Wallpaper ---
$imageUrl = "https://r4.wallpaperflare.com/wallpaper/543/404/63/abstract-polygon-dark-bw-wallpaper-406075d95f368ec3789f6786bba604d8.jpg"
$localPath = "$env:USERPROFILE\Pictures\wallpaper.jpg"

Write-Host "Downloading wallpaper..."
Invoke-WebRequest -Uri $imageUrl -OutFile $localPath

Write-Host "Setting desktop background..."
$code = @'
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lvParam, int fuWinIni);
}
'@
Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
[Wallpaper]::SystemParametersInfo(0x0014, 0, $localPath, 0x0001 -bor 0x0002)

# --- Brightness ---
Write-Host "Setting screen brightness to 100%..."
Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods |
    Invoke-CimMethod -MethodName WmiSetBrightness -Arguments @{ Timeout = 0; Brightness = 100 }

Write-Host "All tasks completed successfully!"   
