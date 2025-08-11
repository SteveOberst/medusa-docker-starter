param(
  [string]$BackendDir = "backend",
  [string]$StorefrontDir = "storefront"
)

$ErrorActionPreference = "Stop"

function Copy-Patch($src, $dest) {
  if (Test-Path $src) {
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
    Write-Host "Applying patch from '$src' to '$dest'"
    Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force -ErrorAction Stop
  } else {
    Write-Host "No patch directory found at '$src' — skipping"
  }
}

Copy-Patch -src (Join-Path "patch" "backend") -dest $BackendDir
Copy-Patch -src (Join-Path "patch" "storefront") -dest $StorefrontDir

Write-Host "Patches applied."
