@echo off
echo === Deploy VR Abandonada (CMD) ===
git add .
git commit -m "Deploy automático VR Abandonada"
git push
echo.
echo [OK] Alterações enviadas para o Git.
echo O Vercel deve iniciar o deploy automaticamente.
pause
