#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

branch="$(git rev-parse --abbrev-ref HEAD)"
[ -n "$branch" ] || branch="main"
stamp="$(date '+%Y-%m-%d %H:%M:%S')"

say "==> Fazendo commit e push ($branch)"
git add -A
git commit -m "deploy-now: $stamp" >/dev/null || true
git push origin "$branch"

# Deploy Hook opcional (.env.vercel)
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

say "==> Deploy acionado."
