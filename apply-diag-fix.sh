#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

dst="src/app/api/diag/ss/route.ts"
mkdir -p "$(dirname "$dst")"

cat > "$dst" <<'TSX'
import { NextResponse } from "next/server";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const id = searchParams.get("id") || "seed-1";

  try {
    const mod = await import("@/lib/ig-data").catch((err) => {
      throw { stage: "import", message: err?.message || String(err), stack: err?.stack || "" };
    });

    const getter = (mod as any).getIgItemById || (mod as any)?.default?.getIgItemById;
    if (typeof getter !== "function") {
      throw { stage: "fn-missing", message: "getIgItemById não encontrado no módulo ig-data" };
    }

    let item = null;
    try {
      item = await getter(id);
    } catch (err: any) {
      throw { stage: "call", message: err?.message || String(err), stack: err?.stack || "" };
    }

    return NextResponse.json({
      ok: true,
      id,
      item,
      diag: { node: process.version, cwd: process.cwd() },
    });
  } catch (err: any) {
    return NextResponse.json({ ok: false, error: err });
  }
}
TSX
echo "==> Gravado $dst"

# Hotfix global: '@/src/lib/' -> '@/lib/'
while IFS= read -r -d '' f; do
  if grep -q "@/src/lib/" "$f"; then
    sed -i.bak 's/@\/src\/lib\//@\/lib\//g' "$f" && rm -f "$f.bak"
    echo "Corrigido import em $f"
  fi
done < <(find src -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.mts" -o -name "*.cts" \) -print0)

git add -A
git commit -m "fix(diag): cria /api/diag/ss e corrige imports '@/src/lib/*' -> '@/lib/*'" >/dev/null || true
branch="$(git rev-parse --abbrev-ref HEAD)"; [ -n "$branch" ] || branch="main"
git push origin "$branch"

if [ -n "${VERCEL_DEPLOY_HOOK_URL:-}" ]; then
  echo "==> Disparando Deploy Hook"
  curl -s -X POST "$VERCEL_DEPLOY_HOOK_URL" >/dev/null || true
else
  echo "Sem Deploy Hook — deploy via push."
fi

echo "==> Fix aplicado."
