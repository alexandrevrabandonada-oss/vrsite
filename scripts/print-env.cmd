@echo off
setlocal
echo Lendo .env.local ...
if not exist ".env.local" (
  echo .env.local nao encontrado.
  exit /b 1
)

set FOUND=0
for /f "usebackq tokens=1,* delims==" %%A in (".env.local") do (
  if /I "%%A"=="IG_USER_ID" echo IG_USER_ID=%%B
  if /I "%%A"=="INSTAGRAM_GRAPH_BASE" echo INSTAGRAM_GRAPH_BASE=%%B
  if /I "%%A"=="NEXT_PUBLIC_SITE_URL" echo NEXT_PUBLIC_SITE_URL=%%B
  if /I "%%A"=="IG_ACCESS_TOKEN" (
    set TOKEN=%%B
    set FOUND=1
  )
)

if "%FOUND%"=="1" (
  set PRE=
  set SUF=
  set PRE=!TOKEN:~0,6!
  set SUF=!TOKEN:~-6!
  echo IG_ACCESS_TOKEN=!PRE!...!SUF!  (len: !TOKEN:~0,-0!)
) else (
  echo IG_ACCESS_TOKEN=NAO DEFINIDO
)
