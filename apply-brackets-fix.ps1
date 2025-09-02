$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "backup-brackets-fix-$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

# Ensure git repo
git rev-parse --is-inside-work-tree *> $null

# Targets with bracketed paths
$targets = @(
  @{ dst = 'src/app/instagram/[id]/page.tsx'; src = 'payload/instagram_id_page.tsx' },
  @{ dst = 'src/app/diag/item/[id]/page.tsx'; src = 'payload/diag_item_id_page.tsx' },
  @{ dst = 'src/app/diag/ids/page.tsx'; src = 'payload/diag_ids_page.tsx' },
  @{ dst = 'src/app/diag/itemid/[id]/page.tsx'; src = 'payload/diag_item_id_page.tsx' }
)

foreach ($t in $targets) {
  $dstPath = Join-Path (Get-Location) $t.dst
  $srcPath = Join-Path (Get-Location) $t.src

  # Backup se existir
  if (Test-Path -LiteralPath $dstPath) {
    $bk = Join-Path $backup $t.dst
    New-Item -ItemType Directory -Force -Path (Split-Path $bk) | Out-Null
    Copy-Item -LiteralPath $dstPath -Destination $bk -Force
  }

  # Garante diretório e escreve usando System.IO (evita curingas)
  $dir = Split-Path $dstPath
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $content = Get-Content -LiteralPath $srcPath -Raw
  [System.IO.File]::WriteAllText($dstPath, $content, [System.Text.Encoding]::UTF8)
  Say "==> Gravado (literal) $($t.dst)"
}

git add -A
git commit -m "fix(windows): escreve rotas com [id] via caminho literal + alias /diag/itemid/[id]" | Out-Null
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = 'main' }
git push origin $branch

# Optional deploy hook
$hook = $null
if (Test-Path '.env.vercel') {
  foreach ($line in Get-Content '.env.vercel') {
    if ($line -match '^\s*VERCEL_DEPLOY_HOOK_URL\s*=\s*(.+)$') { $hook = $Matches[1].Trim() }
  }
}
if ($hook) {
  Say '==> Disparando Deploy Hook'
  try { Invoke-WebRequest -Method POST -Uri $hook -UseBasicParsing | Out-Null } catch { Warn 'Falha ao chamar Deploy Hook' }
} else {
  Warn 'Sem Deploy Hook — apenas push (Git integra com Vercel).'
}

Say '==> Bracket Paths Fix aplicado.'
