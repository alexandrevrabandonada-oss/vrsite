#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

pairs=(
  "payload/src/lib/ig-data.ts|src/lib/ig-data.ts"
  "payload/src/app/api/ig/route.ts|src/app/api/ig/route.ts"
  "payload/src/app/instagram/[id]/page.tsx|src/app/instagram/[id]/page.tsx"
)

backup="backup-ig-layer-$(date +%Y%m%d-%H%M%S)"
for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backup/$(dirname "$dst")"; cp "$dst" "$backup/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Atualizado $dst"
done

git add -A
git commit -m "refactor(ig): camada unica de dados (route + page usam a mesma fonte)" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"; [ -n "$branch" ] || branch="main"
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

say "==> IG Unified Data Layer aplicado."
