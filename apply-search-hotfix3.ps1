$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

# 1) Corrigir imports "@/src/" -> "@/"
$files = Get-ChildItem -Path 'src' -Recurse -Include *.ts,*.tsx
foreach ($f in $files) {
  $p = $f.FullName
  $content = [System.IO.File]::ReadAllText($p)
  $new = $content.Replace('@/src/','@/')
  if ($new -ne $content) {
    [System.IO.File]::WriteAllText($p, $new)
    Say "==> Corrigido import em $p"
  }
}

# 2) tsconfig.json: resolveJsonModule = true (sem depender de ConvertFrom-Json)
$tsPath = Join-Path (Get-Location) 'tsconfig.json'
if (Test-Path $tsPath) {
  $json = [System.IO.File]::ReadAllText($tsPath)
  if ($json -notmatch '"resolveJsonModule"\s*:\s*true') {
    if ($json -match '"compilerOptions"\s*:\s*{') {
      $json = $json -replace '"compilerOptions"\s*:\s*{', '"compilerOptions": { "resolveJsonModule": true,'
    } else {
      # adiciona bloco mínimo
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
git commit -m 'fix(search): compat PS, ajustar imports @/src -> @/ e habilitar resolveJsonModule' | Out-Null
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

Say '==> Search hotfix v3 aplicado.'
