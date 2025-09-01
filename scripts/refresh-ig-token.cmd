\
  @echo off
  setlocal
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refresh-ig-token.ps1"
  endlocal
