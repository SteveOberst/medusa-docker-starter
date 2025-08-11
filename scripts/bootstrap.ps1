param(
  [string]$BackendDir = "backend",
  [string]$StorefrontDir = "storefront",
  [string]$StorefrontRepo = "https://github.com/medusajs/nextjs-starter-medusa",
  [string]$StorefrontRef = "master"
)

$ErrorActionPreference = "Stop"

function Reset-Dir($path) {
  if (Test-Path $path) { Remove-Item -Recurse -Force $path }
  New-Item -ItemType Directory -Path $path | Out-Null
}

# Backend: use current backend as baseline (or optionally scaffold a fresh one in the future)
Write-Host "Preparing backend directory: $BackendDir"
# For now we don't delete backend; users can refresh it manually if desired

# Storefront: clone starter (or custom repo)
Write-Host "Bootstrapping storefront from $StorefrontRepo@$StorefrontRef into $StorefrontDir"
Reset-Dir $StorefrontDir

git clone --depth 1 --branch $StorefrontRef $StorefrontRepo $StorefrontDir
if (-not $?) { throw "Failed to clone storefront" }

# Apply patches
Write-Host "Applying patches"
& ./scripts/apply-patches.ps1 -BackendDir $BackendDir -StorefrontDir $StorefrontDir

# Ensure .env exists based on .env.template if present
if (Test-Path ".env.template" -PathType Leaf) {
  if (-not (Test-Path ".env" -PathType Leaf)) {
    Copy-Item ".env.template" ".env"
    Write-Host "Created .env from .env.template"
  }
}

Write-Host "Bootstrap complete. You can now run 'docker compose up --build'"
