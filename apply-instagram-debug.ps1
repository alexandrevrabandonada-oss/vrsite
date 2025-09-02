$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Repo Git não encontrado na pasta atual.' }
git rev-parse --is-inside-work-tree *> $null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "backup-instagram-debug-$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$pairs = @(
  @{src='payload\src\app\instagram\[id]\page.tsx'; dst='src\app\instagram\[id]\page.tsx'},
  @{src='payload\public\og-default.png';           dst='public\og-default.png'}
)

foreach ($p in $pairs) {
  $src = Join-Path (Get-Location) $p.src
  $dst = Join-Path (Get-Location) $p.dst

  if (Test-Path -LiteralPath $dst) {
    $bk = Join-Path $backup $p.dst
    New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
    Copy-Item -LiteralPath $dst -Destination $bk -Force
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null

  if (Test-Path -LiteralPath $src) {
    $bytes = [System.IO.File]::ReadAllBytes($src)
    [System.IO.File]::WriteAllBytes($dst, $bytes)
    Say "==> Gravado (literal) $($p.dst)"
  } else {
    Fail "Arquivo de payload não encontrado: $($p.src)"
  }
}

git add -A
git commit -m "feat(instagram): pagina com painel de debug + fallback imagem e og-default.png" | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = 'main' }
git push origin $branch

$hook = $null
if (Test-Path '.env.vercel') {
  foreach ($line in Get-Content '.env.vercel') {
    if ($line -match '^\s*VERCEL_DEPLOY_HOOK_URL\s*=\s*(.+)$') { $hook = $Matches[1].Trim() }
  }
}
if ($hook) {
  Say '==> Disparando Deploy Hook no Vercel'
  try { Invoke-WebRequest -Method POST -Uri $hook -UseBasicParsing | Out-Null } catch { Warn 'Falha ao chamar Deploy Hook' }
} else {
  Warn 'Sem Deploy Hook — somente push (Vercel integra via Git).'
}

Say '==> Patch Instagram Detail Debug aplicado.'
