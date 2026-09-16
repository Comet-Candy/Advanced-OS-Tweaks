# ==============================================================================
# AUTOMATIC RUNTIME BINARY DEPLOYMENT (DIRECT REFS/HEADS CDN LINK)
# ==============================================================================
$SetACL = Join-Path $env:TEMP "64SetACL.exe"

Write-Host "Fetching 64SetACL.exe from GitHub CDN mirror..." -ForegroundColor Yellow

# Your explicit direct raw content delivery link
$RawUrl = "https://github.com/Comet-Candy/Advanced-OS-Tweaks/raw/refs/heads/main/Apps/64SetACL.exe"

try {
    # Force connection protocols to modern infrastructure standards
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    
    # Download the tool directly into the hidden system temp folder partition
    Invoke-WebRequest -Uri $RawUrl -OutFile $SetACL -UseBasicParsing
    Write-Host "Successfully deployed 64SetACL.exe to background runtime environment." -ForegroundColor Green
    Write-Host " "
}
catch {
    Write-Error "CRITICAL DOWNLOAD FAULT: Failed to retrieve file from GitHub CDN repository."
    Pause; Exit
}

# ==============================================================================
# UNIFIED REGISTRY & FILE SYSTEM DATABASE
# ==============================================================================
$Targets = @(
    "C:\WINDOWS\Fonts", "C:\Windows\Resources", "C:\Windows\System32\DriverStore\FileRepository\amdfendr.inf_amd64_7da15bd9af6a450f",
    "C:\Windows\System32\DriverStore\FileRepository\amdfendr.inf_amd64_fbce97352464e3d7", "C:\Windows\System32\wbem\AutoRecover",
    "C:\Windows\System32\dwm.exe", "C:\Windows\System32\Windows.UI.logon.dll", "C:\Windows\System32\dwminit.dll",
    "C:\Windows\System32\dwmapi.dll", "C:\Windows\System32\dwmcore.dll", "C:\Windows\System32\dwmghost.dll",
    "C:\Windows\System32\dwmredir.dll", "C:\Windows\System32\dwmscene.dll", "C:\Windows\System32\amdfendr.exe",
    "C:\ProgramData\Microsoft\Windows Defender", "C:\Program Files\Windows Defender", "C:\Program Files\Windows Defender Advanced Threat Protection",
    "HKLM\System\CurrentControlSet\Services\TrustedInstaller", "HKLM\System\CurrentControlSet\Services\WdiSystemHost",
    "HKLM\System\CurrentControlSet\Services\WdiServiceHost", "HKLM\System\CurrentControlSet\Services\TrkWks",
    "HKLM\System\CurrentControlSet\Services\DPS", "HKLM\System\CurrentControlSet\Services\SecurityHealthService",
    "HKLM\System\CurrentControlSet\Services\wscsvc", "HKLM\System\CurrentControlSet\Services\SamSs",
    "HKLM\System\CurrentControlSet\Services\WdBoot", "HKLM\System\CurrentControlSet\Services\WdFilter",
    "HKLM\System\CurrentControlSet\Services\WdNisDrv", "HKLM\System\CurrentControlSet\Services\WdNisSvc",
    "HKLM\System\CurrentControlSet\Services\WinDefend", "HKLM\System\CurrentControlSet\Services\MDCoreSvc",
    "HKLM\System\CurrentControlSet\Services\MpKsl863bd5cf", "HKLM\System\CurrentControlSet\Services\DcomLaunch",
    "HKLM\System\CurrentControlSet\Services\Sense", "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger",
    "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger", "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog",
    "HKLM\SYSTEM\CurrentControlSet\Control\Diagnostics\Performance", "HKLM\SYSTEM\DriverDatabase\Policies\Settings",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration",
    "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId", "HKLM\SOFTWARE\Microsoft\Windows Security Health",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Wallpaper", "HKLM\SOFTWARE\Microsoft\Windows Defender",
    "HKLM\SOFTWARE\Microsoft\Assistance\Client\1.0\Settings", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DelayedApps",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ResourceTimers", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.delete",
    "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex", "HKLM\SOFTWARE\Microsoft\Windows Search\Gathering Manager",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f8278c54-a712-415b-b593-b77a2be0dda9}",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{EDC978D6-4D53-4b2f-A265-5805674BE568}",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{8FD8B88D-30E1-4F25-AC2B-553D3D65F0EA}",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{5b934b42-522b-4c34-bbfe-37a3ef7b9c90}",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{2F6CE85C-F9EE-43CA-90C7-8A9BD53A2467}",
    "HKLM\SOFTWARE\Classes\AppID\SppComApi.dll", "HKLM\SOFTWARE\Classes\AppID\slui.exe",
    "HKCR\CLSID\{088e3905-0323-4b02-9826-5d99428e115f}", "HKCR\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
    "HKCR\Wow6432Node\CLSID\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}", "HKCR\CLSID\{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
    "HKCR\Wow6432Node\CLSID\{A0953C92-50DC-43bf-BE83-3742FED03C9C}", "HKCR\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
    "HKCR\Wow6432Node\CLSID\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}", "HKCR\CLSID\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
    "HKCR\Wow6432Node\CLSID\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}", "HKCR\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
    "HKCR\Wow6432Node\CLSID\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}", "HKCR\CLSID\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
    "HKCR\Wow6432Node\CLSID\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}", "HKCR\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDa",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds\ShellFeedsTaskbarViewMode",
    "HKCU\WOW6432Node\AppID\{cd93979b-c14e-4c29-87a4-75e4f9fa5e0a}", "HKCU\AppID\{cd93979b-c14e-4c29-87a4-75e4f9fa5e0a}",
    "HKCU\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}", "HKCU\WOW6432Node\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}",
    "HKCU\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder\Attributes"
)

Write-Host "Starting target optimization loops..." -ForegroundColor White

foreach ($P in $Targets) {
    if ($P -like "C:\*") {
        if (-not (Test-Path $P)) {
            Write-Host "NOT FOUND: $P" -ForegroundColor Yellow
            continue
        }
        $Type = "file"

        # Pre-cleanup check logic for Windows Defender Local Data blocks
        if ($P -eq "C:\ProgramData\Microsoft\Windows Defender") {
            & $SetACL -on $P -ot file -actn trustee -trst "n1:Administrators;ta:remtrst;w:dacl" -silent
            & $SetACL -on $P -ot file -actn trustee -trst "n1:Administrators;ta:remtrst;w:dacl" -rec cont_obj -silent
        }
    } else {
        $Type = "reg"

        # Normalize shorts for Test-Path confirmation step
        $TestReg = $P -replace "^HKLM", "HKLM:" -replace "^HKCU", "HKCU:" -replace "^HKCR", "Registry::HKEY_CLASSES_ROOT"
        if (-not (Test-Path $TestReg)) {
            Write-Host "NOT FOUND: $P" -ForegroundColor Yellow
            continue
        }

        # Pre-cleanup check logic for WdBoot Service Keys
        if ($P -like "*Services\WdBoot") {
            & $SetACL -on $P -ot reg -actn trustee -trst "n1:Administrators;ta:remtrst;w:dacl" -silent
            & $SetACL -on $P -ot reg -actn trustee -trst "n1:Administrators;ta:remtrst;w:dacl" -rec cont_obj -silent
        }
    }

    # Setup recursion rules
    if ($Type -eq "file" -and -not (Test-Path $P -PathType Container)) {
        $Rec = $null
    } else {
        $Rec = @("-rec", "cont_obj")
    }

    # Fire commands and catch standard error output tokens to format confirmations cleanly
    $OwnerError = & $SetACL -on $P -ot $Type -actn setowner -ownr "n:Administrators" $Rec -erroraction SilentlyContinue 2>&1
    $AceError   = & $SetACL -on $P -ot $Type -actn ace -ace "n:Administrators;p:full" $Rec -erroraction SilentlyContinue 2>&1

    if ($OwnerError -like "*failed*" -or $AceError -like "*failed*") {
        Write-Host "FAILED: Injections blocked on [$Type] -> $P" -ForegroundColor Red
    } else {
        Write-Host "INJECTED: Full Owner and Access applied to [$Type] -> $P" -ForegroundColor Green
    }
}

# ==============================================================================
# RUNTIME ENVIRONMENT TEARDOWN
# ==============================================================================
if (Test-Path $SetACL) {
    Remove-Item -Path $SetACL -Force -ErrorAction SilentlyContinue
    Write-Host " "
    Write-Host "[+] Temporary binary asset cleaned from memory safely." -ForegroundColor Gray
}

Write-Host "All paths processed. Check log metrics above." -ForegroundColor White
Pause
