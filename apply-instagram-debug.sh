#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

pairs=(
  "payload/src/app/instagram/[id]/page.tsx|src/app/instagram/[id]/page.tsx"
  "payload/public/og-default.png|public/og-default.png"
)

backup="backup-instagram-debug-$(date +%Y%m%d-%H%M%S)"
for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backup/$(dirname "$dst")"; cp "$dst" "$backup/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cat "$src" > "$dst"
  say "==> Gravado $dst"
done

git add -A
git commit -m "feat(instagram): pagina com painel de debug + fallback imagem e og-default.png" >/dev/null || true
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

say "==> Patch Instagram Detail Debug aplicado."
