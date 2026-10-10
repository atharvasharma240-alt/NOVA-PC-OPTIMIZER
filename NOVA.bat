@echo off
setlocal EnableExtensions EnableDelayedExpansion
title NOVA Optimizer - Windows Toolkit
color 0B
mode con: cols=100 lines=34 >nul 2>&1
chcp 65001 >nul
pushd "%~dp0"

rem ================================================================
rem NOVA OPTIMIZER
rem A transparent Windows maintenance and diagnostics toolkit.
rem No debloat scripts, no forced service changes, no security changes,
rem no registry "FPS tweaks", and no automatic reboot.
rem ================================================================

set "NOVA_VERSION=2.1"
set "NOVA_HOME=%~dp0"
set "LOGDIR=%NOVA_HOME%NOVA-Logs"
set "LOG=%LOGDIR%\NOVA-Session.log"
if not exist "%LOGDIR%" md "%LOGDIR%" >nul 2>&1
if not exist "%LOGDIR%" set "LOG=%TEMP%\NOVA-Session.log"
call :log "NOVA %NOVA_VERSION% started."
call :detect_admin

:menu
cls
call :header
echo   Welcome to NOVA. Choose a tool; read each confirmation before changes.
echo.
echo   [1]  Dashboard / PC summary
echo   [2]  Full system report (saved to log)
echo   [3]  Clean temporary files (safe best-effort)
echo   [4]  Open Windows Storage / cleanup tools
echo   [5]  Gaming setup hub
echo   [6]  Network & internet toolkit
echo   [7]  Windows health checks and repair
echo   [8]  Disk and drive information
echo   [9]  Startup apps and background-app settings
echo   [10] Power plan tools (inspect / open settings)
echo   [11] Privacy and security settings shortcuts
echo   [12] Create a NOVA diagnostic bundle
echo   [13] Help, safety notes and log location
echo   [0]  Exit
echo.
goto menu_numeric

:menu_numeric
echo Type the number and press Enter:
set "pick="
set /p "pick=  NOVA ^> "
if "%pick%"=="1" goto dashboard
if "%pick%"=="2" goto report
if "%pick%"=="3" goto cleanup
if "%pick%"=="4" goto storage
if "%pick%"=="5" goto gaming
if "%pick%"=="6" goto network
if "%pick%"=="7" goto health
if "%pick%"=="8" goto drives
if "%pick%"=="9" goto startup
if "%pick%"=="10" goto power
if "%pick%"=="11" goto security
if "%pick%"=="12" goto bundle
if "%pick%"=="13" goto help
if "%pick%"=="0" goto exit
echo.
echo   Invalid choice. Enter a number from 0 to 13.
timeout /t 2 >nul
goto menu

:header
echo  ====================================================================================================
echo    N O V A   O P T I M I Z E R   v%NOVA_VERSION%
echo    Windows maintenance ^| Diagnostics ^| Gaming shortcuts ^| Network tools
echo  ====================================================================================================
echo.
exit /b

:dashboard
cls
call :header
echo   QUICK DASHBOARD
echo   -------------------------------------------------------------------------------
echo   Computer name : %COMPUTERNAME%
echo   User          : %USERNAME%
echo   Windows       :
for /f "tokens=*" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption" 2^>nul') do echo                   %%A
echo   CPU           : %PROCESSOR_IDENTIFIER%
echo   Architecture  : %PROCESSOR_ARCHITECTURE%
echo   Admin session : %ADMIN_STATUS%
echo   Log file      : %LOG%
echo.
echo   Live memory summary:
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; '  RAM total: {0:N1} GB' -f ($o.TotalVisibleMemorySize/1MB); '  RAM free : {0:N1} GB' -f ($o.FreePhysicalMemory/1MB)" 2>nul
echo.
echo   NOVA is a maintenance helper, not a magic FPS booster. Results depend on your PC.
call :pause
goto menu

:report
cls
call :header
echo   Collecting a detailed report...
call :log "----- SYSTEM REPORT -----"
(ver) >>"%LOG%" 2>&1
(systeminfo) >>"%LOG%" 2>&1
(echo.) >>"%LOG%"
(echo ==== CPU ====) >>"%LOG%"
(powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List" 2>nul) >>"%LOG%"
(echo ==== MEMORY ====) >>"%LOG%"
(powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer,Capacity,Speed,ConfiguredClockSpeed | Format-Table -AutoSize") >>"%LOG%" 2>&1
(echo ==== GPU ====) >>"%LOG%"
(powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,AdapterRAM | Format-Table -AutoSize") >>"%LOG%" 2>&1
(echo ==== DISKS ====) >>"%LOG%"
(powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,Size | Format-Table -AutoSize") >>"%LOG%" 2>&1
(echo ==== NETWORK CONFIGURATION ====) >>"%LOG%"
(ipconfig /all) >>"%LOG%" 2>&1
(echo ==== POWER PLAN ====) >>"%LOG%"
(powercfg /getactivescheme) >>"%LOG%" 2>&1
(echo ==== END REPORT ====) >>"%LOG%"
echo.
echo   Report appended to:
echo   %LOG%
echo   Note: the report may contain your computer name, account name,
echo   device names and network adapter details. Review it before sharing.
call :pause
goto menu

:cleanup
cls
call :header
echo   TEMPORARY FILE CLEANUP
echo   -------------------------------------------------------------------------------
echo   NOVA targets only the current user's %%TEMP%% folder.
echo   It does not target Downloads, Documents, browser profiles, game files,
echo   Windows Update caches, Prefetch, or the Windows folder.
echo.
echo   Current target: %TEMP%
echo   Locked files will be skipped safely.
echo.
choice /c YN /n /m "Continue? [Y/N]: "
if errorlevel 2 goto menu
call :log "Temp cleanup requested for %TEMP%"
for /f "delims=" %%F in ('dir /a-d /b "%TEMP%" 2^>nul') do (
  del /f /q "%TEMP%\%%F" >nul 2>&1
)
for /d %%D in ("%TEMP%\*") do (
  rd /s /q "%%D" >nul 2>&1
)
echo.
echo   Cleanup pass completed. Windows may retain files that are in use.
call :log "Temp cleanup pass completed."
call :pause
goto menu

:storage
cls
call :header
echo   STORAGE TOOLS
echo   [1] Open Storage settings
echo   [2] Open Disk Cleanup
echo   [3] Open Temporary files settings
echo   [4] Open Optimize Drives (TRIM / drive optimization UI)
echo   [5] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" start "" ms-settings:storagesense
if "%pick%"=="2" start "" cleanmgr.exe
if "%pick%"=="3" start "" ms-settings:storagesense
if "%pick%"=="4" start "" dfrgui.exe
if "%pick%"=="5" goto menu
goto storage

:gaming
cls
call :header
echo   GAMING SETUP HUB
echo   [1] Game Mode settings
echo   [2] Graphics settings (per-app GPU preference)
echo   [3] Captures / background recording settings
echo   [4] Xbox Game Bar settings
echo   [5] Task Manager (check CPU, RAM, GPU usage)
echo   [6] DirectX diagnostic tool
echo   [7] Show active power plan
echo   [8] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" start "" ms-settings:gaming-gamemode
if "%pick%"=="2" start "" ms-settings:display-advancedgraphics
if "%pick%"=="3" start "" ms-settings:gaming-gamedvr
if "%pick%"=="4" start "" ms-settings:gaming-gamebar
if "%pick%"=="5" start "" taskmgr.exe
if "%pick%"=="6" start "" dxdiag.exe
if "%pick%"=="7" (
  powercfg /getactivescheme
  call :pause
)
if "%pick%"=="8" goto menu
goto gaming

:network
cls
call :header
echo   NETWORK & INTERNET TOOLKIT
echo   [1] Show IP / adapter configuration
echo   [2] Ping Cloudflare (1.1.1.1) - quick connectivity test
echo   [3] Ping Google DNS (8.8.8.8) - alternative test
echo   [4] DNS lookup for example.com
echo   [5] Flush DNS resolver cache (safe; does not change DNS provider)
echo   [6] Open Network settings
echo   [7] Open Network Connections
echo   [8] Open Windows network troubleshooter/settings
echo   [9] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" (
  ipconfig /all
  call :log "Network configuration viewed."
  call :pause
)
if "%pick%"=="2" (
  ping -n 4 1.1.1.1
  call :log "Ping test to 1.1.1.1 run."
  call :pause
)
if "%pick%"=="3" (
  ping -n 4 8.8.8.8
  call :log "Ping test to 8.8.8.8 run."
  call :pause
)
if "%pick%"=="4" (
  nslookup example.com
  call :pause
)
if "%pick%"=="5" (
  echo This clears cached DNS lookup results. It does not make internet faster by itself.
  choice /c YN /n /m "Flush DNS cache? [Y/N]: "
  if not errorlevel 2 (
    ipconfig /flushdns
    call :log "DNS cache flush attempted."
  )
  call :pause
)
if "%pick%"=="6" start "" ms-settings:network-status
if "%pick%"=="7" start "" ncpa.cpl
if "%pick%"=="8" start "" ms-settings:troubleshoot
if "%pick%"=="9" goto menu
goto network

:health
cls
call :header
echo   WINDOWS HEALTH CHECKS
echo   These checks can take time. Repair commands may need Administrator access.
echo   They use Microsoft's built-in Windows servicing tools.
echo.
echo   [1] Check whether Windows component store reports health (DISM CheckHealth)
echo   [2] Scan Windows system files (SFC /scannow)
echo   [3] DISM RestoreHealth repair (internet may be required; can take a while)
echo   [4] Open Windows Update settings
echo   [5] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" (
  call :admin_check
  if "!ADMIN_OK!"=="0" goto health_need_admin
  DISM /Online /Cleanup-Image /CheckHealth
  call :log "DISM CheckHealth run."
  call :pause
)
if "%pick%"=="2" (
  call :admin_check
  if "!ADMIN_OK!"=="0" goto health_need_admin
  echo.
  echo   SFC can take several minutes. Do not close this window mid-scan.
  choice /c YN /n /m "Start SFC /scannow? [Y/N]: "
  if errorlevel 2 goto health
  sfc /scannow
  call :log "SFC /scannow run."
  call :pause
)
if "%pick%"=="3" (
  call :admin_check
  if "!ADMIN_OK!"=="0" goto health_need_admin
  echo.
  echo   DISM RestoreHealth can take a while. Save your work first.
  choice /c YN /n /m "Start DISM RestoreHealth? [Y/N]: "
  if errorlevel 2 goto health
  DISM /Online /Cleanup-Image /RestoreHealth
  call :log "DISM RestoreHealth run."
  call :pause
)
if "%pick%"=="4" start "" ms-settings:windowsupdate
if "%pick%"=="5" goto menu
goto health

:health_need_admin
echo.
echo   This operation needs an elevated Administrator terminal.
echo   Close NOVA, right-click NOVA.bat and choose "Run as administrator".
call :pause
goto health

:drives
cls
call :header
echo   DRIVE & DISK INFORMATION
echo.
echo   Logical drives:
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,DriveType,@{N='FileSystem';E={$_.FileSystem}},@{N='FreeSpaceGB';E={[math]::Round($_.FreeSpace/1GB,1)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,1)}},VolumeName | Format-Table -AutoSize" 2>nul
echo.
echo   Physical disk health (where supported):
powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,1)}} | Format-Table -AutoSize" 2>nul
echo.
echo   CHKDSK status (read-only query):
fsutil dirty query %SystemDrive% 2>nul
echo.
echo   Tip: do not run repair scans on a drive you suspect is failing without backing up important files.
call :pause
goto menu

:startup
cls
call :header
echo   STARTUP & BACKGROUND SETTINGS
echo   [1] Open Startup Apps settings
echo   [2] Open Task Manager Startup Apps tab
echo   [3] Open installed apps settings
echo   [4] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" start "" ms-settings:startupapps
if "%pick%"=="2" start "" taskmgr.exe
if "%pick%"=="3" start "" ms-settings:appsfeatures
if "%pick%"=="4" goto menu
goto startup

:power
cls
call :header
echo   POWER PLAN TOOLS
echo   [1] Show active power plan
echo   [2] List available power plans
echo   [3] Open Power Options
echo   [4] Open Windows power settings
echo   [5] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" (
  powercfg /getactivescheme
  call :pause
)
if "%pick%"=="2" (
  powercfg /list
  call :pause
)
if "%pick%"=="3" start "" powercfg.cpl
if "%pick%"=="4" start "" ms-settings:powersleep
if "%pick%"=="5" goto menu
goto power

:security
cls
call :header
echo   PRIVACY & SECURITY SHORTCUTS
echo   NOVA will not disable Defender, Firewall, SmartScreen, UAC, or Windows Update.
echo.
echo   [1] Windows Security dashboard
echo   [2] Windows Update
echo   [3] Privacy settings
echo   [4] App permissions
echo   [5] Return
set "pick="
set /p "pick=Choose: "
if "%pick%"=="1" start "" windowsdefender:
if "%pick%"=="2" start "" ms-settings:windowsupdate
if "%pick%"=="3" start "" ms-settings:privacy
if "%pick%"=="4" start "" ms-settings:privacy-appdiagnostics
if "%pick%"=="5" goto menu
goto security

:bundle
cls
call :header
echo   CREATE DIAGNOSTIC BUNDLE
echo   This writes a text report to NOVA-Logs. Review it before sharing publicly.
echo   It can contain device names, Windows username, adapter details and IP info.
echo.
choice /c YN /n /m "Create report now? [Y/N]: "
if errorlevel 2 goto menu
set "BUNDLE=%LOGDIR%\NOVA-Diagnostic-%COMPUTERNAME%.txt"
if not exist "%LOGDIR%" md "%LOGDIR%" >nul 2>&1
(
 echo NOVA Diagnostic Bundle v%NOVA_VERSION%
 echo Generated: %DATE% %TIME%
 echo Computer: %COMPUTERNAME%
 echo User: %USERNAME%
 echo.
 echo ==== WINDOWS ====
 systeminfo
 echo.
 echo ==== CPU ====
 powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List"
 echo.
 echo ==== MEMORY ====
 powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,OSArchitecture,TotalVisibleMemorySize,FreePhysicalMemory | Format-List"
 echo.
 echo ==== GPU ====
 powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate | Format-Table -AutoSize"
 echo.
 echo ==== DISKS ====
 powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,Size | Format-Table -AutoSize"
 echo.
 echo ==== NETWORK ====
 ipconfig /all
 echo.
 echo ==== POWER ====
 powercfg /getactivescheme
) >"%BUNDLE%" 2>&1
call :log "Diagnostic bundle created: %BUNDLE%"
echo.
echo   Bundle saved:
echo   %BUNDLE%
echo.
echo   IMPORTANT: inspect and redact personal/device/network information before uploading.
call :pause
goto menu

:help
cls
call :header
echo   HELP & SAFETY NOTES
echo   -------------------------------------------------------------------------------
echo   * NOVA is a .BAT front end for built-in Windows tools.
echo   * It asks before cleanup, DNS cache flushing, SFC and DISM repair.
echo   * Temporary cleanup is limited to the current user's TEMP directory.
echo   * No automatic registry edits, service disabling, app removal, or reboot.
echo   * "Optimizer" tools cannot guarantee higher FPS or lower ping.
echo   * For gaming, close apps you recognize and do not need; keep drivers updated.
echo   * Do not disable antivirus or Windows services from random optimization guides.
echo   * Run SFC/DISM only when troubleshooting Windows issues, not as a daily ritual.
echo.
echo   Log: %LOG%
echo   Logs and diagnostic reports may contain personal information.
call :pause
goto menu

:detect_admin
set "ADMIN_STATUS=Standard user"
net session >nul 2>&1
if not errorlevel 1 set "ADMIN_STATUS=Administrator"
exit /b

:admin_check
set "ADMIN_OK=0"
net session >nul 2>&1
if not errorlevel 1 set "ADMIN_OK=1"
exit /b

:log
>>"%LOG%" echo [%DATE% %TIME%] %*
exit /b

:pause
echo.
pause
exit /b

:exit
call :log "NOVA closed."
echo.
echo   Thanks for using NOVA Optimizer.
echo   Your log is here: %LOG%
popd
endlocal
exit /b
