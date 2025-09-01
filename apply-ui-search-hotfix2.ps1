$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host '[ERRO] ' + $m -ForegroundColor Red; exit 1 }

if (-not (Test-Path '.git')) { Fail 'Este diretorio nao parece ser um repo Git (.git ausente).' }
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { Fail 'Nao eh um repo Git valido.' }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = 'backup-ui-hotfix2-' + $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$homeFile = 'src\app\page.tsx'
if (-not (Test-Path $homeFile)) {
  Warn "Nao encontrei $homeFile. Nada a fazer."
  exit 0
}

# Backup
$rel = Resolve-Path -Relative $homeFile
$destBackup = Join-Path $backupDir $rel
New-Item -ItemType Directory -Force -Path (Split-Path $destBackup) | Out-Null
Copy-Item -Path $homeFile -Destination $destBackup -Force

# Read
[string]$txt = [System.IO.File]::ReadAllText($homeFile)

# Ensure import (checa por aspas simples ou duplas)
if (-not ($txt.Contains("from '@/components/HomeSearchBar'") -or $txt.Contains('from "@/components/HomeSearchBar"'))) {
  $txt = "import HomeSearchBar from '@/components/HomeSearchBar'" + [Environment]::NewLine + $txt
}

# Insert component antes de <main>, uma única vez
$idx = $txt.IndexOf("<main")
if ($idx -ge 0) {
  $before = $txt.Substring(0, $idx)
  $after  = $txt.Substring($idx)
  $txt = $before + "<HomeSearchBar />`n" + $after
} else {
  # Se não houver <main>, tenta após 'return ('
  $ret = $txt.IndexOf("return (")
  if ($ret -ge 0) {
    $afterRet = $ret + ("return (").Length
    $before = $txt.Substring(0, $afterRet)
    $after  = $txt.Substring($afterRet)
    $txt = $before + "`n  <HomeSearchBar />" + $after
  } else {
    # fallback: adiciona no topo do arquivo
    $txt = "<HomeSearchBar />`n" + $txt
  }
}

[System.IO.File]::WriteAllText($homeFile, $txt, [System.Text.Encoding]::UTF8)
Say "==> HomeSearchBar injetado em src/app/page.tsx"

Say '==> Commitando e enviando'
git add -A
git commit -m 'fix(ui): injetar HomeSearchBar sem regex problematica e evitar $HOME' | Out-Null
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

Say '==> UI Search Hotfix v2 aplicado.'
