#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf "\033[36m%s\033[0m\n" "$1"; }
warn(){ printf "\033[33m%s\033[0m\n" "$1"; }
fail(){ printf "\033[31m[ERRO] %s\033[0m\n" "$1"; exit 1; }

[ -d .git ] || fail "Este diretório não é um repositório Git (.git ausente)."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Não é um repositório Git válido."

stamp="$(date +%Y%m%d-%H%M%S)"
backupDir="backup-seo-$stamp"
mkdir -p "$backupDir"

copy_with_backup () {
  src="$1"; dst="$2"
  src_abs="$(realpath "$src")"
  dst_abs="$(realpath "$dst" 2>/dev/null || true)"
  if [ -n "${dst_abs:-}" ] && [ "$src_abs" = "$dst_abs" ]; then
    warn "Ignorando cópia: origem e destino são o mesmo arquivo."
    return
  fi
  if [ -e "$dst" ]; then
    mkdir -p "$backupDir/$(dirname "$dst")"
    cp -R "$dst" "$backupDir/$dst"
  fi
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}

files=(
  "payload/src/app/robots.ts|src/app/robots.ts"
  "payload/src/app/sitemap.ts|src/app/sitemap.ts"
  "payload/src/lib/seo.ts|src/lib/seo.ts"
  "payload/src/components/StructuredData.tsx|src/components/StructuredData.tsx"
  "payload/public/og-default.png|public/og-default.png"
)
for pair in "${files[@]}"; do
  IFS="|" read -r src dst <<< "$pair"
  say "==> Copiando $src -> $dst"
  copy_with_backup "$src" "$dst"
done

say "==> Commitando e enviando"
git add -A
git commit -m "feat(seo): sitemap, robots, og default e json-ld (v3 payload + guard)" >/dev/null || true
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

say "==> SEO-Pack aplicado (v3)."
