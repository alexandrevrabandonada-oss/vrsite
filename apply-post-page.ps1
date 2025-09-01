$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-postpage-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$entries = @(
  @{src='payload\src\app\posts\[id]\page.tsx'; dst='src\app\posts\[id]\page.tsx'},
  @{src='payload\src\app\api\ig\route.ts'; dst='src\app\api\ig\route.ts'},
  @{src='payload\src\components\HomeFeed.tsx'; dst='src\components\HomeFeed.tsx'}
)

foreach ($e in $entries) {
  $src = Join-Path (Get-Location) $e.src
  $dst = Join-Path (Get-Location) $e.dst

  if (Test-Path $dst) {
    $rel = Resolve-Path -Relative $dst
    $destBackup = Join-Path $backupDir $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $destBackup) | Out-Null
    Copy-Item -Path $dst -Destination $destBackup -Force
  }

  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  Copy-Item -Path $src -Destination $dst -Force
  Say ("==> Atualizado " + $e.dst)
}

# Ajustar alias '@/src/' -> '@/'
$targets = @(
  'src\app\api\ig\route.ts',
  'src\app\posts\[id]\page.tsx',
  'src\components\HomeFeed.tsx'
)
foreach ($t in $targets) {
  if (-not (Test-Path $t)) { continue }
  $c = [System.IO.File]::ReadAllText($t)
  $n = $c.Replace('@/src/','@/')
  if ($n -ne $c) { [System.IO.File]::WriteAllText($t, $n) }
}

Say '==> Commitando e enviando'
git add -A
git commit -m 'feat(posts): página /posts/[id] e Home linkando internamente; API /api/ig com ?id' | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = 'main' }
git push origin $branch

$hook = $null
$envFile = '.env.vercel'
if (Test-Path $envFile) {
  foreach ($line in Get-Content $envFile) {
    if ($line -match '^\s*VERCEL_DEPLOY_HOOK_URL\s*=\s*(.+)$') { $hook = $Matches[1].Trim() }
  }
}
if ($hook) {
  Say '==> Disparando Deploy Hook no Vercel'
  try {
    $resp = Invoke-WebRequest -Method POST -Uri $hook -UseBasicParsing
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300) {
      Write-Host '[OK] Redeploy solicitado com sucesso.' -ForegroundColor Green
    } else {
      Warn ('Resposta do Vercel: ' + $resp.StatusCode)
    }
  } catch {
    Warn 'Falha ao chamar Deploy Hook. Verifique a URL em .env.vercel'
  }
} else {
  Warn 'Sem Deploy Hook configurado — apenas o push foi feito (o Vercel deve buildar via Git).'
}

Say '==> Post Page MVP aplicado.'
