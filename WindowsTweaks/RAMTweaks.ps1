<# :
@echo off
:: Automatically request Administrator permission and bypass script execution restrictions
net session >nul 2>&1 || (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "IEX ([System.IO.File]::ReadAllText('%~f0'))"
exit /b
#>

# 1. Key Registry Path Mappings
$c  = 'HKLM:\SYSTEM\CurrentControlSet\Control'
$sm = "$c\Session Manager"; $mm = "$sm\Memory Management"; $k = "$sm\kernel"
$dg = "$c\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
$d  = 'HKLM:\SOFTWARE\Microsoft\DirectX'; $pf = "$mm\PrefetchParameters"
$sp = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'

function s($path, $name, $value, $type='Dword') {
    if (!(Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Value $value -Type $type -ErrorAction SilentlyContinue
}

# 2. Interactive RAM Target Profile Setup
Clear-Host
Write-Host "===================================================================="
Write-Host "             SELECT YOUR PHYSICAL RAM CAPACITY                      "
Write-Host "===================================================================="
Write-Host "`n  1: 4GB  |  2: 8GB  |  3: 16GB  |  4: 32GB  |  5: 48GB  |  6: 64GB  |  7: Skip`n"

$ch = Read-Host "Enter option number (1-7)"
$sv = 4294967295; $pfSize = 0

switch ($ch) {
    1 { s $mm IoPageLockLimit 1048576;  s $mm CacheUnmapBehindLengthInMB 256;  s $mm ModifiedWriteMaximum 32;  $sv=400000;  $pfSize=4096 }
    2 { s $mm IoPageLockLimit 2097152;  s $mm CacheUnmapBehindLengthInMB 512;  s $mm ModifiedWriteMaximum 64;  $sv=800000;  $pfSize=8192 }
    3 { s $mm IoPageLockLimit 4194304;  s $mm CacheUnmapBehindLengthInMB 1024; s $mm ModifiedWriteMaximum 128; $sv=1000000; $pfSize=16384 }
    4 { s $mm IoPageLockLimit 8388608;  s $mm CacheUnmapBehindLengthInMB 2048; s $mm ModifiedWriteMaximum 352; $sv=2000000; $pfSize=32768 }
    5 { s $mm IoPageLockLimit 9437184;  s $mm CacheUnmapBehindLengthInMB 4608; s $mm ModifiedWriteMaximum 576; $sv=3000000; $pfSize=49152 }
    6 { s $mm IoPageLockLimit 16777216; s $mm CacheUnmapBehindLengthInMB 5632; s $mm ModifiedWriteMaximum 800; $sv=4000000; $pfSize=65536 }
}

# 3. Virtual Memory Static Pagefile Allocation
if ($pfSize -gt 0) {
    Write-Host "[*] Configuring stable 1:1 Static Pagefile space ($pfSize MB)..."
    $csObj = Get-CimInstance -ClassName Win32_ComputerSystem -EA 0
    if ($csObj.AutomaticManagedPagefile) { Set-CimInstance -InputObject $csObj -Property @{AutomaticManagedPagefile=$False} -EA 0 }
    $pfsObj = Get-CimInstance -ClassName Win32_PageFileSetting -EA 0 | Where-Object {$_.Name -like "*pagefile.sys"}
    if ($pfsObj) { Set-CimInstance -InputObject $pfsObj -Property @{InitialSize=$pfSize; MaximumSize=$pfSize} -EA 0 }
    else { New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name="C:\pagefile.sys"; InitialSize=$pfSize; MaximumSize=$pfSize} -EA 0 }
}

Write-Host "`n[*] Processing engine optimization matrices..."
s $c SvcHostSplitThresholdInKB $sv; s $c CriticalSystemProcessesBoost 1; s $c PriorityControl 38; s $c EnableAutostartEvents 0; s $dg Enabled 0
Remove-ItemProperty -Path $mm -Name AllocationPreference,UnusedFileCache -ErrorAction SilentlyContinue

# 4. Dense Looped Registry Injections
$map = [ordered]@{
    $mm = @{ 'DisableWriteBehind'=1;'PoolTag'=0;'StoreDirtyPages'=0;'BoostCriticalThreads'=1;'ClearPageFileAtShutdown'=0;'CrashDumpEnabled'=0;'CriticalThreadPriority'=1;'DedicatedGameCache'=1;'DisableCacheTelemetry'=1;'DisableCHPE'=1;'DisableDynamicMemoryAllocation'=1;'DisableKernelPaging'=1;'DisableOptimisticNUMA'=0;'DisablePageCombining'=1;'DisablePagingCombining'=1;'DisableRegistryPaging'=1;'DontVerifyRandomDrivers'=0;'DynamicMemory'=1;'EnableCompression'=0;'EnableCooling'=0;'EnableHighPrecisionClockSync'=1;'EnableHyperThreadingOptimization'=0;'EnableLogFile'=0;'EnableLookasideLists'=1;'EnableLowVaAccess'=1;'EnableNUMA'=1;'EnablePerVolumeLazyWriter'=2;'EnableSegmentHeap'=0;'EnergyDriverPolicyVideo'=1;'EnforceWriteProtection'=0;'FirstLevelDataCache'=32;'ForceSingleCoreAffinityForCriticalThreads'=1;'LargePageMinimum'=1048576;'LargeSystemCache'=1;'MakeLowMemory'=1;'MapAllocationFragment'=131072;'PagedPoolSize'=4294967295;'PoolUsageMaximum'=96;'PreferExternalManifest'=1;'ProcessPrePage'=1;'RegistryProcessMemoryOptimization'=1;'SchedulerQuantum'=1;'SecondLevelDataCache'=512;'SegmentHeap'=0;'SessionImageSize'=16;'SessionPoolSize'=0;'SessionSpaceLimit'=0;'SessionViewSize'=0;'SnapUnloads'=1;'SystemCacheDirtyPageThreshold'=128;'SystemPages'=4294967295;'ThirdLevelDataCache'=98304;'ThreadSchedulingMode'=1;'ThreadSchedulingModel'=1;'TimerBResolution'=1;'TimerMinResolution'=1;'NUMA'=1 }
    $sm = @{ 'Debugger Retries'=0;'AllowProtectedRenames'=1;'AlpcMessageLog'=0;'AlpcWakePolicy'=1;'AutoChkTimeout'=10;'BackgroundLoadKnownDlls'=1;'BootExecuteNoPnpSync'=1;'CWDIllegalInDllSearch'=2;'DisablePagingExecutive'=0;'DisableWpbtExecution'=1;'EnableDeadGwdTimers'=1;'HeapDeCommitFreeBlockThreshold'=8192;'HeapDeCommitTotalFreeThreshold'=131072;'HeapSegmentCommit'=16384;'HeapSegmentReserve'=2097152;'NumaAware'=1;'TaskhostTimeout'=2000 }
    "$sm\Segment Heap" = @{ 'Enabled'=0;'HeapSegmentReserve'=2097152;'HeapSegmentCommit'=16384;'HeapDeCommitTotalFreeThreshold'=131072;'HeapDeCommitFreeBlockThreshold'=8192;'OverrideServerSKU'=1 }
    "$sm\SubSystems" = @{ 'HeapDeCommitFreeBlockThreshold'=8192;'HeapDeCommitTotalFreeThreshold'=131072 }
    $k  = @{ 'ObjectSecurityInheritance'=0;'RequireDeviceAccessCheck'=0;'DisableHvci'=1;'DisableAcg'=1;'DisableArbitraryCodeGuard'=1;'DisableCfg'=1;'DisableRop'=1;'DisableShadowStacks'=1;'DisableCetShadowStacks'=1;'DisableUserCet'=1;'DisableKernelCet'=1;'DisableMemoryProtection'=1;'DisableKernelAslr'=1;'KernelTopologyOptimization'=1;'AdditionalClockTicksInProcessor'=2576980377;'AdjustDpcThreshold'=1;'AmdTprLowerInterruptDelayConfig'=1;'BoostingPeriodMultiplier'=3;'BufferSize'=32;'CacheAwareScheduling'=47;'Capabilities'=272;'ClockOwner'=1;'ClockRate'=1;'Clock_Rate'=1;'ClockTimerAlwaysOnPresent'=1;'ClockTimerPerCpu'=1;'ClockTimerResolution'=1;'CoalescingTimerDisabled'=1;'CpuRelaxedSpeculation'=1;'CyclesPerClockQuantum'=1;'DefaultDynamicHeteroCpuPolicy'=3;'DefaultHeteroCpuPolicy'=5;'DelayCloseSize'=1;'DelayDerefKCBLimit'=1;'DeviceOwnerProtectionDowngradeAllowed'=0;'DisableAutoBoost'=1;'DisableBufferedIoInit'=1;'DisableCoalescing'=1;'DisableControlFlowGuardExportSuppression'=1;'DisableControlFlowGuardXfg'=1;'DisableDynamicTick'=1;'DisableExceptionChainValidation'=1;'DisableIdleInhibitor'=1;'DisableIFEOCaching'=1;'DisableLightWeightSuspend'=1;'DisableOverlappedExecution'=32;'DisablePrefetcher'=1;'DisableSystemPTEWriteBack'=1;'DisableThreadBoost'=1;'DisableThreadPreemption'=1;'DisableTsx'=1;'DistributeTimers'=1;'DpcDuration'=1;'DpcLastCount'=1000;'DpcQueueDepth'=1;'DpcRequestRate'=2576980377;'DpcTimeCount'=10;'DpcWatchdogThreshold'=2147483647;'DpcWatchdogTimeout'=4294967295;'DriveRemappingMitigation'=0;'DynamicDpcProtocol'=1;'DynamicHeteroCpuPolicyExpectedRuntime'=5200;'DynamicHeteroCpuPolicyImportant'=2;'DynamicHeteroCpuPolicyImportantPriority'=8;'DynamicHeteroCpuPolicyImportantShort'=3;'DynamicHeteroCpuPolicyMask'=7;'DynamicTickDisable'=1;'EnableControlFlowGuardExportSuppression'=1;'EnableFsCacheHost'=1;'EnableLowLatencyIo'=1;'EnableLowMemoryKiller'=1;'EnablePerCpuClockTickScheduling'=1;'EnableUserModeCache'=1;'EnableUserReporting'=1;'EnergyDriverPolicy'=1;'EnergyDriverPolicyVideo'=1;'ExQueueWorkItem'=32;'ExTryQueueWorkItem'=32;'ForceApicPhysicalDestinationMode'=1 }
    $pf = @{ 'EnableBootTrace'=0;'EnablePrefetch'=0;'EnablePrefetcher'=0;'EnableSuperfetch'=0;'EnableSuperfetcher'=0;'FIPrefetchDelayMs'=0;'SfTracingState'=0 }
    $d  = @{ 'AllowNvidiaDecoder'=1;'D3D11_ALLOW_TILING'=1;'D3D11_DEFERRED_CONTEXTS'=1;'D3D11_ENABLE_DYNAMIC_CODEGEN'=1;'D3D11_MULTITHREADED'=1;'D3D12_ALLOW_TILING'=1;'D3D12_CPU_PAGE_TABLE_ENABLED'=1;'D3D12_DEFERRED_CONTEXTS'=1;'D3D12_ENABLE_RUNTIME_DRIVER_OPTIMIZATIONS'=1;'D3D12_ENABLE_UNSAFE_COMMAND_BUFFER_REUSE'=1;'D3D12_HEAP_SERIALIZATION_ENABLED'=1;'D3D12_MAP_HEAP_ALLOCATIONS'=1;'D3D12_MULTITHREADED'=1;'D3D12_RESIDENCY_MANAGEMENT_ENABLED'=1;'D3D12_RESOURCE_ALIGNMENT'=1;'DisableHWOverlay'=1;'DisableNV12'=0;'FlipModelForceEnabled'=1;'FlipQueueLowLatency'=1;'ForceGPUPreemption'=1;'MaxFrameLatency'=1;'MaxQueuedFrames'=1;'PreferExternalManifest'=1;'ShaderCache'=1;'DisableFullscreenOptimizations'=1 }
    $sp = @{ 'AllowTearing'=1;'AlwaysOn'=0;'AlwaysUseDirectFlip'=1;'GPU Priority'=8;'IdleDetectionCycles'=1;'LazyModeTimeout'=1000000;'MaxThreadsPerProcess'=32;'MaxThreadsTotal'=65535;'NetworkThrottlingIndex'=10;'NoLazyMode'=1;'SchedulerPeriod'=50000;'SchedulerTimerResolution'=10000;'SystemResponsiveness'=10;'TimerResolution'=1;'LatencySensitive'=1;'ThreadPriority'=4 }
}

foreach ($target in $map.Keys) {
    foreach ($key in $map[$target].Keys) { s $target $key $map[$target][$key] }
}

# 5. Fixed Binary Keys & Finalizations
s $k EAFModules ' ' String
s $k SystemMitigationOptions ([byte[]](0x22)*24) Binary
s $k SystemMitigationAuditOptions ([byte[]](0x00)*16) Binary
s $k KernelMitigationOptions ([byte[]](0x22)*24) Binary
s $k ZeroDelay ([byte[]](0x11)*32) Binary
s $sp 'Scheduling Category' 'High' String

# Fixed Line 80 Typo
Remove-ItemProperty -Path $d -Name Direct3D -ErrorAction SilentlyContinue

Disable-MMAgent -MemoryCompression -EA 0; Disable-MMAgent -PageCombining -EA 0
Write-Host "`n[SUCCESS] Custom optimization matrix deployed smoothly!" -ForegroundColor Green
Read-Host "Press Enter to exit"
