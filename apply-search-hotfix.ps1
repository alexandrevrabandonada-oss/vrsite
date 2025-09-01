$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

# 1) Corrigir imports "@/src/" -> "@/"
$changed = @()
Get-ChildItem -Path 'src' -Recurse -Include *.ts,*.tsx | ForEach-Object {
  $p = $_.FullName
  $c = Get-Content $p -Raw
  $n = $c -replace "@/src/","@/"
  if ($n -ne $c) {
    Set-Content -Path $p -Value $n -Encoding UTF8
    $changed += $p
    Say "==> Corrigido import em $p"
  }
}

# 2) tsconfig.json: resolveJsonModule = true
$tsPath = 'tsconfig.json'
if (Test-Path $tsPath) {
  $ts = ConvertFrom-Json (Get-Content $tsPath -Raw)
} else {
  $ts = ConvertFrom-Json '{"compilerOptions":{}}'
}
if (-not $ts.compilerOptions) { $ts | Add-Member -NotePropertyName compilerOptions -NotePropertyValue @{} -Force }
$ts.compilerOptions.resolveJsonModule = $true
($ts | ConvertTo-Json -Depth 20) | Set-Content $tsPath -Encoding UTF8

Say '==> Commitando e enviando'
git add -A
git commit -m 'fix(search): ajustar imports @/src -> @/ e habilitar resolveJsonModule' | Out-Null
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

Say '==> Search hotfix aplicado.'
