$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-seo-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

function CopyWithBackup {
  param([string]$Src, [string]$Dst)
  # Skip if resolved paths are identical
  $srcFull = (Resolve-Path $Src).Path
  $dstFull = (Resolve-Path -ErrorAction SilentlyContinue $Dst)
  $dstFullPath = $null
  if ($dstFull) { $dstFullPath = $dstFull.Path }
  if ($dstFullPath -and ($srcFull -ieq $dstFullPath)) {
    Warn 'Ignorando copia: origem e destino sao o mesmo arquivo.'
    return
  }

  if (Test-Path $Dst) {
    $relPath = Resolve-Path -Relative $Dst
    $destBackup = Join-Path $backupDir $relPath
    New-Item -ItemType Directory -Force -Path (Split-Path $destBackup) | Out-Null
    Copy-Item -Path $Dst -Destination $destBackup -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $Dst) | Out-Null
  Copy-Item -Path $Src -Destination $Dst -Force
}

$entries = @(
  @{src='payload\src\app\robots.ts'; dst='src\app\robots.ts'},
  @{src='payload\src\app\sitemap.ts'; dst='src\app\sitemap.ts'},
  @{src='payload\src\lib\seo.ts'; dst='src\lib\seo.ts'},
  @{src='payload\src\components\StructuredData.tsx'; dst='src\components\StructuredData.tsx'},
  @{src='payload\public\og-default.png'; dst='public\og-default.png'}
)

foreach ($e in $entries) {
  $src = Join-Path (Get-Location) $e.src
  $dst = Join-Path (Get-Location) $e.dst
  Say ('==> Copiando ' + $e.src + ' -> ' + $e.dst)
  CopyWithBackup -Src $src -Dst $dst
}

Say '==> Commitando e enviando'
git add -A
git commit -m 'feat(seo): sitemap, robots, og default e json-ld (v3 payload + guard)' | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = 'main' }
git push origin $branch

# Deploy Hook opcional
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

Say '==> SEO-Pack aplicado (v3).'
