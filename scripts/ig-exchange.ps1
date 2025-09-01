Param(
  [string]$AppSecret,
  [string]$ShortToken
)

Write-Host "== VR Abandonada :: Gerar TOKEN LONGO (Instagram Basic Display) ==" -ForegroundColor Cyan

if (-not $ShortToken) {
  $ShortToken = Read-Host "Cole aqui o TOKEN CURTO (sem aspas)"
}
if (-not $AppSecret) {
  $AppSecret = Read-Host "Cole aqui o APP SECRET (Facebook/Instagram)"
}

$ShortToken = $ShortToken.Trim()
$AppSecret = $AppSecret.Trim()

if ($ShortToken.Length -lt 30) {
  Write-Host "[ERRO] Token curto vazio ou inválido." -ForegroundColor Red
  exit 1
}

$exchangeUrl = "https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=$AppSecret&access_token=$ShortToken"

try {
  Write-Host "Trocando por token LONGO..." -ForegroundColor Yellow
  $res = Invoke-RestMethod -Method Get -Uri $exchangeUrl -TimeoutSec 30
} catch {
  Write-Host "[ERRO] Falha ao chamar IG exchange: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

$LongToken = $res.access_token
if (-not $LongToken) {
  Write-Host "[ERRO] Resposta sem access_token:" -ForegroundColor Red
  Write-Host ($res | ConvertTo-Json -Depth 5)
  exit 1
}

Write-Host ("OK: Token LONGO (preview): {0}...{1}" -f $LongToken.Substring(0,6), $LongToken.Substring($LongToken.Length-6)) -ForegroundColor Green

# Validar e obter IG_USER_ID
$meUrl = "https://graph.instagram.com/me?fields=id,username&access_token=$LongToken"
try {
  Write-Host "Validando token em /me..." -ForegroundColor Yellow
  $me = Invoke-RestMethod -Method Get -Uri $meUrl -TimeoutSec 30
} catch {
  Write-Host "[ERRO] Falha ao validar token em /me: $($_.Exception.Response.GetResponseStream() | % { (New-Object System.IO.StreamReader($_)).ReadToEnd() })" -ForegroundColor Red
  exit 1
}

$igId = $me.id
$igUser = $me.username
if (-not $igId) {
  Write-Host "[ERRO] Não foi possível obter IG_USER_ID." -ForegroundColor Red
  exit 1
}

# Escrever .env.local (na pasta atual)
$envPath = ".env.local"
$lines = @()
if (Test-Path $envPath) {
  $lines = Get-Content $envPath -Raw
}

function UpsertKV([string]$content, [string]$key, [string]$value) {
  $pattern = "^{0}=.*$" -f [Regex]::Escape($key)
  if ($content -match $pattern) {
    return [Regex]::Replace($content, $pattern, "$key=$value", 'Multiline')
  } else {
    $sep = ($content.Trim().Length -gt 0) ? "`r`n" : ""
    return "$content$sep$key=$value`r`n"
  }
}

$content = if ($lines) { $lines } else { "" }
$content = UpsertKV $content "IG_ACCESS_TOKEN" $LongToken
$content = UpsertKV $content "IG_USER_ID" $igId
$content = UpsertKV $content "INSTAGRAM_GRAPH_BASE" "https://graph.instagram.com"

Set-Content -Path $envPath -Value $content -Encoding UTF8
Write-Host "Salvo .env.local com IG_ACCESS_TOKEN e IG_USER_ID ($igUser / $igId)." -ForegroundColor Green

Write-Host "Teste rápido do feed (primeiro item)..." -ForegroundColor Yellow
$feedUrl = "https://graph.instagram.com/$igId/media?fields=id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username,children{media_type,media_url,thumbnail_url}&limit=1&access_token=$LongToken"
try {
  $feed = Invoke-RestMethod -Method Get -Uri $feedUrl -TimeoutSec 30
  if ($feed.data.Count -gt 0) {
    Write-Host "OK: Feed retornou ao menos 1 item." -ForegroundColor Green
  } else {
    Write-Host "Atenção: feed vazio (sem itens)." -ForegroundColor Yellow
  }
} catch {
  Write-Host "[ALERTA] Falha ao consultar feed, mas .env.local está gravado." -ForegroundColor Yellow
}

Write-Host "Pronto. Rode 'npm run dev' e acesse /api/instagram/debug." -ForegroundColor Cyan
