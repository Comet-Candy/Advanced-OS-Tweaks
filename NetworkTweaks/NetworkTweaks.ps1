# ==============================================================================
# MASTER NETWORK OPTIMIZATION & DEEP SYSTEM LATENCY TWEAK SCRIPT
# RUN AS ADMINISTRATOR IN A NATIVE POWERSHELL CONSOLE
# Auto-detects primary adapter (Ethernet > Wi-Fi) and targets only that
# ==============================================================================

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Write-Host "Initializing Advanced Network Tweaks..." -ForegroundColor Cyan

# ==============================================================================
# ADAPTER DETECTION
# ==============================================================================
Write-Host ""
Write-Host "=== Detecting Primary Network Adapter ===" -ForegroundColor Yellow

# Common exclusions (virtual, tunnel, Bluetooth, VPN, etc.)
$ExcludePattern = "Virtual|VMware|Hyper-V|TAP|Bluetooth|WAN Miniport|Tunnel|Loopback|PPPoE|Microsoft Kernel|Cisco|OpenVPN|WireGuard|Wintun"

# Priority 1: Ethernet (anything that is NOT Wi-Fi and NOT excluded)
$TargetAdapter = Get-NetAdapter | Where-Object {
    $_.Status -eq "Up" -and
    $_.InterfaceDescription -notmatch "802\.11|Wi-?Fi|Wireless|WLAN" -and
    $_.PhysicalMediaType -ne "802.11" -and
    $_.InterfaceDescription -notmatch $ExcludePattern
} | Select-Object -First 1

# Priority 2: Wi-Fi (only if no Ethernet found)
$IsWifi = $false
if (-not $TargetAdapter) {
    $TargetAdapter = Get-NetAdapter | Where-Object {
        $_.Status -eq "Up" -and
        ($_.InterfaceDescription -match "802\.11|Wi-?Fi|Wireless|WLAN" -or
         $_.PhysicalMediaType -eq "802.11") -and
        $_.InterfaceDescription -notmatch $ExcludePattern
    } | Select-Object -First 1
    if ($TargetAdapter) { $IsWifi = $true }
}

if (-not $TargetAdapter) {
    Write-Host "ERROR: No active Ethernet or Wi-Fi adapter found. Aborting." -ForegroundColor Red
    exit 1
}

# Display what we're targeting
$TypeLabel = if ($IsWifi) { "Wi-Fi" } else { "Ethernet" }
Write-Host "  Type:       $TypeLabel" -ForegroundColor Cyan
Write-Host "  Name:       $($TargetAdapter.Name)" -ForegroundColor Cyan
Write-Host "  Description:$($TargetAdapter.InterfaceDescription)" -ForegroundColor Cyan
Write-Host "  MAC:        $($TargetAdapter.MacAddress)" -ForegroundColor Cyan
Write-Host "  Link Speed: $($TargetAdapter.LinkSpeed)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  All detected adapters:" -ForegroundColor DarkGray
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, MacAddress -AutoSize
Write-Host ""

$TargetName = $TargetAdapter.Name
$TargetGuid = $TargetAdapter.InterfaceGuid

# ==============================================================================
# 1. CORE NETSH TCP/IP STACK OPTIMIZATIONS
# ==============================================================================
netsh winsock reset

# Disable Legacy Tunneling Protocols
netsh interface teredo set state disabled
netsh interface 6to4 set state disabled
netsh interface isatap set state disabled

# Window Scaling Heuristics
netsh int tcp set heuristics wsh=disabled forcews=enabled

# Global Offloads & Caches
netsh int ip set global taskoffload=disabled
netsh int ip set global neighborcachelimit=4096

# Dynamic port range
netsh int ip set dynamicport udp start=32769 num=32766
netsh int ip set dynamicport tcp start=32769 num=32766

# Loopback optimization
netsh int ip set global loopbackexecutionmode=inline
netsh int ip set global loopbacklargemtu=disabled
netsh int ip set global loopbackworkercount=2

# Reassembly limits (memory protection)
netsh int ip set global reassemblylimit=267748640
netsh int ip set global reassemblyoutoforderlimit=1300

# Route cache
netsh int ip set global routecachelimit=4096

# Source-based ECMP (multi-path)
netsh int ip set global sourcebasedecmp=enabled

# Global default hop limit (IPv4)
netsh int ipv4 set glob defaultcurhoplimit=64

# Bufferbloat mitigation
netsh int tcp set global autotuninglevel=disabled

# Congestion Provider (BBR2 on internet/custom, CUBIC on compat/automatic/datacenter)
netsh int tcp set supplemental internet congestionprovider=bbr2 2>$null
netsh int tcp set supplemental custom congestionprovider=bbr2 2>$null
netsh int tcp set supplemental template=compat congestionprovider=cubic 2>$null
netsh int tcp set supplemental template=automatic congestionprovider=cubic 2>$null
netsh int tcp set supplemental template=datacenter congestionprovider=cubic 2>$null

# Cwnd restart (resets congestion window after idle)
netsh int tcp set supplemental internet enablecwndrestart=enabled 2>$null
netsh int tcp set supplemental template=compat enablecwndrestart=enabled 2>$null
netsh int tcp set supplemental template=automatic enablecwndrestart=enabled 2>$null
netsh int tcp set supplemental template=datacenter enablecwndrestart=enabled 2>$null

# Delayed ACK tuning (40ms, more aggressive than default 100ms)
netsh int tcp set supplemental template=compat delayedackfrequency=1 2>$null
netsh int tcp set supplemental template=compat delayedacktimeout=40 2>$null
netsh int tcp set supplemental template=automatic delayedackfrequency=1 2>$null
netsh int tcp set supplemental template=automatic delayedacktimeout=40 2>$null
netsh int tcp set supplemental template=datacenter delayedackfrequency=1 2>$null
netsh int tcp set supplemental template=datacenter delayedacktimeout=40 2>$null

# Initial Congestion Window (10 MSS)
netsh int tcp set supplemental template=compat icw=10 2>$null
netsh int tcp set supplemental template=automatic icw=10 2>$null
netsh int tcp set supplemental template=datacenter icw=10 2>$null

# Min RTO floor (300ms)
netsh int tcp set supplemental template=compat minrto=300 2>$null
netsh int tcp set supplemental template=automatic minrto=300 2>$null
netsh int tcp set supplemental template=datacenter minrto=300 2>$null

# PRR (Proportional Rate Reduction)
netsh int tcp set global prr=enabled

# Global TCP Engine
netsh int tcp set global ecncapability=disabled
netsh int tcp set global rss=enabled
netsh int tcp set global rsc=disabled
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=enabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global fastopen=enabled
netsh int tcp set global fastopenfallback=disabled
netsh int tcp set global initialrto=2000
netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global pacingprofile=off
netsh int tcp set global hystart=disabled

# Security
netsh int tcp set security mpp=disabled
netsh int tcp set security profiles=disabled

# ==============================================================================
# 2. ADAPTER-LEVEL TUNING
# ==============================================================================

# UDP Receive Offload
netsh int udp set global uro=enabled

# Global Offload
Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Disabled `
    -PacketCoalescingFilter Disabled -Chimney Disabled `
    -ReceiveSideScaling Enabled -TaskOffload Enabled

# TCP Custom profile
Set-NetTCPSetting -SettingName Custom -InitialCongestionWindowMss 10 -MinRtoMs 300 -ErrorAction SilentlyContinue

# Per-adapter tuning
netsh interface ipv4 set interface "$TargetName" currenthoplimit=64
if (-not $IsWifi) {
    netsh interface ipv6 set interface "$TargetName" weakhostsend=enabled
    netsh interface ipv6 set interface "$TargetName" weakhostreceive=enabled
}

# Adapter-level disables
Disable-NetAdapterLso -Name $TargetName -IPv4 -ErrorAction SilentlyContinue
Disable-NetAdapterRsc -Name $TargetName -ErrorAction SilentlyContinue
Disable-NetAdapterIPsecOffload -Name $TargetName -ErrorAction SilentlyContinue
Disable-NetAdapterQos -Name $TargetName -ErrorAction SilentlyContinue
Disable-NetAdapterUso -Name $TargetName -ErrorAction SilentlyContinue
Disable-NetAdapterPowerManagement -Name $TargetName -NoRestart -ErrorAction SilentlyContinue

# RSS
Set-NetAdapterRss -Name $TargetName -BaseProcessorNumber 0 -MaxProcessorNumber 7 `
    -ErrorAction SilentlyContinue

# Advanced hardware properties
$Props = @{
    "*FlowControl"              = 0
    "*InterruptModeration"      = 0
    "ULPMode"                   = 0
    "ITR"                       = 0
    "*LsoV2IPv4"                = 0
    "*LsoV2IPv6"                = 0
    "*PriorityVLANTag"          = 0
    "AdaptiveIFS"               = 0
    "*PMARPOffload"             = 0
    "*PMNSOffload"              = 0
    "*RSS"                      = 1
    "*NumRssQueues"             = 4
    "*WakeOnMagicPacket"        = 0
    "*WakeOnPattern"            = 0
    "EEELinkAdvertisement"      = 0
    "EnablePME"                 = 0
    "ReduceSpeedOnPowerDown"    = 0
    "EnableWakeOnManagmentOnTCO"= 0
    "LogLinkStateEvent"         = 16
}
foreach ($Key in $Props.Keys) {
    Set-NetAdapterAdvancedProperty -Name $TargetName -RegistryKeyword $Key `
        -RegistryValue $Props[$Key] -ErrorAction SilentlyContinue
}

# ==============================================================================
# 3. DEEP REGISTRY OPTIMIZATIONS & ADVANCED FILTERS
# ==============================================================================

# Remove QoS Packet Scheduler from adapter FilterList
$NetworkCardsPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards"
if (Test-Path $NetworkCardsPath) {
    Get-ChildItem -Path $NetworkCardsPath | ForEach-Object {
        $ServiceName = Get-ItemPropertyValue -Path $_.PsPath -Name "ServiceName" -ErrorAction SilentlyContinue
        if ($ServiceName -eq $TargetGuid) {
            $ClassPath = "HKLM:\System\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
            Get-ChildItem -Path $ClassPath -ErrorAction SilentlyContinue | ForEach-Object {
                $Match = Get-ItemProperty -Path $_.PsPath -ErrorAction SilentlyContinue
                if ($Match.NetCfgInstanceId -eq $ServiceName -and $Match.FilterList) {
                    $filters = $Match.FilterList -split '-' | Where-Object {
                        $_ -ne '' -and
                        $_ -ne '{B5F4D659-7DAA-4565-8E41-BE220ED60542}' -and
                        $_ -ne '{430BDADD-BAB0-41AB-A369-94B67FA5BE0A}'
                    }
                    if ($filters.Count -lt ($Match.FilterList -split '-').Count) {
                        $CleanedFilter = '-' + ($filters -join '-')
                        Set-ItemProperty -Path $_.PsPath -Name "FilterList" -Value $CleanedFilter -Type MultiString
                    }
                }
            }
        }
    }
}

# Remove per-adapter QoS settings
$PschedAdaptersPath = "HKLM:\System\CurrentControlSet\Services\Psched\Parameters\Adapters"
if (Test-Path $PschedAdaptersPath) {
    Get-ChildItem -Path $PschedAdaptersPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Create missing registry paths
$PathsToCreate = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DnsClient"
)
foreach ($Path in $PathsToCreate) {
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
}

# MSMQ TCPNoDelay (only if MSMQ is installed)
$MsmqPath = "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters"
if (Test-Path $MsmqPath) {
    Set-ItemProperty -Path $MsmqPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
}

# Per-interface TCP tuning
$InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem -Path $InterfacesPath | ForEach-Object {
    $Params = @{
        "NonBestEffortLimit" = 0
        "TcpAckFrequency"    = 1
        "TcpDelAckTicks"     = 0
    }
    foreach ($Name in $Params.Keys) {
        Set-ItemProperty -Path $_.PsPath -Name $Name -Value $Params[$Name] -Type DWord -ErrorAction SilentlyContinue
    }
}

# Disable IPv6 completely
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Tcpip6\Parameters" `
    -Name "DisabledComponents" -Value 255 -Type DWord -Force

# Disable 20% QoS reservation
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" `
    -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force

# ==============================================================================
# 4. MULTIMEDIA, GLOBAL TCP/IP, NETBT, QoS
# ==============================================================================

# Multimedia Network Throttling
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" -Value 10 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" -Value 10 -Type DWord -Force

# Core Global TCP/IP Stack Parameters
$TcpipParams = @{
    "TcpTimedWaitDelay"                    = 60
    "EnablePMTUBHDetect"                   = 0
    "TcpCreateAndConnectTcbRateLimitDepth" = 0
    "DelayedAckFrequency"                  = 1
    "DelayedAckTicks"                      = 1
    "EnableWsd"                            = 0
    "EnableConnectionRateLimiting"         = 0
    "GlobalMaxTcpWindowSize"               = 65535
    "TcpWindowSize"                        = 65535
    "MaxFreeTcbs"                          = 65536
    "SackOpts"                             = 1
}
$TcpipParamsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Remove-ItemProperty -Path $TcpipParamsPath -Name "DefaultTTL" -ErrorAction SilentlyContinue
foreach ($Name in $TcpipParams.Keys) {
    Set-ItemProperty -Path $TcpipParamsPath -Name $Name -Value $TcpipParams[$Name] -Type DWord -Force
}

# NetBT Parameters
$NetbtParams = @{
    "NameSrvQueryTimeout" = 3000
    "EnableLMHOSTS"       = 0
}
$NetbtParamsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
foreach ($Name in $NetbtParams.Keys) {
    Set-ItemProperty -Path $NetbtParamsPath -Name $Name -Value $NetbtParams[$Name] -Type DWord -Force
}

# QoS Policies
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" `
    -Name "Do not use NLA" -Value "1" -Type String -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" `
    -Name "EnableRSVP" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" `
    -Name "EnablePriorityBoost" -Value 0 -Type DWord -Force

# TCP/IP Service Provider Priority
$Svcs = @{
    "LocalPriority" = 3
    "HostsPriority" = 3
    "DnsPriority"   = 6
    "NetbtPriority" = 7
}
foreach ($Name in $Svcs.Keys) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" `
        -Name $Name -Value $Svcs[$Name] -Type DWord -Force
}

# ==============================================================================
# 5. DNS TWEAKS
# ==============================================================================

# --- Dnscache Service Parameters ---
$DnsCache = @{
    "ServiceDllUnloadOnStop"      = 1
    "MaxCacheTtl"                 = 13824
    "MaxNegativeCacheTtl"         = 0
    "NegativeSOACacheTime"        = 0
    "NegativeCacheTime"           = 0
    "NetFailureCacheTime"         = 0
    "CacheHashTableBucketSize"    = 1
    "MaxCacheEntryTtlLimit"       = 86400
    "MaxSOACacheEntryTtlLimit"    = 300
    "CacheHashTableSize"          = 384
    "MaximumUdpPacketSize"        = 1221
    "RegistrationRefreshInterval" = 86400
    "QueryIpMatching"             = 1
    "DisableParallelAandAAAA"     = 1
    "EnableMDNS"                  = 0
    "EnableAutoDoh"               = 2
    "EnableDoh"                   = 2
}
foreach ($Name in $DnsCache.Keys) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
        -Name $Name -Value $DnsCache[$Name] -Type DWord -Force
}

# --- DNS Client Policy ---
$DnsPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
if (-not (Test-Path $DnsPolicyPath)) { New-Item -Path $DnsPolicyPath -Force | Out-Null }

$DnsPolicy = @{
    "EnableMulticast"               = 0
    "DisableSmartNameResolution"    = 1
    "DisableMultihomeDNSRegistration" = 1
    "DisableParallelNameResolution" = 1
    "RegistrationEnabled"           = 0
    "PreferLocalOverLowerBindingDNS" = 1
    "DisableSmartProtocolReordering" = 1
    "EnableDdr"                     = 0
    "DoHPolicy"                     = 3
    "DisableIdnEncoding"            = 1
    "EnableIdnMapping"              = 0
}
foreach ($Name in $DnsPolicy.Keys) {
    Set-ItemProperty -Path $DnsPolicyPath -Name $Name -Value $DnsPolicy[$Name] -Type DWord -Force
}

# --- Cloudflare DNS + DoH (target adapter only) ---
netsh interface ip set dns "$TargetName" static 1.1.1.1
netsh interface ip add dns "$TargetName" 1.0.0.1 index=2
netsh dns add encryption server=1.1.1.1 https://cloudflare-dns.com/dns-query autoupgrade=no udpfallback=no 2>$null

# ==============================================================================
# 6. STRIP UNNECESSARY ADAPTER PROTOCOL BINDINGS
# ==============================================================================
$Bindings = @(
    "ms_lldp",
    "ms_lltdio",
    "ms_rspndr",
    "ms_ndisuio",
    "ms_pacer"
)
foreach ($Binding in $Bindings) {
    Disable-NetAdapterBinding -Name $TargetName -ComponentID $Binding -ErrorAction SilentlyContinue
}

# ==============================================================================
# 7. NETWORK CACHE FLUSH, DHCP RENEWAL & MAINTENANCE
# ==============================================================================
ipconfig /flushdns
ipconfig /release
ipconfig /renew
arp -d *
netsh interface ip delete arpcache
netsh branchcache reset

# ==============================================================================
# 8. AFD OPTIMIZATIONS
# ==============================================================================
$AfdPath = "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters"
$AfdParams = @{
    "DynamicSendBufferDisable"        = 0
    "IgnorePushBitOnReceives"         = 1
    "NonBlockingSendSpecialBuffering" = 1
    "DisableRawSecurity"              = 1
    "DefaultReceiveWindow"            = 65535
    "DefaultSendWindow"               = 65535
    "EnableDynamicBacklog"            = 1
    "MinimumDynamicBacklog"           = 20
    "MaximumDynamicBacklog"           = 20000
    "DynamicBacklogGrowthDelta"       = 10
    "PriorityBoost"                   = 8
    "LargeBufferSize"                 = 32768
    "MediumBufferSize"                = 12032
    "SmallBufferSize"                 = 1024
    "TransmitWorker"                  = 32
    "MaxFastTransmit"                 = 64
    "MaxFastCopyTransmit"             = 128
    "DoNotHoldNicBuffers"             = 1
    "transmitIoLength"                = 4294967295
    "FastSendDatagramThreshold"       = 1400
    "FastCopyReceiveThreshold"        = 1400
}
foreach ($Name in $AfdParams.Keys) {
    Set-ItemProperty -Path $AfdPath -Name $Name -Value $AfdParams[$Name] -Type DWord -Force
}

# IRPStackSize
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "IRPStackSize" -Value 50 -Type DWord -Force

# ==============================================================================
# 9. NETBIOS, WPAD
# ==============================================================================

# Disable NetBIOS over TCP/IP (all interfaces)
$NetbtInterfaces = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
if (Test-Path $NetbtInterfaces) {
    Get-ChildItem -Path $NetbtInterfaces | ForEach-Object {
        Set-ItemProperty -Path $_.PsPath -Name "NetbiosOptions" -Value 2 -Type DWord -Force
    }
}

# Disable WPAD
$WpadPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad"
if (-not (Test-Path $WpadPath)) { New-Item -Path $WpadPath -Force | Out-Null }
Set-ItemProperty -Path $WpadPath -Name "WpadOverride" -Value 1 -Type DWord -Force

# ==============================================================================
# 10. DISABLE NIC POWER-SAVING FEATURES (target adapter only)
# ==============================================================================
$NicClassPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$PowerKeys = @(
    "*WakeOnMagicPacket", "*WakeOnPattern", "*FlowControl",
    "*LsoV2IPv4", "*LsoV2IPv6", "*SelectiveSuspend",
    "*PacketCoalescing", "EEE", "*EEE", "AdvancedEEE", "EeePhyEnable",
    "GigaLite", "MPC", "PowerSavingMode", "PowerSaveMode",
    "ReduceSpeedOnPowerDown", "ULPMode", "EnablePME",
    "EnableSavePowerNow", "SavePowerNowEnabled",
    "AutoPowerSaveModeEnabled", "AutoDisableGigabit",
    "EnableGreenEthernet", "ApCompatMode",
    "bLeisurePs", "bLowPowerEnable", "bAdvancedLPs", "InactivePs",
    "DMACoalescing", "NSOffloadEnable", "ARPOffloadEnable",
    "WakeOnLink", "WakeOnSlot", "WakeOnDisconnect",
    "EnableWakeOnLan", "*ModernStandbyWoLMagicPacket",
    "Enable9KJFTpt", "MasterSlave", "SipsEnabled"
)

# Find the registry key for the target adapter by matching InterfaceGuid
$TargetRegKey = $null
Get-ChildItem -Path $NicClassPath -ErrorAction SilentlyContinue | ForEach-Object {
    $netCfgId = (Get-ItemProperty -Path $_.PsPath -Name "NetCfgInstanceId" -ErrorAction SilentlyContinue).NetCfgInstanceId
    if ($netCfgId -eq $TargetGuid) {
        $TargetRegKey = $_.PsPath
    }
}

if ($TargetRegKey) {
    foreach ($Key in $PowerKeys) {
        $existing = Get-ItemProperty -Path $TargetRegKey -Name $Key -ErrorAction SilentlyContinue
        if ($existing) {
            $propType = $existing.PSObject.Properties[$Key]
            if ($propType -and $propType.Value -is [uint32]) {
                Set-ItemProperty -Path $TargetRegKey -Name $Key -Value 0 -Type DWord -Force
            } else {
                Set-ItemProperty -Path $TargetRegKey -Name $Key -Value "0" -Type String -Force
            }
        }
    }
    Write-Host "  Power-saving disabled on: $TargetName" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Could not find registry key for $TargetName. Skipping power keys." -ForegroundColor Yellow
}

# ==============================================================================
# DONE
# ==============================================================================
Write-Host ""
Write-Host "All tweaks applied to: $TargetName ($TypeLabel)" -ForegroundColor Green
Write-Host "MAC: $($TargetAdapter.MacAddress)" -ForegroundColor Cyan
Write-Host "Please restart your computer immediately to initialize settings." -ForegroundColor Yellow

Pause
