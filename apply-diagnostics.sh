#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

pairs=(
  "payload/src/app/api/diag/route.ts|src/app/api/diag/route.ts"
  "payload/src/app/diag/page.tsx|src/app/diag/page.tsx"
  "payload/src/app/instagram/[id]/page.tsx|src/app/instagram/[id]/page.tsx"
)

for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Atualizado $dst"
done

git add -A
git commit -m "chore(diag): /diag page + /api/diag + melhorias no detalhe client" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"
[ -n "$branch" ] || branch="main"
git push origin "$branch"

hook=""
if [ -f .env.vercel ]; then
  hook="$(grep -E '^\s*VERCEL_DEPLOY_HOOK_URL=' .env.vercel | sed 's/^[^=]*=//')"
fi
if [ -n "$hook" ]; then
  say "==> Disparando Deploy Hook no Vercel"
  curl -s -X POST "$hook" >/dev/null || true
else
  warn "Sem Deploy Hook configurado — apenas o push foi feito (o Vercel deve buildar via Git)."
fi

say "==> Diagnostics Pack aplicado."
