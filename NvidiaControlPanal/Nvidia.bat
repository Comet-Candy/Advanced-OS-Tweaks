@echo off
SETLOCAL

set "ZIP=%~dp0NVIDIACorp.NVIDIAControlPanel_8.1.969.0_x64__56jybvy8sckqj.zip"
set "DEST=%ProgramFiles%\NVIDIA Corporation\Control Panel Client"

echo Extracting...
if exist "%DEST%" rmdir /s /q "%DEST%"
mkdir "%DEST%"
tar -xf "%ZIP%" -C "%DEST%" nvcplui.exe nvcpluir.dll nvImage.dll NvGpuUtilization.exe resources.pri

echo Writing launcher...
(
echo sc.exe config NVDisplay.ContainerLocalSystem start= demand ^>nul 2^>^&1
echo net start NVDisplay.ContainerLocalSystem ^>nul 2^>^&1
echo start "" "%DEST%\nvcplui.exe"
) > "%DEST%\launch.bat"

echo Configuring registry...
reg add "HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client" /v ShowSedoanEula /t REG_DWORD /d 1 /f
reg add "HKCU\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v ContextUIPolicy /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%DEST%\nvcplui.exe" /t REG_SZ /d "~ RUNASADMIN" /f

echo Registering context menu...
reg delete "HKCR\Directory\Background\shell\NVIDIAControlPanel" /f >nul 2>&1
reg delete "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /f >nul 2>&1
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /ve /t REG_SZ /d "NVIDIA Control Panel" /f
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /v "Icon" /t REG_SZ /d "%DEST%\nvcpluir.dll,0" /f
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel\command" /ve /t REG_SZ /d "conhost --headless \"%DEST%\launch.bat\"" /f

echo Creating Start Menu shortcut...
powershell -NoProfile -Command "$ws=New-Object -ComObject WScript.Shell;$sc=$ws.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\NVIDIA Control Panel.lnk');$sc.TargetPath='%DEST%\nvcplui.exe';$sc.IconLocation='%DEST%\nvcpluir.dll,0';$sc.Save()"

taskkill /f /im explorer.exe >nul 2>&1
del /f /q "%localappdata%\IconCache.db" >nul 2>&1
del /f /q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
start explorer.exe

echo Done.
pause
