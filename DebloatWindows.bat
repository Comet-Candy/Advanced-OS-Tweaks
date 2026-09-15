@echo off
:: Force Admin elevation and ensure the window stays open on error
if not "%1"=="am_admin" (
    powershell -Command "Start-Process -FilePath '%0' -ArgumentList 'am_admin' -Verb RunAs"
    exit /b
)

echo ===================================================
echo   RUNNING OPTIMIZED DEBLOAT MASTER (ONE-BLOCK)
echo ===================================================

echo [1/5] Starting core services and setting TLS 1.2 network rules...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v "DisabledByDefault" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\DTLS 1.2\Client" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\DTLS 1.2\Client" /v "DisabledByDefault" /t REG_DWORD /d "0" /f >nul 2>&1

for %%S in (UsoSvc wisvc wuauserv BITS TrustedInstaller WaaSMedicSvc InventorySvc DoSvc DiagTrack Appinfo Winmgmt) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%S" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Appinfo" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
sc config winmgmt start= auto >nul 2>&1

for %%S in (UsoSvc wisvc wuauserv BITS TrustedInstaller WaaSMedicSvc cryptsvc InventorySvc DoSvc DiagTrack Appinfo Winmgmt) do (
    net start %%S >nul 2>&1
)
powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart" -ErrorAction SilentlyContinue

echo [2/5] Cleaning standard Store framework packages safely...
powershell -Command "Get-AppxPackage -AllUsers | Where-Object { !$_.NonRemovable -and $_.Name -notlike '*CBS*' -and $_.Name -notlike '*Edge*' -and $_.Name -notlike '*Notepad*' -and $_.Name -notlike '*PowerShell*' -and $_.Name -notlike '*DesktopAppInstaller*' -and $_.Name -notlike '*wmi*' } | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue; Get-AppXProvisionedPackage -Online | Where-Object DisplayName -eq $_.Name | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue }"

echo [3/5] Purging blacklisted consumer Store apps...
powershell -Command "$B = @('People','549981C3','Xbox*','Gaming*','Todos','Zune*','Alarms','Maps','StickyNotes','YourPhone','GetHelp','FeedbackHub','Teams*','Bing*','ScreenSketch','PowerAutomate*','SoundRecorder','Getstarted','Solitaire*','Calculator','Camera','Clipchamp*','OutlookForWindows','DolbyAudio*','OfficeHub','communicationsapps','devhome','3DBuilder','MixedReality*','NetworkSpeedTest','News','OneNote','Sway','OneConnect','Print3D','SkypeApp','Family','QuickAssist','MSPaint','OneDrive','Paint','Whiteboard','Photos','RemoteDesktop','ACGMediaPlayer','Actipro*','PhotoshopExpress','Amazon*','PrimeVideo','Asphalt8*','SketchBook','CaesarsSlots*','COOKINGFEVER','CyberLink*','Disney*','DrawboardPDF','Duolingo*','EclipseManager','Facebook','FarmVille*','fitbit','Flipboard','HiddenCity','HULU*','iHeartRadio','Instagram','LinkedIn*','MarchofEmpires','Netflix','NYTCrossword','OneCalendar','Pandora*','Phototastic*','PicsArt*','Plex','Polarr*','RoyalRevolt*','Shazam','LiveWallpaper','SlingTV','Spotify','TikTok','TuneIn*','Twitter','Viber','WinZip*','Wunderlist','XING','HEVC*','HEIF*','MPEG2*','RawImage*','VP9*','WebMedia*','Webp*','CrossDevice','Widgets*','KillerControlCenter','StartExperiences*','SecureAssessment*','CloudExperience*','PeopleExperience*','NarratorQuickStart','ContentDelivery*','Win32WebViewHost','CredDialogHost','ParentalControls','XGpuEjectDialog'); foreach($t in $B){ Get-AppxPackage -AllUsers * $t * -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue }"

echo [4/5] Removing legacy structural system features and IIS components...
for %%F in (MediaPlayback Microsoft-Windows-Subsystem-Linux MSRDC-Infrastructure Printing-Foundation-Features Printing-Foundation-InternetPrinting-Client Printing-PrintToPDFServices-Features Printing-XPSServices-Features SMB1Protocol SearchEngine-Client-Package WCF-TCP-PortSharing45 Windows-Defender-Default-Definitions WorkFolders-Client NetFx3 LegacyComponents DirectPlay SMB1Protocol-Client SMB1Protocol-Server SimpleTCP Microsoft-RemoteDesktopConnection DirectoryServices-ADAM-Client SmbDirect Recall SNMP WMISnmpProvider Windows-Identity-Foundation RasCMAK RasRip TelnetServer TelnetClient TFTP TIFFIFilter NetFx4-AdvSrvs WCF-Services45 MFaxServicesClientPackage HyperV) do (
    DISM /Online /Disable-Feature /FeatureName:%%F /Remove /NoRestart >nul 2>&1
)

for %%P in (*HVSI* *CodeIntegrity-Diagnostics* *VirtualizationBasedSecurity* *DeviceGuard* *Defender* *RestrictedCodecs* *RemoteDesktopServices* *SMB* *Smb* *Telnet* *TFTP* *WMPNetworkSharing* OpenSSH-Client *Internet-Browser* *EdgeDevTools* *Hyper-V* Client-ProjFS VirtualMachinePlatform HypervisorPlatform Containers *DisposableClientVM* *Network-FlowSteering* *OfflineFile* *NFS* *NetworkDiagnostics* *PeerDist* *MultiPoint* MultiPoint *ClientForNFS* *UtilityVm* *UtilityVM-Containers* *Lxss* *WinOcr* *HgsClient* *Identity-TenantRestrictions* *SearchEngine* WindowsSearchEngineSKU RemoteDesktopServices *RDC* *Remote* *IIS* *CoreSystem-RemoteFS* *msmq* *MSMQ* MSMQ-Driver *COM-MSMQ* *Help* *Internet* *Browser* *CEIPEnable* *FodMetadata* *ErrorReporting* *EnterpriseClientSync* *DiagnosticInfrastructure* DiskIo-QoS *TerminalServices* *MediaPlayback-OC* *SecureAssessment* *WinSATMediaFiles* *FlipGridPWA* *OutlookPWA* *ScreenSavers* *RecoveryDrive* *RecDisc* *ADAM-Tools* *SensorDataService* *NewTabPageHost* *TabShellExperience* *Identity-Foundation* *WinOcr* *Holographic* *Media-Streaming* *Embedded* *EmbeddedExp* *Printing* *WindowsIoT* *ShellExt-Tools* *DeviceUpdateCenter* *DataCenterBridging* *FCI-Client* *Dedup-ChunkLibrary* *AppManagement-UEV* *AppManagement-AppV* *ADAM-Client* *PAW* *ProjFS* *MobilePC-Client-Premium* Server-Help) do (
    DISM /Online /Remove-Package /PackageName:%%P /NoRestart >nul 2>&1
)

echo [5/5] Disabling legacy capabilities and performing final Winget sweeps...
for %%C in (Realtek Vmware InternetExplorer StepsRecorder WindowsPlayer Wallpapers Print MathRecognizer OpenSSH QuickAssist OneSync LA57 Virtual Hello Language.Handwriting Language.OCR Language.Speech Language.TextToSpeech VBSCRIPT Vmxnet3 Extended) do (
    powershell -Command "Get-WindowsCapability -Online | Where-Object Name -like '*%%~C*' | Remove-WindowsCapability -Online" >nul 2>&1
)

DISM /Online /Set-ReservedStorageState /State:Disabled /NoRestart >nul 2>&1

for %%A in ("cortana" "Microsoft.OneDrive" "camera" "help" "photos" "phone" "edge" "windows web experience pack" "Microsoft.Teams.Free" "Microsoft.Teams" "feedback hub" "paint" "WebView2" "LinkedIn" "LinkedInforWindows" "Clipchamp" "Clipchamp.Clipchamp" "Microsoft.Clipchamp" "Microsoft.Clipchamp.Clipchamp" "Microsoft.Windows.Clipchamp" "Microsoft.Windows.Clipchamp.Clipchamp" "Microsoft.Copilot_8wekyb3d8bbwe" "Microsoft.Copilot") do (
    winget uninstall %%A --accept-source-agreements --silent >nul 2>&1
)

echo ---------------------------------------------------
echo Execution complete. REBOOT STRONGLY RECOMMENDED.
pause
