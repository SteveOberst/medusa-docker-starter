param(
  [string]$BackendDir = "backend",
  [string]$StorefrontDir = "storefront",
  [string]$StorefrontRepo = "https://github.com/medusajs/nextjs-starter-medusa",
  [string]$StorefrontRef = "main",
  [string]$BackendRepo = "https://github.com/medusajs/medusa-starter-default",
  [string]$BackendRef = "master"
)

$ErrorActionPreference = "Stop"

# Ensure we run from repo root regardless of invocation path
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$RepoRoot = Resolve-Path (Join-Path $ScriptDir '..')
Set-Location $RepoRoot

# Load .env if present so users can configure without passing parameters
if (Test-Path ".env" -PathType Leaf) {
  Get-Content ".env" | ForEach-Object {
    if (-not $_ -or $_.Trim().StartsWith('#')) { return }
    if ($_ -match '^[^=]+=.+') {
      $parts = $_ -split '=', 2
      $key = $parts[0].Trim()
      $val = $parts[1]
      # strip optional surrounding quotes
      if ($val.StartsWith('"') -and $val.EndsWith('"')) { $val = $val.Trim('"') }
      elseif ($val.StartsWith("'") -and $val.EndsWith("'")) { $val = $val.Trim("'") }
      $env:$key = $val
    }
  }
  # Override defaults with env vars only if parameters were not explicitly provided
  if (-not $PSBoundParameters.ContainsKey('BackendDir') -and $env:BACKEND_DIR) { $BackendDir = $env:BACKEND_DIR }
  if (-not $PSBoundParameters.ContainsKey('StorefrontDir') -and $env:STOREFRONT_DIR) { $StorefrontDir = $env:STOREFRONT_DIR }
  if (-not $PSBoundParameters.ContainsKey('StorefrontRepo') -and $env:STOREFRONT_REPO) { $StorefrontRepo = $env:STOREFRONT_REPO }
  if (-not $PSBoundParameters.ContainsKey('StorefrontRef') -and $env:STOREFRONT_REF) { $StorefrontRef = $env:STOREFRONT_REF }
  if (-not $PSBoundParameters.ContainsKey('BackendRepo') -and $env:BACKEND_REPO) { $BackendRepo = $env:BACKEND_REPO }
  if (-not $PSBoundParameters.ContainsKey('BackendRef') -and $env:BACKEND_REF) { $BackendRef = $env:BACKEND_REF }
}

function Reset-Dir($path) {
  if (Test-Path $path) { Remove-Item -Recurse -Force $path }
  New-Item -ItemType Directory -Path $path | Out-Null
}

# Backend: reset and either clone starter repo or initialize using create tool
Write-Host "Preparing backend directory: $BackendDir"
Reset-Dir $BackendDir
if ($BackendRepo) {
  Write-Host "Cloning backend from $BackendRepo@$BackendRef into $BackendDir"
  git clone --depth 1 --branch $BackendRef $BackendRepo $BackendDir
  if (-not $?) { throw "Failed to clone backend" }
} else {
  function Initialize-Backend([string]$dir) {
    $cmdTemplate = if ($env:BACKEND_INIT_CMD) { $env:BACKEND_INIT_CMD } else { 'npx create-medusa-app@latest {dir}' }
    if ($cmdTemplate -like '*{dir}*') { $cmd = $cmdTemplate.Replace('{dir}', $dir) } else { $cmd = "$cmdTemplate $dir" }
    Write-Host "Initializing backend using: $cmd"
    Invoke-Expression $cmd
  }
  Initialize-Backend $BackendDir
}

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
