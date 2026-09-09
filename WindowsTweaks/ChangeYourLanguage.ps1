# ╔══════════════════════════════════════════════════════════════╗
# ║       🌐 FULL SYSTEM LOCALISATION TOOL                      ║
# ║       Sets language, region, timezone & keyboard layout     ║
# ║       Run as Administrator                                  ║
# ╚══════════════════════════════════════════════════════════════╝

Import-Module International -ErrorAction Stop

# ─── Helper Functions ───────────────────────────────────────
function Write-Step([string]$Text, [int]$Num, [int]$Total) {
    $Bar = "█" * $Num + "░" * ($Total - $Num)
    Write-Host "  [$Bar] ($Num/$Total) $Text" -ForegroundColor Cyan
}

function Write-OK([string]$Text) {
    Write-Host "    ✅ $Text" -ForegroundColor Green
}

function Write-Warn([string]$Text) {
    Write-Host "    ⚠️  $Text" -ForegroundColor Yellow
}

function Write-Err([string]$Text) {
    Write-Host "    ❌ $Text" -ForegroundColor Red
}

# ─── Available Languages ────────────────────────────────────
$Languages = @(
    @{ Tag="en-NZ";  Name="English (New Zealand)";    GeoId=192;  TZ="New Zealand Standard Time" }
    @{ Tag="en-US";  Name="English (United States)";  GeoId=244;  TZ="Eastern Standard Time" }
    @{ Tag="en-GB";  Name="English (United Kingdom)"; GeoId=199;  TZ="GMT Standard Time" }
    @{ Tag="en-AU";  Name="English (Australia)";      GeoId=16;   TZ="Central Standard Time (Australia)" }
    @{ Tag="en-CA";  Name="English (Canada)";         GeoId=44;   TZ="Pacific Standard Time" }
    @{ Tag="en-IE";  Name="English (Ireland)";        GeoId=177;  TZ="GMT Standard Time" }
    @{ Tag="en-ZA";  Name="English (South Africa)";   GeoId=190;  TZ="South Africa Standard Time" }
    @{ Tag="en-IN";  Name="English (India)";          GeoId=160;  TZ="India Standard Time" }
    @{ Tag="en-SG";  Name="English (Singapore)";      GeoId=201;  TZ="Singapore Standard Time" }
    @{ Tag="en-PH";  Name="English (Philippines)";    GeoId=166;  TZ="SE Asia Standard Time" }
    @{ Tag="en-JM";  Name="English (Jamaica)";        GeoId=124;  TZ="Eastern Standard Time" }
    @{ Tag="en-FJ";  Name="English (Fiji)";           GeoId=98;   TZ="Fiji Time" }
    @{ Tag="en-PG";  Name="English (Papua New Guinea)";GeoId=175;TZ="SE Asia Standard Time" }
    @{ Tag="en-KE";  Name="English (Kenya)";          GeoId=121;  TZ="E. Africa Standard Time" }
    @{ Tag="en-NG";  Name="English (Nigeria)";        GeoId=164;  TZ="W. Africa Standard Time" }
    @{ Tag="en-GH";  Name="English (Ghana)";          GeoId=108;  TZ="GMT Standard Time" }
    @{ Tag="en-ZM";  Name="English (Zambia)";         GeoId=207;  TZ="W. Central Africa Standard Time" }
    @{ Tag="en-ZW";  Name="English (Zimbabwe)";       GeoId=208;  TZ="South Africa Standard Time" }
    @{ Tag="en-UG";  Name="English (Uganda)";         GeoId=200;  TZ="E. Africa Standard Time" }
    @{ Tag="en-TZ";  Name="English (Tanzania)";       GeoId=203;  TZ="E. Africa Standard Time" }
    @{ Tag="en-SC";  Name="English (Seychelles)";     GeoId=189;  TZ="Mauritius Standard Time" }
    @{ Tag="en-MU";  Name="English (Mauritius)";      GeoId=126;  TZ="Mauritius Standard Time" }
    @{ Tag="en-BS";  Name="English (Bahamas)";        GeoId=25;   TZ="Eastern Standard Time" }
    @{ Tag="en-TC";  Name="English (Turks & Caicos)"; GeoId=212;  TZ="Eastern Standard Time" }
    @{ Tag="en-AG";  Name="English (Antigua & Barbuda)";GeoId=14;TZ="Atlantic Standard Time" }
    @{ Tag="en-DM";  Name="English (Dominica)";       GeoId=77;   TZ="Atlantic Standard Time" }
    @{ Tag="en-VC";  Name="English (St. Vincent)";    GeoId=224;  TZ="Atlantic Standard Time" }
    @{ Tag="en-GD";  Name="English (Grenada)";        GeoId=115;  TZ="Atlantic Standard Time" }
    @{ Tag="en-DO";  Name="English (Dominican Republic)";GeoId=76;TZ="Eastern Standard Time" }
    @{ Tag="en-PA";  Name="English (Panama)";         GeoId=172;  TZ="Pacific Standard Time" }
    @{ Tag="en-PR";  Name="English (Puerto Rico)";    GeoId=186;  TZ="Eastern Standard Time" }
    @{ Tag="en-TT";  Name="English (Trinidad)";       GeoId=213;  TZ="Atlantic Standard Time" }
    @{ Tag="en-VG";  Name="English (British Virgin Is.)";GeoId=225;TZ="Eastern Standard Time" }
    @{ Tag="en-VI";  Name="English (U.S. Virgin Is.)";GeoId=226; TZ="Eastern Standard Time" }
    @{ Tag="en-AS";  Name="English (American Samoa)"; GeoId=12;   TZ="Samoa Standard Time" }
    @{ Tag="en-GU";  Name="English (Guam)";           GeoId=116;  TZ="Western Standard Time" }
    @{ Tag="en-MP";  Name="English (N. Mariana Is.)"; GeoId=143;  TZ="Western Standard Time" }
    @{ Tag="en-MH";  Name="English (Marshall Is.)";   GeoId=136;  TZ="Central Pacific Standard Time" }
    @{ Tag="en-KI";  Name="English (Kiribati)";       GeoId=120;  TZ="Central Pacific Standard Time" }
    @{ Tag="en-NR";  Name="English (Nauru)";          GeoId=148;  TZ="Central Pacific Standard Time" }
    @{ Tag="en-TV";  Name="English (Tuvalu)";         GeoId=215;  TZ="Central Pacific Standard Time" }
    @{ Tag="en-WS";  Name="English (Samoa)";          GeoId=222;  TZ="Samoa Standard Time" }
    @{ Tag="en-NU";  Name="English (Niue)";           GeoId=147;  TZ="Samoa Standard Time" }
    @{ Tag="en-CK";  Name="English (Cook Is.)";       GeoId=58;   TZ="Hawaiian Standard Time" }
    @{ Tag="en-HK";  Name="English (Hong Kong)";      GeoId=110;  TZ="China Standard Time" }
    @{ Tag="en-MO";  Name="English (Macau)";          GeoId=134;  TZ="China Standard Time" }
    @{ Tag="en-BN";  Name="English (Brunei)";         GeoId=31;   TZ="SE Asia Standard Time" }
    @{ Tag="en-MY";  Name="English (Malaysia)";       GeoId=132;  TZ="SE Asia Standard Time" }
    @{ Tag="en-TH";  Name="English (Thailand)";       GeoId=204;  TZ="SE Asia Standard Time" }
    @{ Tag="en-VN";  Name="English (Vietnam)";        GeoId=228;  TZ="SE Asia Standard Time" }
    @{ Tag="en-KR";  Name="English (South Korea)";    GeoId=128;  TZ="Korea Standard Time" }
    @{ Tag="en-JP";  Name="English (Japan)";          GeoId=111;  TZ="Tokyo Standard Time" }
    @{ Tag="en-CN";  Name="English (China)";          GeoId=49;   TZ="China Standard Time" }
    @{ Tag="en-TW";  Name="English (Taiwan)";         GeoId=196;  TZ="China Standard Time" }
    @{ Tag="en-ID";  Name="English (Indonesia)";      GeoId=117;  TZ="SE Asia Standard Time" }
    @{ Tag="en-MN";  Name="English (Mongolia)";       GeoId=145;  TZ="W. Mongolia Standard Time" }
    @{ Tag="en-MX";  Name="English (Mexico)";         GeoId=141;  TZ="Central Standard Time" }
    @{ Tag="en-CR";  Name="English (Costa Rica)";     GeoId=64;   TZ="Central Standard Time" }
    @{ Tag="en-CU";  Name="English (Cuba)";           GeoId=65;   TZ="Cuba Standard Time" }
    @{ Tag="en-HN";  Name="English (Honduras)";       GeoId=119;  TZ="Central Standard Time" }
    @{ Tag="en-GT";  Name="English (Guatemala)";      GeoId=114;  TZ="Central Standard Time" }
    @{ Tag="en-SV";  Name="English (El Salvador)";    GeoId=92;   TZ="Central Standard Time" }
    @{ Tag="en-NI";  Name="English (Nicaragua)";      GeoId=149;  TZ="Central Standard Time" }
    @{ Tag="en-EC";  Name="English (Ecuador)";        GeoId=81;   TZ="Ecuador Time" }
    @{ Tag="en-PE";  Name="English (Peru)";           GeoId=170;  TZ="Ecuador Time" }
    @{ Tag="en-BO";  Name="English (Bolivia)";        GeoId=32;   TZ="Ecuador Time" }
    @{ Tag="en-PY";  Name="English (Paraguay)";       GeoId=174;  TZ="E. South America Standard Time" }
    @{ Tag="en-CL";  Name="English (Chile)";          GeoId=50;   TZ="SA Pacific Standard Time" }
    @{ Tag="en-AR";  Name="English (Argentina)";      GeoId=15;   TZ="E. South America Standard Time" }
    @{ Tag="en-UY";  Name="English (Uruguay)";        GeoId=217;  TZ="E. South America Standard Time" }
    @{ Tag="en-BR";  Name="English (Brazil)";         GeoId=33;   TZ="E. South America Standard Time" }
    @{ Tag="en-GY";  Name="English (Guyana)";         GeoId=118;  TZ="SA Western Standard Time" }
    @{ Tag="en-SR";  Name="English (Suriname)";       GeoId=198;  TZ="SA Western Standard Time" }
    @{ Tag="en-FR";  Name="English (France)";         GeoId=93;   TZ="W. Europe Standard Time" }
    @{ Tag="en-DE";  Name="English (Germany)";        GeoId=104;  TZ="W. Europe Standard Time" }
    @{ Tag="en-IT";  Name="English (Italy)";          GeoId=123;  TZ="W. Europe Standard Time" }
    @{ Tag="en-ES";  Name="English (Spain)";          GeoId=194;  TZ="W. Europe Standard Time" }
    @{ Tag="en-PT";  Name="English (Portugal)";       GeoId=173;  TZ="W. Europe Standard Time" }
    @{ Tag="en-NL";  Name="English (Netherlands)";    GeoId=150;  TZ="W. Europe Standard Time" }
    @{ Tag="en-BE";  Name="English (Belgium)";        GeoId=28;   TZ="W. Europe Standard Time" }
    @{ Tag="en-CH";  Name="English (Switzerland)";    GeoId=75;   TZ="W. Europe Standard Time" }
    @{ Tag="en-AT";  Name="English (Austria)";        GeoId=17;   TZ="W. Europe Standard Time" }
    @{ Tag="en-SE";  Name="English (Sweden)";         GeoId=206;  TZ="W. Europe Standard Time" }
    @{ Tag="en-NO";  Name="English (Norway)";         GeoId=153;  TZ="W. Europe Standard Time" }
    @{ Tag="en-DK";  Name="English (Denmark)";        GeoId=78;   TZ="W. Europe Standard Time" }
    @{ Tag="en-FI";  Name="English (Finland)";        GeoId=101;  TZ="FLE Standard Time" }
    @{ Tag="en-IS";  Name="English (Iceland)";        GeoId=122;  TZ="GMT Standard Time" }
    @{ Tag="en-GR";  Name="English (Greece)";         GeoId=113;  TZ="GTB Standard Time" }
    @{ Tag="en-TR";  Name="English (Turkey)";         GeoId=211;  TZ="Turkey Standard Time" }
    @{ Tag="en-RU";  Name="English (Russia)";         GeoId=191;  TZ="GMT Standard Time" }
    @{ Tag="en-UA";  Name="English (Ukraine)";        GeoId=218;  TZ="FLE Standard Time" }
    @{ Tag="en-PL";  Name="English (Poland)";         GeoId=169;  TZ="W. Europe Standard Time" }
    @{ Tag="en-CZ";  Name="English (Czech Republic)"; GeoId=60;   TZ="W. Europe Standard Time" }
    @{ Tag="en-HU";  Name="English (Hungary)";        GeoId=129;  TZ="W. Europe Standard Time" }
    @{ Tag="en-RO";  Name="English (Romania)";        GeoId=187;  TZ="GTB Standard Time" }
    @{ Tag="en-BG";  Name="English (Bulgaria)";       GeoId=34;   TZ="GTB Standard Time" }
    @{ Tag="en-HR";  Name="English (Croatia)";        GeoId=72;   TZ="W. Europe Standard Time" }
    @{ Tag="en-SI";  Name="English (Slovenia)";       GeoId=197;  TZ="W. Europe Standard Time" }
    @{ Tag="en-SK";  Name="English (Slovakia)";       GeoId=193;  TZ="W. Europe Standard Time" }
    @{ Tag="en-LT";  Name="English (Lithuania)";      GeoId=133;  TZ="GTB Standard Time" }
    @{ Tag="en-LV";  Name="English (Latvia)";         GeoId=135;  TZ="GTB Standard Time" }
    @{ Tag="en-EE";  Name="English (Estonia)";        GeoId=82;   TZ="GTB Standard Time" }
    @{ Tag="en-LU";  Name="English (Luxembourg)";     GeoId=137;  TZ="W. Europe Standard Time" }
    @{ Tag="en-MT";  Name="English (Malta)";          GeoId=139;  TZ="W. Europe Standard Time" }
    @{ Tag="en-CY";  Name="English (Cyprus)";         GeoId=69;   TZ="GTB Standard Time" }
    @{ Tag="en-AL";  Name="English (Albania)";        GeoId=11;   TZ="Central Europe Standard Time" }
    @{ Tag="en-MK";  Name="English (North Macedonia)";GeoId=140; TZ="Central Europe Standard Time" }
    @{ Tag="en-BA";  Name="English (Bosnia)";         GeoId=35;   TZ="W. Europe Standard Time" }
    @{ Tag="en-ME";  Name="English (Montenegro)";     GeoId=142;  TZ="Central Europe Standard Time" }
    @{ Tag="en-RS";  Name="English (Serbia)";         GeoId=185;  TZ="Central Europe Standard Time" }
    @{ Tag="en-EG";  Name="English (Egypt)";          GeoId=80;   TZ="Egypt Standard Time" }
    @{ Tag="en-LB";  Name="English (Lebanon)";        GeoId=131;  TZ="Syria Standard Time" }
    @{ Tag="en-JO";  Name="English (Jordan)";         GeoId=125;  TZ="Jordan Standard Time" }
    @{ Tag="en-IL";  Name="English (Israel)";         GeoId=127;  TZ="Israel Standard Time" }
    @{ Tag="en-SA";  Name="English (Saudi Arabia)";   GeoId=181;  TZ="Arabic Standard Time" }
    @{ Tag="en-AE";  Name="English (UAE)";            GeoId=2;    TZ="Arab Standard Time" }
    @{ Tag="en-QA";  Name="English (Qatar)";          GeoId=179;  TZ="Arabic Standard Time" }
    @{ Tag="en-KW";  Name="English (Kuwait)";         GeoId=124;  TZ="Arabic Standard Time" }
    @{ Tag="en-BH";  Name="English (Bahrain)";        GeoId=27;   TZ="Arabic Standard Time" }
    @{ Tag="en-OM";  Name="English (Oman)";           GeoId=158;  TZ="Arab Standard Time" }
    @{ Tag="en-IQ";  Name="English (Iraq)";           GeoId=35;   TZ="Arabic Standard Time" }
    @{ Tag="en-IR";  Name="English (Iran)";           GeoId=36;   TZ="Iran Standard Time" }
    @{ Tag="en-AF";  Name="English (Afghanistan)";    GeoId=10;   TZ="Afghanistan Standard Time" }
    @{ Tag="en-PK";  Name="English (Pakistan)";       GeoId=163;  TZ="Pakistan Standard Time" }
    @{ Tag="en-BD";  Name="English (Bangladesh)";     GeoId=29;   TZ="Bangladesh Standard Time" }
    @{ Tag="en-LK";  Name="English (Sri Lanka)";      GeoId=130;  TZ="Sri Lanka Standard Time" }
    @{ Tag="en-NP";  Name="English (Nepal)";          GeoId=151;  TZ="Nepal Standard Time" }
    @{ Tag="en-BT";  Name="English (Bhutan)";         GeoId=36;   TZ="Myanmar Standard Time" }
    @{ Tag="en-MM";  Name="English (Myanmar)";        GeoId=144;  TZ="Myanmar Standard Time" }
    @{ Tag="en-KH";  Name="English (Cambodia)";       GeoId=54;   TZ="SE Asia Standard Time" }
    @{ Tag="en-LA";  Name="English (Laos)";           GeoId=131;  TZ="SE Asia Standard Time" }
    @{ Tag="en-AZ";  Name="English (Azerbaijan)";     GeoId=22;   TZ="Azerbaijan Standard Time" }
    @{ Tag="en-GE";  Name="English (Georgia)";        GeoId=109;  TZ="Caucasus Standard Time" }
    @{ Tag="en-KZ";  Name="English (Kazakhstan)";     GeoId=118;  TZ="Central Asia Standard Time" }
    @{ Tag="en-AM";  Name="English (Armenia)";        GeoId=16;   TZ="Caucasus Standard Time" }
    @{ Tag="en-TM";  Name="English (Turkmenistan)";   GeoId=216;  TZ="Central Asia Standard Time" }
    @{ Tag="en-TJ";  Name="English (Tajikistan)";     GeoId=202;  TZ="Central Asia Standard Time" }
    @{ Tag="en-ET";  Name="English (Ethiopia)";       GeoId=83;   TZ="E. Africa Standard Time" }
    @{ Tag="en-SD";  Name="English (Sudan)";          GeoId=205;  TZ="E. Africa Standard Time" }
    @{ Tag="en-DJ";  Name="English (Djibouti)";       GeoId=79;   TZ="E. Africa Standard Time" }
    @{ Tag="en-SO";  Name="English (Somalia)";        GeoId=199;  TZ="E. Africa Standard Time" }
    @{ Tag="en-MW";  Name="English (Malawi)";         GeoId=138;  TZ="E. Africa Standard Time" }
    @{ Tag="en-MZ";  Name="English (Mozambique)";     GeoId=152;  TZ="E. Africa Standard Time" }
    @{ Tag="en-BW";  Name="English (Botswana)";       GeoId=38;   TZ="South Africa Standard Time" }
    @{ Tag="en-PF";  Name="English (French Polynesia)";GeoId=102;TZ="Hawaiian Standard Time" }
    @{ Tag="en-WF";  Name="English (Wallis & Futuna)";GeoId=229; TZ="Central Pacific Standard Time" }
    @{ Tag="en-PN";  Name="English (Pitcairn)";       GeoId=171;  TZ="Hawaiian Standard Time" }
    @{ Tag="en-KY";  Name="English (Cayman Is.)";     GeoId=56;   TZ="Cuba Standard Time" }
    @{ Tag="en-BM";  Name="English (Bermuda)";        GeoId=37;   TZ="Atlantic Standard Time" }
    @{ Tag="en-GL";  Name="English (Greenland)";      GeoId=112;  TZ="GMT Standard Time" }
    @{ Tag="en-AQ";  Name="English (Antarctica)";     GeoId=13;   TZ="UTC" }
    @{ Tag="en-CC";  Name="English (Cocos Is.)";      GeoId=51;   TZ="SE Asia Standard Time" }
    @{ Tag="en-CX";  Name="English (Christmas Is.)";  GeoId=59;   TZ="Central Asia Standard Time" }
    @{ Tag="en-NC";  Name="English (New Caledonia)";  GeoId=155;  TZ="Central Pacific Standard Time" }
    @{ Tag="en-AW";  Name="English (Aruba)";          GeoId=19;   TZ="SA Western Standard Time" }
    @{ Tag="en-CW";  Name="English (Curaçao)";        GeoId=68;   TZ="SA Western Standard Time" }
)

# ─── Keyboard Layouts ───────────────────────────────────────
$Keyboards = @(
    @{ Tip="0409:00000409"; Name="US QWERTY (Unicode Fixed)" }
    @{ Tip="0809:00000809"; Name="United Kingdom" }
    @{ Tip="0c09:00000c09"; Name="Australia" }
    @{ Tip="0409:00010409"; Name="Canada - Multilingual" }
)

# ─── Banner ─────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         🌐  FULL SYSTEM LOCALISATION TOOL           ║" -ForegroundColor Magenta
Write-Host "  ║         Sets Language · Region · Time · Keyboard   ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ─── Step 1: Select Language ────────────────────────────────
Write-Host "  📋 Select your language:" -ForegroundColor White
Write-Host ""

$Idx = 0
$DisplayList = @()
foreach ($Lang in $Languages) {
    $Idx++
    $DisplayList += [PSCustomObject]@{
        Number = $Idx
        Tag    = $Lang.Tag
        Name   = $Lang.Name
        GeoId  = $Lang.GeoId
        TZ     = $Lang.TZ
    }
}

Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
for ($i = 0; $i -lt $DisplayList.Count; $i++) {
    $Item = $DisplayList[$i]
    $NumStr = "{0,4}" -f $Item.Number
    Write-Host "  │ $NumStr  $($Item.Name)" -ForegroundColor White
}
Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

$Choice = Read-Host "  🎯 Enter language number (1-$($DisplayList.Count)) or type a tag (e.g. en-NZ)"
Write-Host ""

# Parse selection
$Selected = $null
if ($Choice -match '^\d+$') {
    $Num = [int]$Choice
    if ($Num -ge 1 -and $Num -le $DisplayList.Count) {
        $Selected = $DisplayList[$Num - 1]
    } else {
        Write-Err "Invalid number. Exiting."
        Start-Sleep -Seconds 3
        exit 1
    }
} else {
    $Selected = $DisplayList | Where-Object { $_.Tag -eq $Choice }
    if (-not $Selected) {
        $Selected = $DisplayList | Where-Object { $_.Tag -like "*$Choice*" } | Select-Object -First 1
        if (-not $Selected) {
            Write-Err "Language '$Choice' not found. Exiting."
            Start-Sleep -Seconds 3
            exit 1
        }
    }
}

Write-Host "  ✅ Selected: $($Selected.Name) [$($Selected.Tag)]" -ForegroundColor Green
Write-Host ""

# ─── Step 2: Select Keyboard ────────────────────────────────
Write-Host "  ⌨️  Select keyboard layout:" -ForegroundColor White
Write-Host ""
for ($i = 0; $i -lt $Keyboards.Count; $i++) {
    $Num = $i + 1
    Write-Host "    $Num) $($Keyboards[$i].Name)" -ForegroundColor White
}
Write-Host ""

$KBChoice = Read-Host "  🎯 Enter keyboard number (1-$($Keyboards.Count)) [default: 1]"
if (-not $KBChoice) { $KBChoice = "1" }
$KBNum = [int]$KBChoice
if ($KBNum -lt 1 -or $KBNum -gt $Keyboards.Count) { $KBNum = 1 }
$Keyb = $Keyboards[$KBNum - 1].Tip

Write-Host "  ✅ Keyboard: $($Keyboards[$KBNum - 1].Name)" -ForegroundColor Green
Write-Host ""

# ─── Step 3: Confirm ────────────────────────────────────────
Write-Host "  📝 Summary:" -ForegroundColor White
Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "  │  Language    : $($Selected.Name)" -ForegroundColor White
Write-Host "  │  Tag         : $($Selected.Tag)" -ForegroundColor White
Write-Host "  │  Region      : GeoID $($Selected.GeoId)" -ForegroundColor White
Write-Host "  │  Time Zone   : $($Selected.TZ)" -ForegroundColor White
Write-Host "  │  Keyboard    : $($Keyboards[$KBNum - 1].Name)" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

$Confirm = Read-Host "  ⚡ Apply these settings? (Y/N)"
if ($Confirm -notin @("Y","y","yes","Yes")) {
    Write-Host "  ❌ Cancelled. No changes made." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit 0
}
Write-Host ""

# ─── Apply Settings ─────────────────────────────────────────
$TotalSteps = 8
$Step = 0

# 1. User Culture
$Step++
Write-Step "Setting user culture (date/time/number format)..." $Step $TotalSteps
try {
    Set-Culture -CultureInfo $Selected.Tag
    Write-OK "Culture → $($Selected.Tag)"
} catch {
    Write-Err "Culture: $_"
}

# 2. System Locale
$Step++
Write-Step "Setting system locale (ANSI/DOS code pages)..." $Step $TotalSteps
try {
    Set-WinSystemLocale -SystemLocale $Selected.Tag
    Write-OK "System Locale → $($Selected.Tag)"
} catch {
    Write-Err "System Locale: $_"
}

# 3. UI Language
$Step++
Write-Step "Setting Windows display language..." $Step $TotalSteps
try {
    Set-WinUILanguageOverride -Language $Selected.Tag
    Write-OK "UI Language → $($Selected.Tag)"
} catch {
    Write-Warn "UI Language: $_ (may require language pack install)"
}

# 4. Language List + Keyboard
$Step++
Write-Step "Configuring language list & keyboard layout..." $Step $TotalSteps
try {
    $List = New-WinUserLanguageList -Language $Selected.Tag
    $List[0].InputMethodTips.Clear()
    $List[0].InputMethodTips.Add($Keyb)
    Set-WinUserLanguageList $List -Force
    Write-OK "Language List → $($Selected.Tag) [$Keyb]"
} catch {
    Write-Err "Language List: $_"
}

# 5. Default Input Method
$Step++
Write-Step "Setting default input method override..." $Step $TotalSteps
try {
    Set-WinDefaultInputMethodOverride -InputTip $Keyb
    Write-OK "Default IME → $Keyb"
} catch {
    Write-Warn "Default IME: $_"
}

# 6. Home Location
$Step++
Write-Step "Setting home location (region)..." $Step $TotalSteps
try {
    Set-WinHomeLocation -GeoId $Selected.GeoId
    Write-OK "Region → GeoID $($Selected.GeoId)"
} catch {
    Write-Err "Region: $_"
}

# 7. Time Zone
$Step++
Write-Step "Setting time zone..." $Step $TotalSteps
try {
    Set-TimeZone -Id $Selected.TZ
    Write-OK "Time Zone → $($Selected.TZ)"
} catch {
    Write-Warn "Time Zone: $_ (ID may not exist on this system)"
}

# 8. Language Bar + Propagate
$Step++
Write-Step "Configuring language bar & propagating to system..." $Step $TotalSteps
try {
    Set-WinLanguageBarOption -UseLegacySwitchMode:$false -UseLegacyLanguageBar:$false
    Write-OK "Language Bar → Modern mode"
} catch {
    Write-Warn "Language Bar: $_"
}
try {
    Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
    Write-OK "Propagated to Default User & Welcome Screen"
} catch {
    Write-Warn "Propagation skipped (Win 10 or earlier)"
}

# ─── Final Verification ─────────────────────────────────────
Write-Host ""
$LL = Get-WinUserLanguageList

Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║              ✅  VERIFICATION                       ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Culture         : $(Get-Culture).Name" -ForegroundColor White
Write-Host "  System Locale   : $(Get-WinSystemLocale)" -ForegroundColor White
Write-Host "  UI Language     : $(Get-WinUILanguageOverride)" -ForegroundColor White
Write-Host "  Home Location   : $(Get-WinHomeLocation)" -ForegroundColor White
Write-Host "  Time Zone       : $(Get-TimeZone).Id" -ForegroundColor White
Write-Host "  Language List   : $($LL | ForEach-Object { $_.LanguageTag })" -ForegroundColor White
Write-Host "  Input Tips      : $($LL[0].InputMethodTips -join ', ')" -ForegroundColor White
Write-Host "  Default IME     : $(Get-WinDefaultInputMethodOverride)" -ForegroundColor White
Write-Host ""

# ─── Restart Notice ─────────────────────────────────────────
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║  ⚠️  RESTART YOUR COMPUTER TO TAKE FULL EFFECT     ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Pausing for 5 seconds..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5   
