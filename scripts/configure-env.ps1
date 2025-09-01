Param(
  [string]$TokenLongo,
  [string]$IgUserId
)

$ErrorActionPreference = "Stop"

function Read-Input($prompt){
  Write-Host -NoNewline $prompt
  return Read-Host
}

if (-not $TokenLongo) {
  $TokenLongo = Read-Input "Cole o IG_ACCESS_TOKEN LONGO (sem aspas/linhas): "
}
$TokenLongo = $TokenLongo.Trim()

if (-not $IgUserId) {
  $IgUserId = Read-Input "Cole o IG_USER_ID (ex.: 1784...): "
}
$IgUserId = $IgUserId.Trim()

$BASE = "https://graph.facebook.com/v20.0"

Write-Host "Validando token em $BASE/me?fields=id,name ..."
try {
  $me = Invoke-RestMethod -Method Get -Uri "$BASE/me?fields=id,name&access_token=$TokenLongo"
  Write-Host "OK: me.id=$($me.id) name=$($me.name)"
} catch {
  Write-Host "[ERRO] /me => $($_.Exception.Message)"
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  Write-Host "Dica: gere um token LONGO válido (Instagram Graph / Facebook Graph OAuth) e tente novamente."
  exit 1
}

Write-Host "Validando IG_USER em $BASE/$IgUserId?fields=id,username,media_count ..."
try {
  $ig = Invoke-RestMethod -Method Get -Uri "$BASE/$IgUserId?fields=id,username,media_count&access_token=$TokenLongo"
  Write-Host ("OK: IG id={0} username={1} media_count={2}" -f $ig.id, $ig.username, $ig.media_count)
} catch {
  Write-Host "[ERRO] IG_USER => $($_.Exception.Message)"
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  Write-Host "Dica: confira o IG_USER_ID (precisa ser conta Profissional conectada à sua Página)."
  exit 1
}

Write-Host "Testando mídia ($BASE/$IgUserId/media?limit=3) ..."
try {
  $media = Invoke-RestMethod -Method Get -Uri "$BASE/$IgUserId/media?fields=id,caption,media_type,media_url,thumbnail_url,timestamp,permalink&limit=3&access_token=$TokenLongo"
  $count = ($media.data | Measure-Object).Count
  Write-Host "OK: recebidos $count itens."
} catch {
  Write-Host "[ALERTA] Falha na listagem de mídia (pode ser normal se a conta tiver 0 posts)."
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
}

$envPath = Join-Path (Get-Location) ".env.local"
$envText = @"
# === VR Abandonada (.env.local) ===
# Gerado automaticamente por scripts/configure-env.ps1
IG_ACCESS_TOKEN=$TokenLongo
IG_USER_ID=$IgUserId
INSTAGRAM_GRAPH_BASE=$BASE
"@

Set-Content -Path $envPath -Value $envText -NoNewline -Encoding UTF8
Write-Host "[ok] .env.local escrito em $envPath"

Write-Host ""
Write-Host "Pronto! Próximos passos:"
Write-Host "  1) npm run dev  (ou vercel build)"
Write-Host "  2) Teste: http://localhost:3000/api/instagram?limit=3&raw=1"
Write-Host "  3) Página: /instagram"
