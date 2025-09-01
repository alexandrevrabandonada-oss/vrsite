Write-Host "== VR Abandonada :: Atualizar TOKEN LONGO (Instagram Basic Display) ==" -ForegroundColor Cyan

$envPath = ".env.local"
if (-not (Test-Path $envPath)) {
  Write-Host "[ERRO] .env.local não encontrado. Rode scripts\ig-exchange.cmd antes." -ForegroundColor Red
  exit 1
}

$envText = Get-Content $envPath -Raw
function GetKV([string]$content, [string]$key) {
  $m = [Regex]::Match($content, "^{0}=(.*)$" -f [Regex]::Escape($key), 'Multiline')
  if ($m.Success) { return $m.Groups[1].Value.Trim() } else { return $null }
}

$long = GetKV $envText "IG_ACCESS_TOKEN"
if (-not $long) {
  Write-Host "[ERRO] IG_ACCESS_TOKEN ausente no .env.local" -ForegroundColor Red
  exit 1
}

$refreshUrl = "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=$long"

try {
  Write-Host "Atualizando token..." -ForegroundColor Yellow
  $res = Invoke-RestMethod -Method Get -Uri $refreshUrl -TimeoutSec 30
} catch {
  Write-Host "[ERRO] Falha ao atualizar token: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

$newToken = $res.access_token
if ($newToken) {
  $envText = [Regex]::Replace($envText, "^IG_ACCESS_TOKEN=.*$", "IG_ACCESS_TOKEN=$newToken", 'Multiline')
  Set-Content -Path $envPath -Value $envText -Encoding UTF8
  Write-Host ("OK: Token atualizado (preview): {0}...{1}" -f $newToken.Substring(0,6), $newToken.Substring($newToken.Length-6)) -ForegroundColor Green
} else {
  Write-Host "Aviso: resposta sem access_token. Conteúdo:" -ForegroundColor Yellow
  Write-Host ($res | ConvertTo-Json -Depth 5)
}

Write-Host "Teste em /me..." -ForegroundColor Yellow
try {
  $me = Invoke-RestMethod -Method Get -Uri "https://graph.instagram.com/me?fields=id,username&access_token=$newToken" -TimeoutSec 30
  Write-Host "OK: $($me.username) ($($me.id))" -ForegroundColor Green
} catch {
  Write-Host "[ALERTA] Não foi possível validar /me (talvez taxa/instabilidade), mas o .env.local foi escrito." -ForegroundColor Yellow
}

Write-Host "Concluído." -ForegroundColor Cyan
