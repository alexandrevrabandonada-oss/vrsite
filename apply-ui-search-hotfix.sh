#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-ui-hotfix-$stamp"
mkdir -p "$backupDir/src/app"

homeFile="src/app/page.tsx"
if [ ! -f "$homeFile" ]; then
  warn "Não encontrei $homeFile. Nada a fazer."
  exit 0
fi

cp "$homeFile" "$backupDir/$homeFile"

# Ensure import
if ! grep -q "from '@/components/HomeSearchBar'" "$homeFile"; then
  sed -i.bak "1s;^;import HomeSearchBar from '@/components/HomeSearchBar'\n;" "$homeFile" && rm -f "$homeFile.bak"
fi

# Insert component
if grep -q "<main" "$homeFile"; then
  sed -i.bak '0,/<main/s//<HomeSearchBar \/>\n<main/' "$homeFile" && rm -f "$homeFile.bak"
elif grep -q "return[[:space:]]*(" "$homeFile"; then
  sed -i.bak '0,/return[[:space:]]*(/s//return (\n  <HomeSearchBar \/>/' "$homeFile" && rm -f "$homeFile.bak"
else
  printf "\n<HomeSearchBar />\n" >> "$homeFile"
fi

say "==> HomeSearchBar injetado em src/app/page.tsx"

say "==> Commitando e enviando"
git add -A
git commit -m "fix(ui): injetar HomeSearchBar na home e evitar conflito com \$HOME" >/dev/null || true
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

say "==> UI Search Hotfix aplicado."
