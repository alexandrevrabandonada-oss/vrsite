#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

# 1) Corrigir imports reais
for t in src/app/robots.ts src/app/sitemap.ts; do
  if [ -f "$t" ]; then
    sed -i.bak 's#@/src/lib/seo#@/lib/seo#g' "$t" && rm -f "$t.bak"
    say "==> Corrigido import em $t"
  fi
done

# 2) .gitignore
touch .gitignore
grep -q '^backup-\*/' .gitignore || echo 'backup-*/' >> .gitignore
grep -q '^\.\backups/' .gitignore || echo '.backups/' >> .gitignore
grep -q '^payload/' .gitignore || echo 'payload/' >> .gitignore

# 3) tsconfig.json (exclude)
if [ -f tsconfig.json ]; then
  node - <<'NODE'
const fs = require('fs');
let ts = {};
try { ts = JSON.parse(fs.readFileSync('tsconfig.json','utf8')); } catch {}
ts.exclude = Array.isArray(ts.exclude) ? ts.exclude : (ts.exclude ? [ts.exclude] : []);
for (const e of ["**/backup-*/**",".backups/**","payload/**"]) if (!ts.exclude.includes(e)) ts.exclude.push(e);
fs.writeFileSync('tsconfig.json', JSON.stringify(ts, null, 2));
NODE
fi

# 4) Remover payload
if [ -d payload ]; then
  say "==> Removendo payload/ do repo e do disco"
  git rm -r --cached --ignore-unmatch -q payload || true
  rm -rf payload
fi

# 5) Commit + push
say "==> Commitando e enviando"
git add -A
git commit -m "chore(cleanup): excluir payload do repo e do TS build; ajustar ignore/exclude" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"
[ -n "$branch" ] || branch="main"
git push origin "$branch"

# 6) Deploy Hook opcional
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

say "==> Cleanup v2 aplicado."
