# fix-imports-hard.ps1
# Força a correção de imports "@/src/*" => "@/*", cria src/lib/baseUrl.ts,
# e injeta/normaliza aliases no tsconfig.json

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[info]" $msg -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "[ok]  " $msg -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[warn]" $msg -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[err]" $msg -ForegroundColor Red }

# 0) Sanity: garanta que está no root (tem package.json)
if (-not (Test-Path ".\package.json")) {
  Write-Err "Execute este script na raiz do projeto (onde está 'package.json')."
  exit 1
}

# 1) Cria/atualiza src/lib/baseUrl.ts
$libDir = "src\lib"
if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir | Out-Null }

$baseUrlPath = "src\lib\baseUrl.ts"
$baseUrlContent = @'
export function getBaseUrl() {
  // 1) Prioriza variável pública (útil no Vercel e local)
  if (process.env.NEXT_PUBLIC_SITE_URL) {
    return process.env.NEXT_PUBLIC_SITE_URL.replace(/\/+$/, "");
  }

  // 2) Ambiente Vercel
  const vercelUrl =
    process.env.VERCEL_URL ||
    process.env.NEXT_PUBLIC_VERCEL_URL ||
    "";
  if (vercelUrl) {
    const url = vercelUrl.startsWith("http")
      ? vercelUrl
      : `https://${vercelUrl}`;
    return url.replace(/\/+$/, "");
  }

  // 3) Localhost
  const port = process.env.PORT || 3000;
  return `http://localhost:${port}`;
}
'@

Set-Content -LiteralPath $baseUrlPath -Value $baseUrlContent -Encoding UTF8
Write-Ok "Atualizado $baseUrlPath"

# 2) Corrige imports "@/src/..." => "@/..."
$changed = 0
$files = Get-ChildItem -Recurse -Path .\src -Include *.ts,*.tsx `
  | Where-Object { $_.FullName -notmatch "\\(node_modules|\.next)\\" }

foreach ($f in $files) {
  $text = Get-Content -LiteralPath $f.FullName -Raw

  $orig = $text

  # Regras específicas primeiro para evitar cascata errada
  $text = $text -replace "@\/src\/lib\/baseUrl", "@/lib/baseUrl"
  $text = $text -replace "@\/src\/components",   "@/components"
  $text = $text -replace "@\/src\/lib",          "@/lib"

  # Regras gerais (strings com aspas)
  $text = $text -replace '"@\/src\/', '"@/'
  $text = $text -replace "'@\/src\/", "'@/"

  if ($text -ne $orig) {
    Set-Content -LiteralPath $f.FullName -Value $text -Encoding UTF8
    $changed++
    Write-Ok "Corrigido: $($f.FullName)"
  }
}

Write-Info ("Arquivos alterados: {0}" -f $changed)

# 3) Normaliza tsconfig.json (baseUrl e paths)
$tsPath = "tsconfig.json"
if (Test-Path $tsPath) {
  try {
    $json = Get-Content $tsPath -Raw | ConvertFrom-Json
  } catch {
    Write-Err "Falha ao ler tsconfig.json como JSON. Ajuste manualmente se necessário."
    $json = $null
  }

  if ($null -ne $json) {
    if ($null -eq $json.compilerOptions) { $json | Add-Member -NotePropertyName "compilerOptions" -NotePropertyValue (@{}) }

    $json.compilerOptions.baseUrl = "."
    if ($null -eq $json.compilerOptions.paths) { $json.compilerOptions.paths = @{} }
    $json.compilerOptions.paths."@/*" = @("src/*")

    # recomendações mínimas para Next
    $json.compilerOptions.esModuleInterop   = $true
    $json.compilerOptions.moduleResolution  = "node"
    $json.compilerOptions.resolveJsonModule = $true
    $json.compilerOptions.isolatedModules   = $true
    if ($null -eq $json.compilerOptions.skipLibCheck) { $json.compilerOptions.skipLibCheck = $true }
    if ($null -eq $json.compilerOptions.strict)       { $json.compilerOptions.strict = $false }

    if ($null -eq $json.include) {
      $json.include = @("next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts")
    }

    $json | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $tsPath -Encoding UTF8
    Write-Ok "Atualizado $tsPath (aliases + opções Next)"
  }
} else {
  Write-Warn "tsconfig.json não encontrado. Pulei ajustes de alias."
}

# 4) Relatório de sobras (se ainda existe '@/src/' em src/)
$leftovers = Get-ChildItem -Recurse -Path .\src -Include *.ts,*.tsx `
  | Where-Object { $_.FullName -notmatch "\\(node_modules|\.next)\\" } `
  | Select-String -Pattern "@/src/" -SimpleMatch

if ($leftovers) {
  Write-Warn "Ainda existem imports '@/src/' nestes arquivos/linhas:"
  $leftovers | ForEach-Object { Write-Host " - $($_.Path):$($_.LineNumber)  $($_.Line.Trim())" -ForegroundColor Yellow }
} else {
  Write-Ok "Sem restos de '@/src/' encontrados."
}

Write-Host "`nTudo pronto. Agora execute:" -ForegroundColor Cyan
Write-Host "  rmdir /s /q .next" -ForegroundColor White
Write-Host "  npm run build" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
