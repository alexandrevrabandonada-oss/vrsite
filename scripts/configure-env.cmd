@echo off
setlocal ENABLEDELAYEDEXPANSION
set ENV_FILE=.env.local

echo === VR Abandonada - Configurar .env.local (Windows) ===

if not exist %ENV_FILE% (
  echo Criando %ENV_FILE%...
  type nul > %ENV_FILE%
)

echo.
echo Cole o IG_USER_ID (ex.: 1784...):
set /p IGID=

echo.
echo Cole o IG_ACCESS_TOKEN (Facebook Graph - longo):
set /p IGTOK=

echo.
echo (Opcional) Base do Graph [ENTER = https://graph.facebook.com]:
set /p BASE=
if "!BASE!"=="" set BASE=https://graph.facebook.com

echo.
echo Gravando...
> %ENV_FILE% (
  echo IG_USER_ID=!IGID!
  echo IG_ACCESS_TOKEN=!IGTOK!
  echo INSTAGRAM_GRAPH_BASE=!BASE!
  echo INSTAGRAM_GRAPH_VERSION=v21.0
)

echo Pronto. Revise %ENV_FILE% e rode: npm run dev
endlocal