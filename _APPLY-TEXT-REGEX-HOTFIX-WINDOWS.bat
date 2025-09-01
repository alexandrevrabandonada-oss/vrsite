@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\apply-text-regex-hotfix.ps1"
pause
