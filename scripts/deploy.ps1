Param(
  [string]$Message = "chore(deploy): deploy rapido $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)
Write-Host "== VR Abandonada • Deploy via Git ==" -ForegroundColor Cyan
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Este diretório não é um repositório git."
  exit 1
}

git add -A
git commit -m $Message 2>$null
git push
Write-Host "`nSe o projeto esta conectado ao Vercel (Git-based), o deploy inicia automaticamente."
