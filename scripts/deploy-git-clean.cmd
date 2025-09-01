@echo off
setlocal ENABLEDELAYEDEXPANSION
echo == VR Abandonada • Git commit para forcar rebuild ==
echo.

git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo [erro] Este diretório nao eh um repo git.
  exit /b 1
)

set F=.vercel-cache-bust
echo %DATE% %TIME%> "%F%"
git add "%F%"
git commit -m "chore(deploy): cache-bust %DATE% %TIME%"
git push
echo.
echo [ok] Commit enviado. O Vercel fará novo deploy. Se o cache vier reutilizado,
echo use tambem o deploy LIMPO via Vercel CLI (scripts\deploy-clean.cmd).
