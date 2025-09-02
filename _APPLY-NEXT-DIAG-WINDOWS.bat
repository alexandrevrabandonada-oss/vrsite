@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\apply-next-diag.ps1"
pause
