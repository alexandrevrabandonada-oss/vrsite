#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

backup="backup-brackets-fix-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"

copy_literal(){
  local src="$1"; local dst="$2"
  [ -f "$dst" ] && { mkdir -p "$backup/$(dirname "$dst")"; cp "$dst" "$backup/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cat "$src" > "$dst"
  say "==> Gravado $dst"
}

copy_literal "payload/instagram_id_page.tsx" "src/app/instagram/[id]/page.tsx"
copy_literal "payload/diag_item_id_page.tsx" "src/app/diag/item/[id]/page.tsx"
copy_literal "payload/diag_ids_page.tsx" "src/app/diag/ids/page.tsx"
copy_literal "payload/diag_item_id_page.tsx" "src/app/diag/itemid/[id]/page.tsx"

git add -A
git commit -m "fix(windows): escreve rotas com [id] via caminho literal + alias /diag/itemid/[id]" >/dev/null || true
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
  warn "Sem Deploy Hook — apenas push (Git integra com Vercel)."
fi

say "==> Bracket Paths Fix aplicado."
