$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "backup-fix-imports-$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$targets = @(
  'src\app\api\ig\route.ts',
  'src\app\instagram\[id]\page.tsx',
  'src\lib\ig-data.ts'
)

foreach($t in $targets){
  if (Test-Path $t){
    $bk = Join-Path $backup $t
    New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
    Copy-Item $t $bk -Force
    (Get-Content $t -Raw) `
      -replace "@/src/lib/ig-data","@/lib/ig-data" `
      -replace "@/src/data/ig-seed.json","@/data/ig-seed.json" `
      | Set-Content $t -Encoding UTF8
    Say "==> Corrigido $t"
  }
}

git add -A
git commit -m "chore(imports): ajusta '@/src/*' para '@/*' (alias '@' aponta para 'src')" | Out-Null
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

Say '==> Hotfix de imports aplicado.'
