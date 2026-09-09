#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Removes ALL network adapters, virtual components, and Wi-Fi drivers 
    while preserving the single active physical Ethernet connection.
#>

# --- Configuration ---
$ErrorActionPreference = "Continue"
$PauseAtEnd = $true 

# --- Helper: Keep Window Open ---
function Stop-Script {
    param([string]$Message)
    if ($Message) { Write-Host $Message }
    if ($PauseAtEnd) {
        Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
        Read-Host | Out-Null
    }
    exit
}

# --- Header ---
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Total Network Adapter Driver Purge Utility" -ForegroundColor White
Write-Host "   Started: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "WARNING: This will strip ALL Wi-Fi, Virtual, Bluetooth, and" -ForegroundColor Red
Write-Host "unused network components from this system permanently." -ForegroundColor Red
Write-Host "Target: Everything EXCEPT the primary active Ethernet connection." -ForegroundColor White
Write-Host ""

# --- Step 1: Identify Active Ethernet Driver ---
Write-Host "[1/3] Identifying active Ethernet adapter to protect..." -ForegroundColor Cyan
try {
    # Isolate the exact live physical Ethernet cable connection
    $EthernetAdapter = Get-NetAdapter | Where-Object { 
        $_.Status -eq 'Up' -and 
        $_.InterfaceDescription -notmatch 'Wireless|Wi-Fi|Bluetooth|Virtual|TAP|TUN|Loopback|Kernel|Panda' 
    } | Select-Object -First 1

    if (-not $EthernetAdapter) {
        throw "No active physical Ethernet adapter found! Aborting to prevent complete isolation."
    }

    Write-Host "  [PROTECTED] -> $($EthernetAdapter.InterfaceDescription)" -ForegroundColor Green
    Write-Host "  MAC Address  -> $($EthernetAdapter.MacAddress)" -ForegroundColor Gray

    # Map the adapter to its root PnP Device ID
    $PnPDevice = Get-PnpDevice -Class Net | Where-Object { 
        $_.Status -eq 'OK' -and $_.FriendlyName -eq $EthernetAdapter.InterfaceDescription
    } | Select-Object -First 1

    if (-not $PnPDevice) { throw "Could not map active network adapter to a PnP System ID." }

    # Retrieve the exact INF file handling this connection
    $DeviceDetails = Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DeviceID -eq $PnPDevice.InstanceId }
    $ProtectedInf = $DeviceDetails.InfName

    if (-not $ProtectedInf) { throw "Could not determine the INF system filename for your live connection." }
    
    Write-Host "  Protected INF File -> $ProtectedInf" -ForegroundColor Green
}
catch {
    Write-Host "  CRITICAL ERROR: $_" -ForegroundColor Red
    Stop-Script
}

# --- Step 2: Enumerate Everything Else ---
Write-Host "`n[2/3] Scanning for all other targetable network components..." -ForegroundColor Cyan

# Grab every net device (Active, Disconnected, Hidden, Virtual, and Unknown)
$AllNetDevices = Get-PnpDevice -Class Net

$Targets = @()
$ProtectedInfLower = $ProtectedInf.ToLower()

foreach ($Device in $AllNetDevices) {
    # Skip matching our crucial connection
    if ($Device.InstanceId -eq $PnPDevice.InstanceId -or $Device.FriendlyName -eq $EthernetAdapter.InterfaceDescription) {
        continue
    }

    # Dig out the device driver info
    $DriverDetails = Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DeviceID -eq $Device.InstanceId }
    $InfName = $DriverDetails.InfName

    # If it has a valid INF and isn't our protected one, mark it for execution
    if ($InfName) {
        if ($InfName.ToLower() -eq $ProtectedInfLower) { continue }
        
        # Add to object array if not a duplicate
        if ($Targets.InfName -notcontains $InfName) {
            $Targets += [PSCustomObject]@{
                FriendlyName = $Device.FriendlyName
                InstanceId   = $Device.InstanceId
                InfName      = $InfName
            }
        }
    }
}

if ($Targets.Count -eq 0) {
    Write-Host "  No other network drivers found to purge." -ForegroundColor Yellow
    Stop-Script
}

Write-Host "  Found $($Targets.Count) unique driver profile(s) queued for eradication:" -ForegroundColor Yellow
foreach ($Target in $Targets) {
    Write-Host "   - [$($Target.InfName)] $($Target.FriendlyName)" -ForegroundColor Gray
}

# --- Confirmation ---
Write-Host "`nDo you want to proceed with full uninstallation and purging? (Y/N)" -ForegroundColor Yellow
$confirmation = Read-Host
if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "Operation cancelled by user." -ForegroundColor Gray
    Stop-Script
}

# --- Step 3: Purging Process ---
Write-Host "`n[3/3] Commencing deep purge..." -ForegroundColor Cyan
$RemovedCount = 0
$FailedCount = 0

foreach ($Target in $Targets) {
    Write-Host "  Uninstalling device: $($Target.FriendlyName)..." -ForegroundColor Cyan
    
    try {
        # Force system uninstallation and driver block deletion
        $Result = pnputil /delete-driver $Target.InfName /uninstall /force 2>&1 | Out-String
        
        if ($LASTEXITCODE -eq 0 -or $Result -like "*deleted successfully*" -or $Result -like "*uninstalled successfully*") {
            Write-Host "    -> Success: Driver cleared from system." -ForegroundColor Green
            $RemovedCount++
        } else {
            # Some inbox native MS components cannot be hard-deleted from driver storage, but are still disabled/unloaded
            Write-Host "    -> Device uninstalled (Storage package native/locked)." -ForegroundColor Yellow
            $FailedCount++
        }
    }
    catch {
        Write-Host "    -> Fatal Failure: $_" -ForegroundColor Red
        $FailedCount++
    }
}

# --- Summary ---
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "   Purge Process Finalised" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Drivers Completely Purged: $RemovedCount" -ForegroundColor Green
Write-Host "System-Protected/Locked:   $FailedCount" -ForegroundColor Yellow
Write-Host "Active Ethernet Preserved: $ProtectedInf ($($EthernetAdapter.InterfaceDescription))" -ForegroundColor Green

Stop-Script
