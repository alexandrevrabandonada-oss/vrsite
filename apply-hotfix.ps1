$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-hotfix-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$targets = @('src\app\robots.ts','src\app\sitemap.ts')

foreach ($t in $targets) {
  if (Test-Path $t) {
    $rel = Resolve-Path -Relative $t
    $destBackup = Join-Path $backupDir $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $destBackup) | Out-Null
    Copy-Item -Path $t -Destination $destBackup -Force

    $content = Get-Content $t -Raw
    $new = $content -replace "@/src/lib/seo","@/lib/seo"
    if ($new -ne $content) {
      Say "==> Corrigindo import em $t"
      Set-Content -Path $t -Value $new -Encoding UTF8
    } else {
      Warn "Sem alteracao necessaria em $t"
    }
  } else {
    Warn "Arquivo nao encontrado: $t"
  }
}

Say '==> Commitando e enviando'
git add -A
git commit -m 'fix(seo): corrigir imports @/src/lib/seo -> @/lib/seo' | Out-Null
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

Say '==> Hotfix aplicado.'
