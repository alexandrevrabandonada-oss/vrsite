@echo off
setlocal ENABLEDELAYEDEXPANSION
echo == VR Abandonada • Deploy LIMPO via Vercel CLI ==
echo (Forca rebuild sem cache, requer 'vercel login' e 'vercel link')
echo.

where vercel >nul 2>&1 || (
  echo [erro] Vercel CLI nao encontrado. Instale com: npm i -g vercel
  exit /b 1
)

echo [1/4] Limpando caches locais (.next)...
if exist .next rmdir /s /q .next

echo [2/4] Instalando deps (npm ci)...
call npm ci || goto :fail

echo [3/4] Build local (next build)...
call npm run build || goto :fail

echo [4/4] Deploy prebuilt --prod --force ...
vercel deploy --prebuilt --prod --force --yes || goto :fail

echo.
echo [ok] Deploy enviado com forca de cache (novo build no Vercel).
exit /b 0

:fail
echo [erro] Falha no deploy LIMPO.
exit /b 1
