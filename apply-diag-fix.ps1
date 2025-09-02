$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Repo Git não encontrado. Abra nesta pasta o projeto clonado.' }
git rev-parse --is-inside-work-tree *> $null

$dst = Join-Path (Get-Location) 'src\app\api\diag\ss\route.ts'
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null

# Escreve o arquivo com o import correto
$code = @'
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
'@
Set-Content -LiteralPath $dst -Value $code -Encoding UTF8
Say "==> Gravado src/app/api/diag/ss/route.ts"

# Hotfix global: '@/src/lib/' -> '@/lib/'
$files = Get-ChildItem -Path 'src' -Recurse -Include *.ts,*.tsx,*.mts,*.cts
foreach ($f in $files) {
  $content = Get-Content -LiteralPath $f.FullName -Raw
  if ($content -match "@\/src\/lib\/") {
    $new = $content -replace "@\/src\/lib\/", "@/lib/"
    if ($new -ne $content) {
      Set-Content -LiteralPath $f.FullName -Value $new -Encoding UTF8
      Say "Corrigido import em $($f.FullName)"
    }
  }
}

git add -A
git commit -m "fix(diag): cria /api/diag/ss e corrige imports '@/src/lib/*' -> '@/lib/*'" | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim(); if (-not $branch) { $branch = 'main' }
git push origin $branch

# Deploy Hook opcional
$hook = $null
if (Test-Path '.env.vercel') {
  foreach ($l in Get-Content '.env.vercel') {
    if ($l -match '^\s*VERCEL_DEPLOY_HOOK_URL\s*=\s*(.+)$') { $hook = $Matches[1].Trim() }
  }
}
if ($hook) {
  Say '==> Disparando Deploy Hook'
  try { Invoke-WebRequest -Method POST -Uri $hook -UseBasicParsing | Out-Null } catch { Warn 'Falha ao chamar Deploy Hook' }
} else {
  Warn 'Sem Deploy Hook — deploy via push.'
}
Say '==> Fix aplicado.'
