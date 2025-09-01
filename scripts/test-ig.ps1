$ErrorActionPreference = "Stop"
$BASE = $env:INSTAGRAM_GRAPH_BASE
if (-not $BASE) { $BASE = "https://graph.facebook.com/v20.0" }

$TOKEN = $env:IG_ACCESS_TOKEN
$UID = $env:IG_USER_ID

if (-not $TOKEN -or -not $UID) {
  Write-Host "ERRO: Faltam IG_ACCESS_TOKEN e/ou IG_USER_ID no ambiente (.env.local)."
  exit 1
}

Write-Host "Teste /me:"
try {
  $me = Invoke-RestMethod -Method Get -Uri "$BASE/me?fields=id,name&access_token=$TOKEN"
  $me | ConvertTo-Json -Depth 6 | Write-Host
} catch { Write-Host $_.ErrorDetails.Message }

Write-Host "`nTeste IG user:"
try {
  $ig = Invoke-RestMethod -Method Get -Uri "$BASE/$UID?fields=id,username,media_count&access_token=$TOKEN"
  $ig | ConvertTo-Json -Depth 6 | Write-Host
} catch { Write-Host $_.ErrorDetails.Message }

Write-Host "`nTeste /media (3 itens):"
try {
  $media = Invoke-RestMethod -Method Get -Uri "$BASE/$UID/media?fields=id,caption,media_type,media_url,thumbnail_url,timestamp,permalink&limit=3&access_token=$TOKEN"
  $media | ConvertTo-Json -Depth 6 | Write-Host
} catch { Write-Host $_.ErrorDetails.Message }
