#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

dst="src/app/instagram/[id]/page.tsx"
[ -f "$dst" ] && { mkdir -p "backup-instagram-safe-$(date +%Y%m%d-%H%M%S)/$(dirname "$dst")"; cp "$dst" "backup-instagram-safe-$(date +%Y%m%d-%H%M%S)/$dst"; }
mkdir -p "$(dirname "$dst")"
cat "payload/src/app/instagram/[id]/page.tsx" > "$dst"
say "==> Gravado $dst"

git add -A
git commit -m "fix(instagram): modo seguro com try/catch + debug JSON" >/dev/null || true
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
  warn "Sem Deploy Hook — somente push (Vercel integra via Git)."
fi

say "==> Safe Mode aplicado."
