#!/bin/bash
echo "==> Corrigindo links do feed (removendo ?debug)..."
find src -type f \( -name "*.ts" -o -name "*.tsx" \) -exec sed -i 's/?debug=?1//g' {} \;

git add .
git commit -m "fix: remove '?debug' from instagram feed links" || echo "Nenhuma alteração para commitar"

if [ -n "$VERCEL_DEPLOY_HOOK_URL" ]; then
  echo "==> Disparando redeploy no Vercel..."
  curl -X POST "$VERCEL_DEPLOY_HOOK_URL"
else
  echo "==> Deploy hook não configurado. Faça o deploy manual."
fi
