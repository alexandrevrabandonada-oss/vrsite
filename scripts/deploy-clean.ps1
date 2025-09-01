Write-Host "== VR Abandonada • Deploy LIMPO via Vercel CLI ==" -ForegroundColor Cyan
$vercel = (Get-Command vercel -ErrorAction SilentlyContinue)
if (-not $vercel) {
  Write-Error "Vercel CLI não encontrado. Instale com: npm i -g vercel"
  exit 1
}

if (Test-Path .next) { Remove-Item .next -Recurse -Force }

Write-Host "[2/4] npm ci" -ForegroundColor Yellow
npm ci || exit 1

Write-Host "[3/4] npm run build" -ForegroundColor Yellow
npm run build || exit 1

Write-Host "[4/4] vercel deploy --prebuilt --prod --force --yes" -ForegroundColor Yellow
vercel deploy --prebuilt --prod --force --yes || exit 1

Write-Host "`n[ok] Deploy enviado com rebuild forçado." -ForegroundColor Green
