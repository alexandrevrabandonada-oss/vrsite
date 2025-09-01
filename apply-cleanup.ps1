$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

# 1) Corrigir imports (por garantia)
$targets = @('src\app\robots.ts','src\app\sitemap.ts')
foreach ($t in $targets) {
  if (Test-Path $t) {
    $content = Get-Content $t -Raw
    $new = $content -replace "@/src/lib/seo","@/lib/seo"
    if ($new -ne $content) {
      Say "==> Corrigindo import em $t"
      Set-Content -Path $t -Value $new -Encoding UTF8
    }
  }
}

# 2) Atualizar .gitignore
$gi = '.gitignore'
$need = @("backup-*/", ".backups/")
$giContent = ""
if (Test-Path $gi) { $giContent = Get-Content $gi -Raw } else { $giContent = "" }
foreach ($pat in $need) {
  if ($giContent -notmatch [Regex]::Escape($pat)) {
    $giContent += "`n$pat"
  }
}
Set-Content -Path $gi -Value $giContent -Encoding UTF8

# 3) Atualizar tsconfig.json (exclude)
$tsPath = 'tsconfig.json'
if (Test-Path $tsPath) {
  $ts = ConvertFrom-Json (Get-Content $tsPath -Raw)
} else {
  $ts = ConvertFrom-Json '{"compilerOptions":{}}'
}
if (-not $ts.exclude) { $ts | Add-Member -NotePropertyName exclude -NotePropertyValue @() -Force }
# garantir arrays
if ($ts.exclude.GetType().Name -ne 'Object[]') { $ts.exclude = @($ts.exclude) }
$addEx = @("**/backup-*/**",".backups/**")
foreach ($e in $addEx) {
  if (-not ($ts.exclude -contains $e)) { $ts.exclude += $e }
}
($ts | ConvertTo-Json -Depth 20) | Set-Content $tsPath -Encoding UTF8

# 4) Remover pastas backup-* do working tree e do histórico atual (commit de remoção)
$removed = @()
Get-ChildItem -Directory -Filter "backup-*" | ForEach-Object {
  $dir = $_.FullName
  Say "==> Removendo $_"
  git rm -r --cached --ignore-unmatch --quiet $_.Name | Out-Null
  Remove-Item -Recurse -Force $_
  $removed += $_.Name
}

# 5) Opcional: mover para .backups/ (neste cleanup apenas removemos)

# 6) Commit + push
Say '==> Commitando e enviando'
git add -A
git commit -m 'chore(cleanup): excluir backups do repo, ajustar ignore e tsconfig' | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = 'main' }
git push origin $branch

# 7) Deploy Hook opcional
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

Say '==> Cleanup aplicado.'
