#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-homefeed-$stamp"
mkdir -p "$backupDir"

pairs=(
  "payload/src/components/HomeFeed.tsx|src/components/HomeFeed.tsx"
  "payload/src/app/api/ig/route.ts|src/app/api/ig/route.ts"
  "payload/src/data/ig-seed.json|src/data/ig-seed.json"
  "payload/src/app/page.tsx|src/app/page.tsx"
)
for pair in "${pairs[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backupDir/$(dirname "$dst")"; cp "$dst" "$backupDir/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Atualizado $dst"
done

# ensure tsconfig resolveJsonModule
if [ -f tsconfig.json ]; then
  node - <<'NODE'
const fs = require('fs');
let ts = {};
try { ts = JSON.parse(fs.readFileSync('tsconfig.json','utf8')); } catch {}
ts.compilerOptions = ts.compilerOptions || {};
ts.compilerOptions.resolveJsonModule = true;
fs.writeFileSync('tsconfig.json', JSON.stringify(ts, null, 2));
NODE
fi

say "==> Commitando e enviando"
git add -A
git commit -m "feat(home): HomeFeed MVP + /api/ig + seed" >/dev/null || true
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

say "==> Home Feed MVP aplicado."
