\
  # scripts/refresh-ig-token.ps1
  <#
    Refresh a LONG-LIVED Instagram Graph token (90 days) using:
    GET https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token={long-lived}

    Usage:
      - Run from project root:  scripts\refresh-ig-token.cmd
      - Paste your LONG-LIVED token when prompted (no quotes).
  #>

  $ErrorActionPreference = "Stop"
  $base = "https://graph.instagram.com"
  $token = $env:IG_ACCESS_TOKEN

  if (-not $token -or $token.Trim().Length -lt 50) {
    Write-Host "Cole o TOKEN LONGO atual (sem aspas) e pressione Enter:" -ForegroundColor Yellow
    $token = Read-Host
  }

  $token = $token.Trim('"').Trim()
  if ($token.Length -lt 50) {
    Write-Error "Token muito curto. Aborting."
  }

  $url = "$base/refresh_access_token?grant_type=ig_refresh_token&access_token=$token"
  Write-Host "Chamando refresh..." -ForegroundColor Cyan
  try {
    $res = Invoke-RestMethod -Method Get -Uri $url -TimeoutSec 20
  } catch {
    Write-Error "Falha no refresh: $($_.Exception.Message)"
    throw
  }

  if (-not $res.access_token) {
    Write-Host "Resposta:" ($res | ConvertTo-Json -Depth 5)
    Write-Error "Resposta sem access_token. Nada atualizado."
  }

  $newToken = $res.access_token
  $preview = $newToken.Substring(0,6) + "..." + $newToken.Substring($newToken.Length-6,6)
  Write-Host ("OK: Novo token (preview): {0}" -f $preview) -ForegroundColor Green

  $dotenv = ".env.local"
  if (Test-Path $dotenv) {
    $content = Get-Content $dotenv -Raw
  } else {
    $content = ""
  }

  # Replace or append IG_ACCESS_TOKEN=...
  $pattern = '(?m)^IG_ACCESS_TOKEN\s*=\s*.*$'
  if ($content -match $pattern) {
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, ("IG_ACCESS_TOKEN={0}" -f $newToken))
  } else {
    $sep = ""
    if ($content.Trim().Length -gt 0) { $sep = "`n" }
    $content = $content + $sep + ("IG_ACCESS_TOKEN={0}" -f $newToken) + "`n"
  }
  Set-Content -LiteralPath $dotenv -Value $content -Encoding UTF8
  Write-Host "Atualizado IG_ACCESS_TOKEN em .env.local" -ForegroundColor Green

  Write-Host "`nDica: Rode 'npm run dev' novamente para recarregar variáveis." -ForegroundColor Gray
