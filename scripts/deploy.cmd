@echo off
setlocal ENABLEDELAYEDEXPANSION
echo == VR Abandonada • Deploy via Git ==
echo.

REM Ensure we're in a git repo
git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [erro] Este diretório nao eh um repo git.
  echo Abra a pasta do projeto correta e tente de novo.
  exit /b 1
)

set MSG=chore(deploy): deploy rapido %DATE% %TIME%
if not "%~1"=="" set MSG=%*
echo Commit: %MSG%
git add -A
git commit -m "%MSG%" || echo [info] Nada para commitar (ok)
git push
echo.
echo Se o projeto esta conectado ao Vercel (Git-based), o deploy inicia automaticamente.
echo Abra o painel do Vercel para acompanhar.
