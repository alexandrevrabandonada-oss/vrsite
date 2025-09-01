# PowerShell - aplica correções dos arquivos deste pacote ao projeto
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Copy-Into {
  param($relPath)
  $src = Join-Path $here $relPath
  $dst = Join-Path (Get-Location) $relPath
  $dstDir = Split-Path $dst -Parent
  if (!(Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
  Copy-Item -Force $src $dst
  Write-Host "[ok]" $relPath
}

Copy-Into "src/components/PdfViewer.tsx"
Copy-Into "src/components/MangaReader.tsx"
Copy-Into "src/app/artigos/page.tsx"
Copy-Into "src/app/hqs/page.tsx"
Copy-Into "src/app/jogos/page.tsx"

if (Test-Path ".next") {
  Remove-Item -Recurse -Force ".next"
  Write-Host "[ok] cache .next removido"
}

Write-Host "`nTudo pronto."
Write-Host "1) npm run dev   # desenvolvimento"
Write-Host "2) npm run build # build de produção"