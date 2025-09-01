#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-textregex-flag-$stamp"
mkdir -p "$backupDir"

# Lista de arquivos contendo /[\u0300-\u036f]/gu
mapfile -d '' files < <(grep -rlZ --include='*.ts' --include='*.tsx' '/\[\\u0300-\\u036f\]/gu' src || true)
for f in "${files[@]}"; do
  mkdir -p "$backupDir/$(dirname "$f")"
  cp "$f" "$backupDir/$f"
  sed -i.bak 's#/\[\\u0300-\\u036f\]/gu#/[\\u0300-\\u036f]/g#g' "$f" && rm -f "$f.bak"
  say "==> Removido flag 'u' em $f"
done

say "==> Commitando e enviando"
git add -A
git commit -m "fix(text): remover flag 'u' de /[\\u0300-\\u036f]/gu para compatibilidade ES5" >/dev/null || true
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

say "==> Text Regex Flag Hotfix aplicado."
