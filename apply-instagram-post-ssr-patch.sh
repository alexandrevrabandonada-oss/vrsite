#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

backupDir="backup-instagram-post-ssr-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backupDir/src/app/instagram/[id]"

src="payload/src/app/instagram/[id]/page.tsx"
dst="src/app/instagram/[id]/page.tsx"
[ -f "$dst" ] && cp "$dst" "$backupDir/$dst"
mkdir -p "$(dirname "$dst")"
cp "$src" "$dst"
say "==> Atualizado $dst"

git add -A
git commit -m "fix(instagram): detalhe SSR com origem via headers e dynamic=force-dynamic" >/dev/null || true
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

say "==> Instagram Post SSR Patch aplicado."
