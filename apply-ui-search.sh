#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-ui-$stamp"
mkdir -p "$backupDir"

# Write components
for pair in \
  "payload/src/components/AppHeader.tsx|src/components/AppHeader.tsx" \
  "payload/src/components/HomeSearchBar.tsx|src/components/HomeSearchBar.tsx"
do
  IFS="|" read -r src dst <<< "$pair"
  [ -f "$dst" ] && { mkdir -p "$backupDir/$(dirname "$dst")"; cp "$dst" "$backupDir/$dst"; }
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  say "==> Gravado $dst"
done

# Inject header in layout.tsx
layout="src/app/layout.tsx"
if [ -f "$layout" ]; then
  txt="$(cat "$layout")"
  if ! grep -q "from '@/components/AppHeader'" <<<"$txt"; then
    txt="$(printf "import AppHeader from '@/components/AppHeader'\n%s" "$txt")"
  fi
  # Insert <AppHeader /> right after <body ...>
  txt="$(printf "%s" "$txt" | awk 'BEGIN{added=0} {print} /<body/{if(added==0){print "      <AppHeader />"; added=1}}')"
  printf "%s" "$txt" > "$layout"
  say "==> Header injetado em layout.tsx"
else
  warn "Nao encontrei src/app/layout.tsx. Pulei a injecao do header."
fi

# Inject HomeSearchBar in page.tsx
home="src/app/page.tsx"
if [ -f "$home" ]; then
  if ! grep -q "from '@/components/HomeSearchBar'" "$home"; then
    sed -i.bak "1s;^;import HomeSearchBar from '@/components/HomeSearchBar'\n;" "$home" && rm -f "$home.bak"
  fi
  if grep -q "<main" "$home"; then
    sed -i.bak '0,/<main/s//<HomeSearchBar \/>\n<main/' "$home" && rm -f "$home.bak"
  else
    # fallback: after 'return ('
    sed -i.bak '0,/return[[:space:]]*(/s//return (\n  <HomeSearchBar \/>/' "$home" && rm -f "$home.bak"
  fi
  say "==> HomeSearchBar injetado em page.tsx"
else
  warn "Nao encontrei src/app/page.tsx. Pulei injecao na home."
fi

say "==> Commitando e enviando"
git add -A
git commit -m "feat(ui): navbar com link /search + barra de busca na home (hero)" >/dev/null || true
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

say "==> UI Search Visibility Pack aplicado."
