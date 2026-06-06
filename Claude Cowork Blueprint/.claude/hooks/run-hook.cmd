: << 'CMDBLOCK'
@echo off
REM Windows: run the PowerShell version of the hook (powershell.exe is built in).
REM Usage: run-hook.cmd <name>  ->  <name>.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0%~1.ps1"
exit /b %ERRORLEVEL%
CMDBLOCK

# Unix (mac/linux): run the bash version of the hook. stdin (the payload) is inherited.
DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$DIR/$1.sh"
