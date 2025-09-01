#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-textregex-$stamp"
mkdir -p "$backupDir"

while IFS= read -r -d '' f; do
  rel="$f"
  mkdir -p "$backupDir/$(dirname "$rel")"
  cp "$rel" "$backupDir/$rel"
  # Replace \p{Diacritic} with [\u0300-\u036f]
  sed -i.bak 's#\\p{Diacritic}#[\\u0300-\\u036f]#g' "$rel" && rm -f "$rel.bak"
  say "==> Corrigido regex em $rel"
done < <(find src -type f \( -name '*.ts' -o -name '*.tsx' \) -print0 | xargs -0 grep -l '\\p{Diacritic}' -Z | tr -d '\n' | xargs -0 -I{} bash -c 'printf "%s\0" "$@"' _ {})

say "==> Commitando e enviando"
git add -A
git commit -m "fix(text): substituir \\p{Diacritic} por [\\u0300-\\u036f] para compatibilidade" >/dev/null || true
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

say "==> Text Regex Hotfix aplicado."
