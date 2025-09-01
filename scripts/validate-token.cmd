@echo off
setlocal

if not exist ".env.local" (
  echo .env.local nao encontrado.
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in (".env.local") do (
  if /I "%%A"=="IG_ACCESS_TOKEN" set TOKEN=%%B
  if /I "%%A"=="INSTAGRAM_GRAPH_BASE" set GRAPH=%%B
)

if "%GRAPH%"=="" set GRAPH=https://graph.instagram.com

if "%TOKEN%"=="" (
  echo IG_ACCESS_TOKEN vazio.
  exit /b 1
)

echo Testando token em %GRAPH%/me ...
curl -s -G "%GRAPH%/me" -d "fields=id,username" -d "access_token=%TOKEN%"
echo.
