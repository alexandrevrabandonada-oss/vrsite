$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Repo Git não encontrado.' }
git rev-parse --is-inside-work-tree *> $null

$dst = Join-Path (Get-Location) 'src\app\instagram\[id]\page.tsx'
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null

# Grava como literal (evita curinga dos colchetes no PowerShell)
$code = Get-Content -LiteralPath (Join-Path (Get-Location) 'payload\src\app\instagram\[id]\page.tsx') -Raw
Set-Content -LiteralPath $dst -Value $code -Encoding UTF8
Say "==> Gravado src/app/instagram/[id]/page.tsx (client)"

git add -A
git commit -m "feat(instagram): detalhe client-side com fetch a /api/ig e debug opcional" | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim(); if (-not $branch) { $branch = 'main' }
git push origin $branch

$hook = $null
if (Test-Path '.env.vercel') {
  foreach ($line in Get-Content '.env.vercel') {
    if ($line -match '^\s*VERCEL_DEPLOY_HOOK_URL\s*=\s*(.+)$') { $hook = $Matches[1].Trim() }
  }
}
if ($hook) {
  Say '==> Disparando Deploy Hook'
  try { Invoke-WebRequest -Method POST -Uri $hook -UseBasicParsing | Out-Null } catch { Warn 'Falha ao chamar Deploy Hook' }
} else {
  Warn 'Sem Deploy Hook — deploy via push.'
}

Say '==> Página client aplicada.'
