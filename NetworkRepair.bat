@echo off
:: USE AT OWN RISK. PROVIDED AS IS WITHOUT WARRANTY.
:: Run this script as Administrator.

echo [1/6] Restoring Network Services and Registry Policies...
reg add "HKLM\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" /v "DisablePassivePolling" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" /v "NoActiveProbe" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v "EnableActiveProbing" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Services\BFE" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\System\CurrentControlSet\Services\Dnscache" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\System\CurrentControlSet\Services\MpsSvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\System\CurrentControlSet\Services\WinHttpAutoProxySvc" /v "Start" /t REG_DWORD /d "3" /f

sc config Dhcp start= auto
sc config DPS start= auto
sc config DusmSvc start= auto
sc config lmhosts start= auto
sc config NlaSvc start= auto
sc config nsi start= auto
sc config RmSvc start= auto
sc config Wcmsvc start= auto
sc config WdiServiceHost start= demand
sc config Winmgmt start= auto
sc config NcbService start= demand
sc config ndu start= demand
sc config Netman start= demand
sc config netprofm start= demand
sc config WlanSvc start= auto
sc config WwanSvc start= demand

net start DPS >nul 2>&1
net start nsi >nul 2>&1
net start NlaSvc >nul 2>&1
net start Dhcp >nul 2>&1
net start Wcmsvc >nul 2>&1
net start RmSvc >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\DUSM\dusmtask" /Enable >nul 2>&1

echo [2/6] Power-cycling Network Adapters...
for /L %%i in (0,1,5) do wmic path win32_networkadapter where index=%%i call disable >nul 2>&1
timeout /t 5 /nobreak
for /L %%i in (0,1,5) do wmic path win32_networkadapter where index=%%i call enable >nul 2>&1

echo [3/6] Flushing Network Caches and Resetting Configurations...
arp -d * >nul 2>&1
route -f >nul 2>&1
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1
netsh advfirewall reset >nul 2>&1
netsh dns set global doh=no >nul 2>&1
netsh dns set global dot=no >nul 2>&1
netcfg -d >nul 2>&1
netsh winsock reset >nul 2>&1

echo [4/6] Resetting IP and Tunnel Interfaces...
netsh int 6to4 reset all >nul 2>&1
netsh int httpstunnel reset all >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int isatap reset all >nul 2>&1
netsh int portproxy reset all >nul 2>&1
netsh int tcp reset all >nul 2>&1
netsh int teredo reset all >nul 2>&1
netsh branchcache reset >nul 2>&1
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1

echo [5/6] Opening Hosts File for Verification...
echo Verify that only localhost entries are active (127.0.0.1 and ::1).
start "" /wait notepad %WINDIR%\System32\Drivers\Etc\Hosts

echo [6/6] System will restart in 60 seconds.
echo To cancel the restart, open CMD and type: shutdown /a
shutdown /r /t 60
pause
