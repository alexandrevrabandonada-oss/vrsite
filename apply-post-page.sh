#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-postpage-$stamp"
mkdir -p "$backupDir"

pairs=(
  "payload/src/app/posts/[id]/page.tsx|src/app/posts/[id]/page.tsx"
  "payload/src/app/api/ig/route.ts|src/app/api/ig/route.ts"
  "payload/src/components/HomeFeed.tsx|src/components/HomeFeed.tsx"
)
for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backupDir/$(dirname "$dst")"; cp "$dst" "$backupDir/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Atualizado $dst"
done

# Ajustar alias '@/src/' -> '@/'
for f in \
  "src/app/api/ig/route.ts" \
  "src/app/posts/[id]/page.tsx" \
  "src/components/HomeFeed.tsx"
do
  [ -f "$f" ] || continue
  sed -i.bak 's#@/src/#@/#g' "$f" && rm -f "$f.bak"
done

say "==> Commitando e enviando"
git add -A
git commit -m "feat(posts): página /posts/[id] e Home linkando internamente; API /api/ig com ?id" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"
[ -n "$branch" ] || branch="main"
git push origin "$branch"

hook=""
if [ -f .env.vercel ]; then
  hook="$(grep -E '^\s*VERCEL_DEPLOY_HOOK_URL=' .env.vercel | sed 's/^[^=]*=//')"
fi
if [ -n "$hook" ]; then
  say "==> Disparando Deploy Hook no Vercel"
  curl -s -X POST "$hook" >/dev/null || warn "Falha ao chamar Deploy Hook (verifique .env.vercel)"
else
  warn "Sem Deploy Hook configurado — apenas o push foi feito (o Vercel deve buildar via Git)."
fi

say "==> Post Page MVP aplicado."
