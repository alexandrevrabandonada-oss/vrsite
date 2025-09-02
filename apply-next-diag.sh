#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

pairs=(
  "payload/src/app/diag/ids/page.tsx|src/app/diag/ids/page.tsx"
  "payload/src/app/diag/item/[id]/page.tsx|src/app/diag/item/[id]/page.tsx"
)

backup="backup-next-diag-$(date +%Y%m%d-%H%M%S)"
for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backup/$(dirname "$dst")"; cp "$dst" "$backup/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Atualizado $dst"
done

git add -A
git commit -m "chore(diag): paginas /diag/ids e /diag/item/[id] para inspeção SSR" >/dev/null || true
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

say "==> Next Diagnostics Kit aplicado."
