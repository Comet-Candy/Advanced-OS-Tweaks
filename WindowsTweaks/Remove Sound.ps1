# Requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    Break
}

# 1. Define Patterns
$includePatterns = @("*Audio*", "*Sound*", "*Microphone*", "*Headset*", "*Speaker*", "*Realtek*", "*Conexant*", "*IDT*", "*NVIDIA High Definition Audio*", "*Voice Clarity*", "*VoiceClarity*", "*Dolby*", "*Nahimic*", "*Sonic Studio*")
$excludePatterns = @("*Ethernet*", "*Network*", "*Controller*", "*GbE*", "*Wi-Fi*", "*Wireless*", "*Bluetooth*")

Write-Host "Scanning for devices..." -ForegroundColor Cyan

# 2. Retrieve and Filter Devices
$allDevices = Get-PnpDevice -Status 'OK' | Where-Object { $_.FriendlyName }

$targetDevices = $allDevices | Where-Object {
    $name = $_.FriendlyName
    $isIncluded = $false
    $isExcluded = $false

    # Check Include patterns
    foreach ($pattern in $includePatterns) {
        if ($name -like $pattern) {
            $isIncluded = $true
            break
        }
    }

    # Check Exclude patterns (takes precedence)
    if ($isIncluded) {
        foreach ($pattern in $excludePatterns) {
            if ($name -like $pattern) {
                $isExcluded = $true
                break
            }
        }
    }

    return ($isIncluded -and -not $isExcluded)
}

if ($targetDevices.Count -eq 0) {
    Write-Host "No matching devices found based on your patterns." -ForegroundColor Yellow
    Exit
}

Write-Host "Found $($targetDevices.Count) matching device(s):" -ForegroundColor Green
$targetDevices | ForEach-Object { Write-Host " - $($_.FriendlyName) ($($_.InstanceId))" }

# 3. Action: Disable Devices
Write-Host "`n[Step 1] Disabling devices..." -ForegroundColor Yellow

foreach ($device in $targetDevices) {
    try {
        Write-Host "Disabling: $($device.FriendlyName)..." -NoNewline
        Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host " [Success]" -ForegroundColor Green
    }
    catch {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Warning "Could not disable $($device.FriendlyName). Error: $_"
    }
}

Write-Host "`nProcess complete!" -ForegroundColor Cyan
