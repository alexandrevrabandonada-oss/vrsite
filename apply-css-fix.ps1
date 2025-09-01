\
# Apply clean CSS/PostCSS/Tailwind config
param()

$ErrorActionPreference = "Stop"

$root = Get-Location
$srcCss = Join-Path $PSScriptRoot "src_app_globals.css"
$dstCss = Join-Path $root "src\app\globals.css"

$postcssSrc = Join-Path $PSScriptRoot "postcss.config.js"
$postcssDst = Join-Path $root "postcss.config.js"

$tailwindSrc = Join-Path $PSScriptRoot "tailwind.config.js"
$tailwindDst = Join-Path $root "tailwind.config.js"

# Ensure folders
$dstDir = Split-Path $dstCss -Parent
if (!(Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }

Copy-Item $srcCss $dstCss -Force
Copy-Item $postcssSrc $postcssDst -Force
Copy-Item $tailwindSrc $tailwindDst -Force

# Clean .next cache to avoid stale pipeline
$nextDir = Join-Path $root ".next"
if (Test-Path $nextDir) { Remove-Item $nextDir -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host "[ok] globals.css, postcss.config.js e tailwind.config.js atualizados."
Write-Host "Passos:"
Write-Host "1) npm i -D tailwindcss postcss autoprefixer"
Write-Host "2) npm run dev   (ou npm run build)"
