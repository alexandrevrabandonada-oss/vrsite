Write-Host "=== Deploy VR Abandonada (PowerShell) ===" -ForegroundColor Green

git add .
git commit -m "Deploy automático VR Abandonada"
git push

Write-Host "`n[OK] Alterações enviadas para o Git." -ForegroundColor Cyan
Write-Host "O Vercel deve iniciar o deploy automaticamente." -ForegroundColor Yellow
