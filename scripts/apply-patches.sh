#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR=${1:-backend}
STOREFRONT_DIR=${2:-storefront}

copy_patch() {
  local src=$1
  local dest=$2
  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    echo "Applying patch from '$src' to '$dest'"
    cp -R "$src"/* "$dest"/
  else
    echo "No patch directory found at '$src' — skipping"
  fi
}

copy_patch "patch/backend" "$BACKEND_DIR"
copy_patch "patch/storefront" "$STOREFRONT_DIR"

echo "Patches applied."
