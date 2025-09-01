$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$targets = @(
  'src\app\api\ig\route.ts',
  'src\app\page.tsx',
  'src\components\HomeFeed.tsx'
)

$changed = 0
foreach ($t in $targets) {
  if (-not (Test-Path $t)) { continue }
  $c = [System.IO.File]::ReadAllText($t)
  $n = $c.Replace('@/src/','@/')
  if ($n -ne $c) {
    [System.IO.File]::WriteAllText($t, $n)
    Say "==> Corrigido import em $t"
    $changed++
  }
}

if ($changed -eq 0) { Warn 'Nenhuma ocorrência "@/src/" encontrada nos arquivos-alvo.' }

Say '==> Commitando e enviando'
git add -A
git commit -m 'fix(alias): corrigir "@/src/" -> "@/" em HomeFeed e API IG' | Out-Null
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

Say '==> Alias Fix (HomeFeed) aplicado.'
