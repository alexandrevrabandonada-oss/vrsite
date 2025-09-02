$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Repo Git não encontrado na pasta atual.' }
git rev-parse --is-inside-work-tree *> $null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "backup-instagram-safe-$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$src = Join-Path (Get-Location) 'payload\src\app\instagram\[id]\page.tsx'
$dst = Join-Path (Get-Location) 'src\app\instagram\[id]\page.tsx'

if (Test-Path -LiteralPath $dst) {
  $bk = Join-Path $backup 'src\app\instagram\[id]\page.tsx'
  New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
  Copy-Item -LiteralPath $dst -Destination $bk -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
$bytes = [System.IO.File]::ReadAllBytes($src)
[System.IO.File]::WriteAllBytes($dst, $bytes)
Say "==> Gravado (literal) src/app/instagram/[id]/page.tsx"

git add -A
git commit -m "fix(instagram): modo seguro com try/catch + debug JSON" | Out-Null
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

Say '==> Safe Mode aplicado.'
