Write-Host "==> Corrigindo links do feed (removendo ?debug)..." -ForegroundColor Cyan
Get-ChildItem -Path "src" -Recurse -Include *.ts,*.tsx | ForEach-Object {
    (Get-Content $_.FullName) -replace "\?debug=?1?", "" | Set-Content $_.FullName
}

git add .
git commit -m "fix: remove '?debug' from instagram feed links" || Write-Host "Nenhuma alteração para commitar"

if ($env:VERCEL_DEPLOY_HOOK_URL) {
    Write-Host "==> Disparando redeploy no Vercel..." -ForegroundColor Green
    Invoke-WebRequest -Method Post -Uri $env:VERCEL_DEPLOY_HOOK_URL
} else {
    Write-Host "==> Deploy hook não configurado. Faça o deploy manual." -ForegroundColor Yellow
}
