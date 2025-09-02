#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

dst="src/app/instagramid/[id]/page.tsx"
mkdir -p "$(dirname "$dst")"
cat "payload/src/app/instagramid/[id]/page.tsx" > "$dst"
say "==> Gravado $dst"

git add -A
git commit -m "feat: rota alias /instagramid/[id] com painel de debug" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"; [ -n "$branch" ] || branch="main"
git push origin "$branch"

hook=""
if [ -f .env.vercel ]; then
  hook="$(grep -E '^\s*VERCEL_DEPLOY_HOOK_URL=' .env.vercel | sed 's/^[^=]*=//')"
fi
if [ -n "$hook" ]; then
  say "==> Disparando Deploy Hook"
  curl -s -X POST "$hook" >/dev/null || true
else
  warn "Sem Deploy Hook — apenas push."
fi

say "==> Alias aplicado."
