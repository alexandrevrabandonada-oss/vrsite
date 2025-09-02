#!/bin/bash
set -e

echo "==> Backup de middleware.*"
for f in src/middleware.*; do
  if [ -f "$f" ]; then
    mv "$f" "$f.off"
    echo "Renomeado: $f -> $f.off"
  fi
done

echo "==> Adicionando rota de diagnóstico"
git add src/app/api/diag/ss/route.ts || true

echo "==> Commitando mudanças"
git add -A
git commit -m "Bypass middleware + rota deep diag" || true
git push

if [ ! -z "$VERCEL_DEPLOY_HOOK_URL" ]; then
  echo "==> Disparando deploy hook"
  curl -X POST "$VERCEL_DEPLOY_HOOK_URL"
fi
