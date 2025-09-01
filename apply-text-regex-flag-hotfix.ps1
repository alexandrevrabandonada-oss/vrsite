$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-textregex-flag-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$files = Get-ChildItem -Path 'src' -Recurse -Include *.ts,*.tsx
$pattern = '/\[\\u0300-\\u036f\]/gu'
$changed = 0

foreach ($f in $files) {
  $p = $f.FullName
  $content = [System.IO.File]::ReadAllText($p)
  if ($content -match $pattern) {
    $rel = Resolve-Path -Relative $p
    $destBackup = Join-Path $backupDir $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $destBackup) | Out-Null
    Copy-Item -Path $p -Destination $destBackup -Force

    $new = $content -replace '/\[\\u0300-\\u036f\]/gu','/[\\u0300-\\u036f]/g'
    [System.IO.File]::WriteAllText($p, $new)
    Say "==> Removido flag 'u' em $rel"
    $changed++
  }
}

if ($changed -eq 0) { Warn "Nenhuma ocorrência '/[\\u0300-\\u036f]/gu' encontrada." }

Say '==> Commitando e enviando'
git add -A
git commit -m "fix(text): remover flag 'u' de /[\\u0300-\\u036f]/gu para compatibilidade ES5" | Out-Null
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

Say '==> Text Regex Flag Hotfix aplicado.'
