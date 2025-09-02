#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

dst="src/app/instagram/[id]/page.tsx"
mkdir -p "$(dirname "$dst")"
cat "payload/src/app/instagram/[id]/page.tsx" > "$dst"
say "==> Gravado $dst (client)"

git add -A
git commit -m "feat(instagram): detalhe client-side com fetch a /api/ig e debug opcional" >/dev/null || true
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
  warn "Sem Deploy Hook — deploy via push."
fi

say "==> Página client aplicada."
