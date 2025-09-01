@echo off
setlocal EnableExtensions EnableDelayedExpansion
title VR Abandonada • Configurar .env.local

echo ===============================================
echo   VR Abandonada - Configurar .env.local
echo   (Windows .CMD - interativo e com PAUSE)
echo ===============================================
echo.

rem --- Solicita TOKEN e USER ID ---
set /p IG_ACCESS_TOKEN= Cole o IG_ACCESS_TOKEN LONGO (sem aspas/linhas): 
set "IG_ACCESS_TOKEN=%IG_ACCESS_TOKEN:"=%"
if not defined IG_ACCESS_TOKEN (
  echo [ERRO] Token vazio.
  goto :end
)

set /p IG_USER_ID= Cole o IG_USER_ID (ex. 1784...): 
set "IG_USER_ID=%IG_USER_ID:"=%"
if not defined IG_USER_ID (
  echo [ERRO] IG_USER_ID vazio.
  goto :end
)

set "INSTAGRAM_GRAPH_BASE=https://graph.facebook.com/v20.0"

rem --- Escreve .env.local ---
(
  echo IG_ACCESS_TOKEN=%IG_ACCESS_TOKEN%
  echo IG_USER_ID=%IG_USER_ID%
  echo INSTAGRAM_GRAPH_BASE=%INSTAGRAM_GRAPH_BASE%
) > ".env.local"

if errorlevel 1 (
  echo [ERRO] Nao foi possivel escrever .env.local
  goto :end
) else (
  echo [ok] .env.local escrito.
)

echo.
echo == Validando credenciais ==
echo.

echo 1) /me (id,name)
curl -s -G "https://graph.facebook.com/v20.0/me" ^
  -d "fields=id,name" ^
  -d "access_token=%IG_ACCESS_TOKEN%" > "%temp%\ig_me.json"
type "%temp%\ig_me.json"
echo.

echo 2) /%IG_USER_ID% (id,username,media_count)
curl -s -G "https://graph.facebook.com/v20.0/%IG_USER_ID%" ^
  -d "fields=id,username,media_count" ^
  -d "access_token=%IG_ACCESS_TOKEN%" > "%temp%\ig_user.json"
type "%temp%\ig_user.json"
echo.

echo 3) /%IG_USER_ID%/media (3 itens)
curl -s -G "https://graph.facebook.com/v20.0/%IG_USER_ID%/media" ^
  -d "fields=id,caption,media_type,media_url,permalink,thumbnail_url,timestamp" ^
  -d "limit=3" ^
  -d "access_token=%IG_ACCESS_TOKEN%" > "%temp%\ig_media.json"
type "%temp%\ig_media.json"
echo.

echo ===============================================
echo Pronto! Agora rode:
echo    npm run dev
echo Testes:
echo    http://localhost:3000/api/instagram?limit=3&raw=1
echo    http://localhost:3000/instagram
echo ===============================================

:end
echo.
pause
endlocal
