$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$entries = @(
  @{src='payload\src\app\diag\ids\page.tsx'; dst='src\app\diag\ids\page.tsx'},
  @{src='payload\src\app\diag\item\[id]\page.tsx'; dst='src\app\diag\item\[id]\page.tsx'}
)

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "backup-next-diag-$stamp"

foreach ($e in $entries) {
  $src = Join-Path (Get-Location) $e.src
  $dst = Join-Path (Get-Location) $e.dst
  if (Test-Path $dst) {
    $bk = Join-Path $backup (Resolve-Path -Relative $dst)
    New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
    Copy-Item -Path $dst -Destination $bk -Force
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
  Copy-Item -Path $src -Destination $dst -Force
  Say ("==> Atualizado " + $e.dst)
}

git add -A
git commit -m 'chore(diag): paginas /diag/ids e /diag/item/[id] para inspeção SSR' | Out-Null
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

Say '==> Next Diagnostics Kit aplicado.'
