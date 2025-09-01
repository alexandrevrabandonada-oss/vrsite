@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\apply-alias-fix-homefeed.ps1"
pause
