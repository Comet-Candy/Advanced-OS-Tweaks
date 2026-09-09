# Brave Core Application Engine Policy Injector (Full Massive Performance Expansion)
# This script injects your complete advanced engine profile straight into Brave's Local State file.

# 1. Close open Brave instances to prevent file lock write issues
Write-Host "Closing open Brave processes to ensure file write access..." -ForegroundColor Yellow
Stop-Process -Name "brave" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 2. Locate the Local State Configuration File
$LocalStatePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Local State"

if (-not (Test-Path $LocalStatePath)) {
    Write-Error "Could not find Brave's Local State config file. Run Brave at least once first."
    Exit
}

# 3. Read the existing JSON tree configuration map
$JsonData = Get-Content -Raw -Path $LocalStatePath | ConvertFrom-Json

# 4. Initialize target preference trees if they are empty or missing
if (-not $JsonData.browser) { 
    $JsonData | Add-Member -MemberType NoteProperty -Name browser -Value ([PSCustomObject]@{}) 
}
if (-not $JsonData.browser.enabled_labs_experiments) { 
    $JsonData.browser | Add-Member -MemberType NoteProperty -Name enabled_labs_experiments -Value @() 
}

# 5. Define the complete massive list of advanced internal engine flags
$TargetFlags = @(
    # --- HARDWARE ACCELERATION & RENDER TUNING ---
    "ignore-gpu-blocklist@1",
    "enable-gpu-rasterization@1",
    "enable-zero-copy@1",
    "canvas-oop-rasterization@1",
    "enable-hardware-overlays@1",
    "enable-raw-draw@1",
    "enable-gpu-compositing@1",
    "enable-oop-rasterization@1",
    
    # --- MULTI-THREADING & SYSTEM SCHEDULING ---
    "enable-drdc@1",
    "enable-threaded-compositing@1",
    "num-raster-threads@4",
    "enable-vulkan@1",
    
    # --- MEMORY & VIDEO ENGINE OVERHAULS ---
    "enable-skia-graphite@1",
    "enable-gpu-memory-buffer-video-frames@1",
    "gpu-no-context-lost@1"
)

# 6. Convert the internal collection array to strong string types to fix serialization bugs
[string[]]$CurrentExperiments = $JsonData.browser.enabled_labs_experiments

# Merge new tweaks cleanly without modifying manual experiments you already toggled
foreach ($Flag in $TargetFlags) {
    if ($CurrentExperiments -notcontains $Flag) {
        $CurrentExperiments += $Flag
    }
}

# Apply the fully merged array back into the JSON structure
$JsonData.browser.enabled_labs_experiments = $CurrentExperiments

# 7. Output the structural engine update cleanly back to the Local State file
$UpdatedJson = ConvertTo-Json $JsonData -Depth 100
Set-Content -Path $LocalStatePath -Value $UpdatedJson -Encoding UTF8

Write-Host "Success! Your massive performance tweak library is now successfully injected into Brave's engine core." -ForegroundColor Green
