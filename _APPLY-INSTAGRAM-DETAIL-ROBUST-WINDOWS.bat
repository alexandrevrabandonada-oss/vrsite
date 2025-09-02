@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\apply-instagram-detail-robust.ps1"
pause
