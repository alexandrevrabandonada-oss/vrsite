@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\apply-text-lib-replace.ps1"
pause
