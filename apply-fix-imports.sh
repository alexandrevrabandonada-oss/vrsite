#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }

targets=(
  "src/app/api/ig/route.ts"
  "src/app/instagram/[id]/page.tsx"
  "src/lib/ig-data.ts"
)

backup="backup-fix-imports-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"

for t in "${targets[@]}"; do
  if [ -f "$t" ]; then
    mkdir -p "$backup/$(dirname "$t")"
    cp "$t" "$backup/$t"
    sed -i.bak -e 's#@/src/lib/ig-data#@/lib/ig-data#g' -e 's#@/src/data/ig-seed.json#@/data/ig-seed.json#g' "$t" || true
    rm -f "$t.bak"
    say "==> Corrigido $t"
  fi
done

git add -A
git commit -m "chore(imports): ajusta '@/src/*' para '@/*' (alias '@' aponta para 'src')" >/dev/null || true
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

say "==> Hotfix de imports aplicado."
