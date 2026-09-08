# === MiniSteam Manager ===

$steamPath    = "C:\Program Files (x86)\Steam\Steam.exe"
$shortcutPath = "$env:USERPROFILE\Desktop\Steam.lnk"
$steamConfig  = "C:\Program Files (x86)\Steam\config"
$steamRoot    = "C:\Program Files (x86)\Steam"

function Show-Menu {
    Write-Host "`n========== MiniSteam ==========" -ForegroundColor Cyan
    Write-Host "  [1] Install Steam (+ apply tweaks)"
    Write-Host "  [2] Uninstall Steam"
    Write-Host "  [3] Apply tweaks only"
    Write-Host "  [4] Exit"
    Write-Host "==================================" -ForegroundColor Cyan
    Read-Host "Choose"
}

function Invoke-Install {
    $installer = "$env:TEMP\SteamSetup.exe"
    Write-Host "`n[Install] Downloading Steam installer..." -ForegroundColor Cyan
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe" -OutFile $installer
    Write-Host "[Install] Running installer. Follow the prompts." -ForegroundColor Yellow
    Start-Process -FilePath $installer -Wait
    Remove-Item $installer -Force -ErrorAction SilentlyContinue

    if (-not (Test-Path $steamPath)) {
        Write-Host "[Install] Steam not found after install. Did it complete?" -ForegroundColor Red
        return
    }

    Write-Host "[Install] Steam installed. Launching..." -ForegroundColor Green
    Start-Process -FilePath $steamPath

    # Wait for first login
    $loginUsers = Join-Path $steamConfig "loginusers.vdf"
    Write-Host "[Install] Waiting for first login..." -ForegroundColor Yellow
    while (-not (Test-Path $loginUsers)) {
        Start-Sleep -Seconds 2
    }
    Write-Host "[Install] Logged in!" -ForegroundColor Green
    Start-Sleep -Seconds 3

    Invoke-Tweaks
}

function Invoke-Uninstall {
    $uninstaller = "$steamRoot\uninstall.exe"
    if (Test-Path $uninstaller) {
        Write-Host "`n[Uninstall] Running Steam uninstaller..." -ForegroundColor Yellow
        Start-Process -FilePath $uninstaller -Wait
    } else {
        $key = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{048298C9-A483-39E9-FBDB-1FB6C90A48FC}"
        if (Test-Path $key) {
            $cmd = (Get-ItemProperty $key).UninstallString
            Write-Host "`n[Uninstall] Running: $cmd" -ForegroundColor Yellow
            Start-Process -FilePath $cmd.Substring(1) -ArgumentList "/S" -Wait
        } else {
            Write-Host "[Uninstall] Could not find uninstaller. Remove manually." -ForegroundColor Red
            return
        }
    }

    $oldShortcuts = @(
        "$env:USERPROFILE\Desktop\Steam.lnk"
        "$env:PUBLIC\Desktop\Steam.lnk"
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Steam.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam.lnk"
    )
    foreach ($s in $oldShortcuts) {
        if (Test-Path $s) { Remove-Item $s -Force }
    }
    Write-Host "[Uninstall] Done." -ForegroundColor Green
}

function Invoke-Tweaks {
    if (-not (Test-Path $steamPath)) {
        Write-Host "`n[Tweaks] Steam is not installed. Nothing to tweak." -ForegroundColor Red
        return
    }

    # --- 1. Kill Steam ---
    Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "[1/6] Steam closed." -ForegroundColor Yellow

    # --- 2. Delete old Steam shortcuts everywhere ---
    $oldShortcuts = @(
        "$env:USERPROFILE\Desktop\Steam.lnk"
        "$env:PUBLIC\Desktop\Steam.lnk"
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Steam.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam.lnk"
    )
    foreach ($s in $oldShortcuts) {
        if (Test-Path $s) {
            Remove-Item $s -Force
            Write-Host "  Deleted: $s" -ForegroundColor Yellow
        }
    }
    Write-Host "[2/6] Old shortcuts removed." -ForegroundColor Yellow

    # --- 3. Set DPISCALING to 0 (registry) ---
    reg add "HKCU\Software\Valve\Steam" /v DPISCALING /t REG_DWORD /d 0 /f
    Write-Host "[3/6] DPISCALING set to 0." -ForegroundColor Green

    # --- 4. Set default view to Library (sharedconfig.vdf) ---
    $shared = Get-ChildItem "$steamRoot\userdata" -Recurse -Filter "sharedconfig.vdf" | Select-Object -First 1
    if ($shared) {
        $t = Get-Content $shared.FullName -Raw
        if ($t -match '"SteamDefaultDialog"\s+"[^"]*"') {
            $t = $t -replace '"SteamDefaultDialog"\s+"[^"]*"', '"SteamDefaultDialog"    "#app_games"'
        } else {
            $t = $t -replace '("Steam")', '("Steam")
            {
                "SteamDefaultDialog"    "#app_games"
            }'
        }
        Set-Content $shared.FullName -Value $t -NoNewline
        Write-Host "[4/6] Library set as default." -ForegroundColor Green
    } else {
        Write-Host "[4/6] sharedconfig.vdf not found!" -ForegroundColor Red
    }

    # --- 5. Set autologin in loginusers.vdf ---
    $loginUsers = Join-Path $steamConfig "loginusers.vdf"
    if (Test-Path $loginUsers) {
        $t = Get-Content $loginUsers -Raw
        $t = $t -replace '"RememberPassword"\s+"[^"]*"', '"RememberPassword"    "1"'
        $t = $t -replace '"AllowAutoLogin"\s+"[^"]*"', '"AllowAutoLogin"    "1"'
        $t = $t -replace '"mostrecent"\s+"[^"]*"', '"mostrecent"    "1"'
        Set-Content $loginUsers -Value $t -NoNewline
        Write-Host "[5/6] Autologin enabled in loginusers.vdf." -ForegroundColor Green
    } else {
        Write-Host "[5/6] loginusers.vdf not found!" -ForegroundColor Red
    }

    # --- 6. Create new shortcut with all flags ---
    $flags = @(
        "-nofriendsui"
        "-no-dwrite"
        "-nointro"
        "-nobigpicture"
        "-nofasthtml"
        "-nocrashmonitor"
        "-noshaders"
        "-no-shared-textures"
        "-disablehighdpi"
        "-cef-single-process"
        "-cef-in-process-gpu"
        "-single_core"
        "-disable-winh264"
        "-vrdisable"
        "-cef-disable-breakpad"
        "-cef-disable-d3d11"
        "-cef-disable-gpu-compositing"
        "-cef-disable-gpu"
        "-cef-disable-js-logging"
        "-cef-disable-occlusion"
        "-cef-disable-renderer-restart"
        "-noconsole"
        "-oldtraymenu"
        "-showallbetas"
        "+open steam://open/minigameslist"
    ) -join " "

    $wsh = New-Object -ComObject WScript.Shell
    $sc = $wsh.CreateShortcut($shortcutPath)
    $sc.TargetPath = $steamPath
    $sc.Arguments = $flags
    $sc.WorkingDirectory = Split-Path $steamPath
    $sc.IconLocation = "$steamPath, 0"
    $sc.Save()
    Write-Host "[6/6] Shortcut created: $shortcutPath" -ForegroundColor Green

    # --- 7. Restart Steam ---
    Start-Process -FilePath $shortcutPath
    Write-Host "`nAll done. Steam restarted." -ForegroundColor Cyan
    Write-Host "If Steam is pinned to taskbar, unpin it, launch from Desktop, then re-pin." -ForegroundColor Yellow
}

# === Main loop ===
do {
    $choice = Show-Menu
    switch ($choice) {
        "1" { Invoke-Install }
        "2" { Invoke-Uninstall }
        "3" { Invoke-Tweaks }
        "4" { exit }
        default { Write-Host "Invalid choice." -ForegroundColor Red }
    }
} while ($true)   
