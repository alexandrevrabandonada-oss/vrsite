@echo off
setlocal EnableExtensions EnableDelayedExpansion
title VR Abandonada • Test IG API

if not exist ".env.local" (
  echo [ERRO] .env.local nao encontrado. Rode scripts\configure-env.cmd primeiro.
  pause
  exit /b 1
)

rem Carrega variaveis de .env.local
for /f "usebackq tokens=1,* delims==" %%A in (".env.local") do (
  if /i "%%A"=="IG_ACCESS_TOKEN" set "IG_ACCESS_TOKEN=%%B"
  if /i "%%A"=="IG_USER_ID" set "IG_USER_ID=%%B"
  if /i "%%A"=="INSTAGRAM_GRAPH_BASE" set "INSTAGRAM_GRAPH_BASE=%%B"
)
if not defined INSTAGRAM_GRAPH_BASE set "INSTAGRAM_GRAPH_BASE=https://graph.facebook.com/v20.0"

echo == Validando com dados do .env.local ==
echo TOKEN (inicio): !IG_ACCESS_TOKEN:~0,10!...
echo IG_USER_ID: !IG_USER_ID!
echo BASE: !INSTAGRAM_GRAPH_BASE!
echo.

echo 1) /me (id,name)
curl -s -G "!INSTAGRAM_GRAPH_BASE!/me" ^
  -d "fields=id,name" ^
  -d "access_token=!IG_ACCESS_TOKEN!"
echo.

echo 2) /!IG_USER_ID! (id,username,media_count)
curl -s -G "!INSTAGRAM_GRAPH_BASE!/!IG_USER_ID!" ^
  -d "fields=id,username,media_count" ^
  -d "access_token=!IG_ACCESS_TOKEN!"
echo.

echo 3) /!IG_USER_ID!/media (3 itens)
curl -s -G "!INSTAGRAM_GRAPH_BASE!/!IG_USER_ID!/media" ^
  -d "fields=id,caption,media_type,media_url,permalink,thumbnail_url,timestamp" ^
  -d "limit=3" ^
  -d "access_token=!IG_ACCESS_TOKEN!"
echo.

pause
endlocal
