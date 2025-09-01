\
# Apply path alias fixes and ensure tsconfig paths exist
param(
  [string]$ProjectRoot = "."
)

Write-Host "== VR Abandonada • Apply path alias fix =="

function Replace-InFiles {
  param([string]$root, [string]$pattern, [string]$replacement)
  $files = Get-ChildItem -Path $root -Recurse -Include *.ts,*.tsx,*.js,*.jsx -File | Where-Object {
    (Get-Content $_.FullName -Raw) -match [regex]::Escape($pattern)
  }
  foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $new = $content.Replace($pattern, $replacement)
    if ($new -ne $content) {
      Set-Content -Path $file.FullName -Value $new -Encoding UTF8
      Write-Host "[fix] $($file.FullName) : '$pattern' -> '$replacement'"
    }
  }
}

# 2.1) Fix bad imports "@/src/..." -> "@/..."
$src = Join-Path $ProjectRoot "src"
if (-not (Test-Path $src)) {
  Write-Error "src folder not found at $src"
  exit 1
}

# Replace common wrong patterns
Replace-InFiles -root $src -pattern "@/src/components/" -replacement "@/components/"
Replace-InFiles -root $src -pattern "@/src/lib/" -replacement "@/lib/"

# 2.2) Ensure tsconfig.json has correct "paths"
$tsconfig = Join-Path $ProjectRoot "tsconfig.json"
if (Test-Path $tsconfig) {
  $json = Get-Content $tsconfig -Raw | ConvertFrom-Json
  if (-not $json.compilerOptions) { $json | Add-Member -NotePropertyName compilerOptions -NotePropertyValue (@{}) }
  if (-not $json.compilerOptions.baseUrl) { $json.compilerOptions.baseUrl = "." }
  if (-not $json.compilerOptions.paths) { $json.compilerOptions.paths = @{} }

  $paths = $json.compilerOptions.paths
  $changed = $false

  if (-not $paths."@/*") { $paths."@/*" = @("src/*"); $changed = $true }
  if (-not $paths."@/components/*") { $paths."@/components/*" = @("src/components/*"); $changed = $true }
  if (-not $paths."@/lib/*") { $paths."@/lib/*" = @("src/lib/*"); $changed = $true }

  if ($changed) {
    $json | ConvertTo-Json -Depth 10 | Out-File -FilePath $tsconfig -Encoding UTF8
    Write-Host "[ok] tsconfig.json updated with paths aliases"
  } else {
    Write-Host "[ok] tsconfig.json paths already OK"
  }
} else {
  Write-Warning "tsconfig.json not found, skipping alias check."
}

Write-Host "Done. Now run: npm run build   (or)   npm run dev"
