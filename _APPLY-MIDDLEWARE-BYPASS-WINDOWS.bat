@echo off
setlocal enabledelayedexpansion

echo ==> Backup de middleware.*
for %%f in (src\middleware.*) do (
  if exist "%%f" (
    ren "%%f" "%%~nxf.off"
    echo Renomeado: %%f -> %%~nxf.off
  )
)

echo ==> Adicionando rota de diagnóstico
git add src\app\api\diag\ss\route.ts

echo ==> Commitando mudanças
git add -A
git commit -m "Bypass middleware + rota deep diag"
git push

if defined VERCEL_DEPLOY_HOOK_URL (
  echo ==> Disparando deploy hook
  curl -X POST %VERCEL_DEPLOY_HOOK_URL%
)
