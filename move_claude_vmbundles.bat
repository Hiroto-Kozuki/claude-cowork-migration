@echo off
REM ASCII-only launcher - no encoding issues
REM Launches the PowerShell script with admin elevation.

set "PS1=%~dp0move_claude_vmbundles.ps1"

if not exist "%PS1%" (
    echo [ERROR] PowerShell script not found:
    echo         %PS1%
    echo Please keep move_claude_vmbundles.ps1 in the same folder as this .bat
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
exit /b %errorLevel%
