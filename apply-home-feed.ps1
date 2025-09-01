$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-homefeed-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$entries = @(
  @{src='payload\src\components\HomeFeed.tsx'; dst='src\components\HomeFeed.tsx'},
  @{src='payload\src\app\api\ig\route.ts'; dst='src\app\api\ig\route.ts'},
  @{src='payload\src\data\ig-seed.json'; dst='src\data\ig-seed.json'},
  @{src='payload\src\app\page.tsx'; dst='src\app\page.tsx'}
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

# tsconfig: resolveJsonModule true (para importar seed)
$tsPath = 'tsconfig.json'
if (Test-Path $tsPath) {
  $json = [System.IO.File]::ReadAllText($tsPath)
  if ($json -notmatch '"resolveJsonModule"\s*:\s*true') {
    if ($json -match '"compilerOptions"\s*:\s*{') {
      $json = $json -replace '"compilerOptions"\s*:\s*{', '"compilerOptions": { "resolveJsonModule": true,'
    } else {
      if ($json.Trim().EndsWith('}')) {
        $json = $json.Trim().TrimEnd('}') + ', "compilerOptions": { "resolveJsonModule": true } }'
      } else {
        $json = '{ "compilerOptions": { "resolveJsonModule": true } }'
      }
    }
    [System.IO.File]::WriteAllText($tsPath, $json)
    Say "==> tsconfig.json: resolveJsonModule=true"
  }
}

Say '==> Commitando e enviando'
git add -A
git commit -m 'feat(home): HomeFeed MVP + /api/ig + seed' | Out-Null
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

Say '==> Home Feed MVP aplicado.'
