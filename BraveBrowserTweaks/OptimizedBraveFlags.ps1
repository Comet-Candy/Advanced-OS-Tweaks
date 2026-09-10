#Requires -RunAsAdministrator

# =========================================================================
# 0. CLOSE RUNNING BRAVE INSTANCES
# =========================================================================
Write-Host "[*] Stopping active Brave Nightly instances..." -ForegroundColor Yellow

Get-Process -Name "brave" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*Brave-Browser-Nightly*" } | ForEach-Object {
    $_.CloseMainWindow()
}
Start-Sleep -Seconds 2

$BraveProcesses = Get-Process -Name "brave" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*Brave-Browser-Nightly*" }
if ($BraveProcesses) {
    Write-Host "[!] Force terminating lingering background processes..." -ForegroundColor LightYellow
    $BraveProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# =========================================================================
# 1. DEBLOAT BLOCK (FILE-BASED JSON POLICIES)
# =========================================================================
$PolicyDir = "$env:SystemDrive\Etc\BraveSoftware\Brave-Browser\Policies\Managed"
$PolicyFile = "$PolicyDir\ultra_debloat_nightly.json"

If (!(Test-Path $PolicyDir)) {
    New-Item -ItemType Directory -Force -Path $PolicyDir | Out-Null
}

$PolicyJson = @'
{
    # --- STATIC STARTUP ENGINE LOCKS ---
    "RestoreOnStartup": 4,
    "RestoreOnStartupURLs": [
        "https://google.com"
    ],
    "HomepageIsNewTabPage": false,
    "HomepageLocation": "https://google.com",
    "NewTabPageLocation": "https://google.com",
    "ShowHomeButton": true,
    "ShowFullUrlsInAddressBar": true,
    "BookmarkBarEnabled": true,

    # --- FORCED EXTENSION DEPLOYMENT ---
    "ExtensionInstallForcelist": [
        "edibdbjcniadpccecjdfdjjppcpchdlm",
        "mnjggcdmjocbbbhaepdhchncahnbgone",
        "bbeaicapbccfllodepmimpkgecanonai",
        "jaadjnlkjnhohljficgoddcjmndjfdmi",
        "ldpochfccmkkmhdbclfhpagapcfdljkj",
        "lckanjgmijmafbedllaakclkaicjfmnk",
        "mlomiejdfkolichcflejclcbmpeaniij",
        "dejhhgdpambaambdifcfbmpliolehfaj",
        "dbepggeogbaibhgnhhndojpepiihcmeb",
        "infppggnoaenmfagbfknfkancpbljcca",
        "chphlpgkkbolifaimnlloiipkdnihall",
        "bmmcjfagflcghljhclhfbhbdgjgkibam",
        "fdpofaadaohfkbbkcmccjefhegijbfjb",
        "nlipnmloinkkcbpnhkphcpjhachlbdpa"
    ],

    # --- CORE PIPELINE OPERATIONAL RETAINMENT ---
    "BraveAIChatEnabled": true,
    "PasswordManagerEnabled": true,
    "AutofillAddressEnabled": true,
    "AutofillCreditCardEnabled": true,
    "SigninAllowed": true,
    "BrowserSignin": 1,
    "SyncDisabled": false,

    # --- AGGRESSIVE BRAVE DEBLOATING ---
    "BraveRewardsDisabled": true,
    "BraveWalletDisabled": true,
    "BraveVPNDisabled": true,
    "BraveNewsDisabled": true,
    "BraveTalkDisabled": true,
    "TorDisabled": true,
    "IPFSEnabled": false,
    "BraveWaybackMachineEnabled": false,
    "BraveWebDiscoveryEnabled": false,
    "BraveSpeedreaderEnabled": false,
    "BravePlaylistEnabled": false,
    "BraveP3AEnabled": false,

    # --- PERFORMANCE & RESOURCE OPTIMISATIONS ---
    "HardwareAccelerationModeEnabled": true,
    "AudioProcessHighPriorityEnabled": true,
    "DefaultJavaScriptJitSetting": 1,
    "BackgroundModeEnabled": false,
    "ComponentUpdatesEnabled": true,
    "RendererAppContainerEnabled": true,
    "NetworkServiceSandboxEnabled": true,
    "SitePerProcess": true,
    "NetworkPredictionOptions": 2,
    "ProxyServerMode": 0,
    "WindowOcclusionEnabled": false,

    # --- PRIVACY & EXTENSIVE TELEMETRY TERMINATION ---
    "EnableDoNotTrack": true,
    "BlockThirdPartyCookies": true,
    "DnsOverHttpsMode": "secure",
    "DnsOverHttpsTemplates": "https://cloudflare-dns.com",
    "DnsPrefetchingEnabled": false,
    "MetricsReportingEnabled": false,
    "DomainReliabilityAllowed": false,
    "SafeBrowsingEnabled": false,
    "SafeBrowsingProtectionLevel": 0,
    "PrivacySandboxAdTopicsEnabled": false,
    "PrivacySandboxAdMeasurementEnabled": false,
    "PrivacySandboxFledgeEnabled": false,
    "PrivacySandboxPromptEnabled": false,
    "UrlKeyedAnonymizedDataCollectionEnabled": false,
    "UrlKeyedMetricsAllowed": false,
    "WebRtcEventLogCollectionAllowed": false,
    "WebRtcTextLogCollectionAllowed": false,
    "WebRtcIPHandling": "disable_non_proxied_udp",
    "ReportMachineIDData": false,
    "ReportPolicyData": false,
    "ReportUserIDData": false,

    # --- CHROMIUM ARTIFICIAL INTELLIGENCE BLOCKS ---
    "GeminiSettings": 1,
    "GeminiActOnWebSettings": 1,
    "GenAILocalFoundationalModelSettings": 1,
    "GenAIInlineImageSettings": 2,
    "GenAIPhotoEditingSettings": 2,
    "GenAISmartGroupingSettings": 1,
    "GenAIVcBackgroundSettings": 2,
    "GenAIWallpaperSettings": 2,
    "GenAiDefaultSettings": 2,
    "DevToolsGenAiSettings": 2,
    "HelpMeWriteSettings": 2,
    "HelpMeReadSettings": 2,

    # --- UI CLEANUP & FUNCTIONAL SHUTDOWNS ---
    "DefaultNotificationsSetting": 2,
    "AllowDinosaurEasterEgg": false,
    "BrowserGuestModeEnabled": false,
    "BrowserLabsEnabled": false,
    "ChromeForTestingAllowed": false,
    "ClickToCallEnabled": false,
    "DesktopSharingHubEnabled": false,
    "NTPCardsVisible": false,
    "ShoppingListEnabled": false,
    "TranslateEnabled": false,
    "QuickAnswersEnabled": false,
    "SuggestedContentEnabled": false,
    "SpellcheckEnabled": true,
    "SpellCheckServiceEnabled": true,
    "UserFeedbackAllowed": false
}
'@

$PolicyJson | Out-File -FilePath $PolicyFile -Encoding utf8 -Force
Write-Host "[+] Deep Debloat JSON Policy Matrix injected." -ForegroundColor Cyan

# =========================================================================
# 2. ADVANCED PERFORMANCE TUNING AND CHROMIUM ENGINE FLAGS
# =========================================================================
# Enforces the browser to read our custom JSON location and skip the registry completely
$IsolationFlag = "--policy-config-dir=`"$PolicyDir`""

# Privacy Flags: Setup wizard and telemetry block filters
$PrivacyFlags = "--disable-breakpad --no-pings --disable-features=AutofillServerCommunication,BraveAdblockUpdater,TelemetryExtension,ReportPageTasks,DiscoveryFeed,SearchEngineChoiceNotification,DomainReliability"

# Cache and Process Optimisation
$PerformanceFlags = "--disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --process-per-site --disk-cache-size=524288000 --disable-component-cloud-policy --disable-default-apps --enable-parallel-downloading --enable-features=TurnOffStreamingMediaCachingOnBattery"

# Hardware Acceleration, Rasterization and Video Overhauls
$GpuFlags = "--ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy --enable-hardware-overlays --enable-raw-draw --enable-gpu-compositing --gpu-no-context-lost --prerender-from-omnibox=disabled"

# Multi-Threading Frameworks (Vulkan Engine Integration)
$ThreadingFlags = "--enable-drdc --enable-threaded-compositing --num-raster-threads=4 --enable-vulkan --enable-features=CanvasOopRasterization,OopRasterization,SkiaGraphite,GpuMemoryBufferVideoFrames"

# Next-Gen Interface Pipeline Acceleration
$ExtremeFlags = "--enable-features=BackForwardCache,InlineCanvas2DRenderingContext,WebAssemblyTiering,BlinkLifecyclePipelineIntensiveThrottling --disable-frame-rate-limit --enable-video-rasterization --io-thread-always-priority=realtime --enable-aggressive-dom-release"

$AllArguments = "$IsolationFlag $PrivacyFlags $PerformanceFlags $GpuFlags $ThreadingFlags $ExtremeFlags"

# =========================================================================
# 3. OVERWRITE IN-PLACE SHORTCUTS & SYSTEM STARTUP
# =========================================================================
$BraveNightlyPath = "C:\Program Files\BraveSoftware\Brave-Browser-Nightly\Application\brave.exe"
$WorkingDir = "C:\Program Files\BraveSoftware\Brave-Browser-Nightly\Application"

if (Test-Path $BraveNightlyPath) {
    Write-Host "[+] Injecting isolated layout arguments into shortcuts..." -ForegroundColor Green
    $WScriptShell = New-Object -ComObject WScript.Shell

    # Target Pinned Taskbar Shortcut
    $TaskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Brave Nightly.lnk"
    if (Test-Path $TaskbarPath) {
        $Shortcut = $WScriptShell.CreateShortcut($TaskbarPath)
        $Shortcut.TargetPath = $BraveNightlyPath
        $Shortcut.Arguments = $AllArguments
        $Shortcut.WorkingDirectory = $WorkingDir
        $Shortcut.Save()
        Write-Host "[+] System Taskbar link successfully modified." -ForegroundColor Green
    }

    # Target All Desktop Shortcuts
    $DesktopPaths = @(
        "$env:Public\Desktop\Brave Nightly.lnk",
        "$env:USERPROFILE\Desktop\Brave Nightly.lnk"
    )

    foreach ($Path in $DesktopPaths) {
        if (Test-Path $Path) {
            $Shortcut = $WScriptShell.CreateShortcut($Path)
            $Shortcut.TargetPath = $BraveNightlyPath
            $Shortcut.Arguments = $AllArguments
            $Shortcut.WorkingDirectory = $WorkingDir
            $Shortcut.Save()
            Write-Host "[+] Desktop shortcut updated: $Path" -ForegroundColor Green
        }
    }

    # Relaunch isolated instance
    Write-Host "[++] Deployment complete! Launching optimized, file-based Brave Nightly..." -ForegroundColor Green
    Start-Process -FilePath $BraveNightlyPath -ArgumentList $AllArguments
} else {
    Write-Host "[!] Critical Error: Brave Nightly binary not found at $BraveNightlyPath" -ForegroundColor Red
}
