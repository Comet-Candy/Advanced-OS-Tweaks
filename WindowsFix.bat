@echo off
:: =====================================================================
#  WARNING: USE AT OWN RISK AS IS WITHOUT WARRANTY OF ANY KIND !!!!!
:: =====================================================================

:: Privilege Elevation Handshake
FLTMC >nul 2>&1 || (
    echo Elevating privileges to Administrator...
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Component Based Servicing Tweaks
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v "DisableRemovePayload" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v "EnableDpxLog" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v "LCUReoffer" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v "DisableWerReporting" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v "ResetManifestCache" /t REG_DWORD /d "1" /f

:: SideBySide Configuration Tweaks
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "CompressBackups" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "CompressMutables" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableResetbase" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "LCUReoffer" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "NTFSCompressPayload" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "NumCBSPersistLogs" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "ReofferUpdate" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "CBSLogCompress" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableComponentBackups" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "PreserveFileCompressionState" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "SupersededActions" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "TransientManifestCache" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Configuration" /v "DisableWerReporting" /t REG_DWORD /d "1" /f

:: Reserve Manager & System Administration Policies
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "MiscPolicyInfo" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "PassedPolicy" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ValidateAdminCodeSignatures" /t REG_DWORD /d "0" /f

:: Automated Volume Cleanmgr Flag Registration Matrix
for %%V in ("Active Setup Temp Folders" "Content Indexer Cleaner" "D3D Shader Cache" "Delivery Optimization Files" "Device Driver Packages" "Diagnostic Data Viewer database files" "Downloaded Program Files" "Internet Cache Files" "Old ChkDsk Files" "Previous Installations" "Recycle Bin" "RetailDemo Offline Content" "Setup Log Files" "System error memory dump files" "System error minidump files" "Temporary Files" "Temporary Setup Files" "Thumbnail Cache" "Upgrade Discarded Files" "User file versions" "Windows Defender" "Windows Error Reporting Files" "Windows ESD installation files" "Windows Upgrade Log Files") do (
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\%%~V" /v "StateFlags6553" /t REG_DWORD /d "2" /f
)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\DownloadsFolder" /v "StateFlags6553" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files" /v "StateFlags6553" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" /v "StateFlags6553" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" /v "Autorun" /t REG_DWORD /d "0" /f

:: Environmental & Core Storage Handshakes
Dism /Online /Set-ReservedStorageState /State:Disabled /Quiet /NoRestart
vssadmin delete shadows /for=c: /all /quiet
fsutil usn deletejournal /d /n c:
ipconfig /flushdns
winget source update
winget export -o D:\OneDrive\Setup\winget.txt --accept-source-agreements

:: Reset Shell View Configuration Caches & Notification Trays
for %%B in ("Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" "Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" "Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\Bags" "Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" "Microsoft\Windows\Shell\Bags" "Microsoft\Windows\Shell\BagMRU" "Microsoft\Windows\ShellNoRoam\Bags" "Microsoft\Windows\ShellNoRoam\BagMRU") do (
    reg delete "HKCU\Software\%%~B" /f >nul 2>&1
)
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v "IconStreams" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v "PastIconsStream" /f >nul 2>&1

:: Kill Target System Processing Elements & Background Caches
for %%P in (msi.exe wuauclt.exe sihclient.exe TiWorker.exe trustedinstaller.exe MoUsoCoreWorker.exe UsoClient.exe usocoreworker.exe brave.exe chrome.exe firefox.exe librewolf.exe msedge.exe tor.exe) do (
    taskkill /im %%P /f >nul 2>&1
)
schtasks /End /TN "\Microsoft\Windows\Wininet\CacheTask" >nul 2>&1

:: Drop Core Maintenance Services
for %%S in (bits cryptSvc DoSvc EventLog msiserver UsoSvc winmgmt wuauserv) do (
    net stop %%S /y >nul 2>&1
)
@echo off
:: Structural Lock Clear Setup
takeown /f "%WINDIR%\winsxs\pending.xml" /a >nul 2>&1
icacls "%WINDIR%\winsxs\pending.xml" /grant:r Administrators:F /c >nul 2>&1
del "%WINDIR%\winsxs\pending.xml" /s /f /q >nul 2>&1

:: Drop Drive Recycle Matrices
for %%D in (C: D: E: Z:) do (
    rd "%%D\$Recycle.bin" /s /q >nul 2>&1
)

:: Clear Target Junk Paths
for %%F in (
    "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
    "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"
    "%LocalAppData%\Microsoft\Windows\WebCache"
    "%LocalAppData%\Temp"
    "%ProgramData%\Applications"
    "%ProgramData%\Package Cache"
    "%ProgramData%\USOPrivate\UpdateStore"
    "%ProgramData%\USOShared\Logs"
    "%SystemDrive%\$GetCurrent"
    "%SystemDrive%\$SysReset"
    "%SystemDrive%\$Windows.~BT"
    "%SystemDrive%\$Windows.~WS"
    "%SystemDrive%\$WinREAgent"
    "%SystemDrive%\OneDriveTemp"
    "%SystemDrive%\Recovery"
    "%temp%"
    "%WINDIR%\Logs"
    "%WINDIR%\Installer\$PatchCache$"
    "%WINDIR%\SoftwareDistribution"
    "%WINDIR%\System32\catroot2"
    "%WINDIR%\System32\LogFiles"
    "%WINDIR%\System32\winevt\Logs"
    "%WINDIR%\Temp"
    "%WINDIR%\WinSxS\Backup"
    "D:\OneDrive\Soft\Brave"
    "D:\OneDrive\Soft\Edge"
    "D:\OneDrive\Soft\Librewolf"
) do (
    del "%%~F" /s /f /q >nul 2>&1
    rd "%%~F" /s /q >nul 2>&1
)

:: Synchronize App Profiles via Robust Directory Copying
xcopy "%LocalAppData%\BraveSoftware\Brave-Browser\User Data" "D:\OneDrive\Soft\Brave" /s /i /y /q >nul 2>&1
xcopy "%LocalAppData%\Microsoft\Edge" "D:\OneDrive\Soft\Edge" /s /i /y /q >nul 2>&1
xcopy "%AppData%\Librewolf" "D:\OneDrive\Soft\Librewolf" /s /i /y /q >nul 2>&1

:: Sync Critical Application Configuration Profiles
xcopy "%AppData%\MPC-BE\mpc-be64.ini" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\MPC-BE\mpc-be64.ini" /y /q >nul 2>&1
xcopy "%AppData%\Rizonesoft\Notepad3\Notepad3.ini" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\Rizonesoft\Notepad3\Notepad3.ini" /y /q >nul 2>&1
xcopy "%AppData%\SystemInformer\settings.json" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\SystemInformer\settings.json" /y /q >nul 2>&1
xcopy "%AppData%\Wise Disk Cleaner\Config.ini" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\Wise Disk Cleaner\Config.ini" /y /q >nul 2>&1
xcopy "%AppData%\Wise Disk Cleaner\exclusions.dat" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\Wise Disk Cleaner\exclusions.dat" /y /q >nul 2>&1
xcopy "%AppData%\Wise Registry Cleaner\Config.ini" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\Wise Registry Cleaner\Config.ini" /y /q >nul 2>&1
xcopy "%AppData%\XnView\xnview.ini" "D:\OneDrive\Setup\Users\Tairi\AppData\Roaming\XnView\xnview.ini" /y /q >nul 2>&1

:: Structural Hardware Database Alignment & WMI Compilation
winmgmt /salvagerepository
cd /d "%WINDIR%\System32\wbem"
for /f %%s in ('dir /b *.mof') do mofcomp %%s >nul 2>&1
lodctr /r >nul 2>&1

:: Execution of Core Image Target Engineering (DISM Stack)
DISM /Get-mountedwiminfo
DISM /Cleanup-mountpoints
DISM /Cleanup-wim
DISM /Online /Cleanup-Image /RestoreHealth
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
DISM /Online /Cleanup-Image /Spsuperseded

:: Core Diagnostics & Local Cleaning
sfc /scannow
chkdsk /scan
cleanmgr /sagerun:6553

:: Call Third-Party Automated Utilities
if exist "%ProgramFiles(x86)%\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe" (
    start "" /wait "%ProgramFiles(x86)%\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe" -a -all
    start "" /wait "%ProgramFiles(x86)%\Wise\Wise Disk Cleaner\WiseDiskCleaner.exe"
)
if exist "%ProgramFiles(x86)%\Wise\Wise Registry Cleaner\WiseRegCleaner.exe" (
    start "" /wait "%ProgramFiles(x86)%\Wise\Wise Registry Cleaner\WiseRegCleaner.exe" -a -all
)
if exist "D:\OneDrive\Soft\Windows Repair Toolbox\Downloads\Custom Tools\Added Custom Tools\Rapr.exe" (
    start "" /wait "D:\OneDrive\Soft\Windows Repair Toolbox\Downloads\Custom Tools\Added Custom Tools\Rapr.exe"
)
if exist "%ProgramFiles%\Kingston_SSD_Manager\KSM_Gen15.exe" (
    start "" /wait "%ProgramFiles%\Kingston_SSD_Manager\KSM_Gen15.exe"
)

:: Hasleo Backup Interface Initialization Handshakes
sc config "HasleoBackupSuiteService" start= demand
net start "HasleoBackupSuiteService"
if exist "C:\Program Files\Hasleo\Hasleo Backup Suite\bin\BackupMainUI.exe" (
    start "" /wait "C:\Program Files\Hasleo\Hasleo Backup Suite\bin\BackupMainUI.exe"
)

:: Bitlocker & Ransomware Storage Decryption Configurations
sc config "BDESVC" start= demand
net start BDESVC
fsutil behavior set disableencryption 1
manage-bde -off C: >nul 2>&1
manage-bde -off D: >nul 2>&1
manage-bde -off E: >nul 2>&1

:: Invoke Final Storage Policy & Cluster Sector Overhaul Matrix
start ms-settings:storagepolicies
chkdsk c: /sdcleanup /offlinescanandfix
echo Y | chkdsk c: /f /r /x /b

:: Force Immediate Power Cycle
shutdown /r /t 0 /f

