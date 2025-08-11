#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root relative to this script and work there, regardless of invocation cwd
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Load .env if present to allow configuring STOREFRONT_REPO/REF and dirs without shell exports
if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ./.env
  set +a
fi

BACKEND_DIR=${BACKEND_DIR:-backend}
STOREFRONT_DIR=${STOREFRONT_DIR:-storefront}
STOREFRONT_REPO=${STOREFRONT_REPO:-https://github.com/medusajs/nextjs-starter-medusa}
STOREFRONT_REF=${STOREFRONT_REF:-main}
BACKEND_REPO=${BACKEND_REPO:-https://github.com/medusajs/medusa-starter-default}
BACKEND_REF=${BACKEND_REF:-main}

reset_dir() {
  local path=$1
  rm -rf "$path"
  mkdir -p "$path"
}

echo "Preparing backend directory: $BACKEND_DIR"
reset_dir "$BACKEND_DIR"
if [[ -n "$BACKEND_REPO" ]]; then
  echo "Cloning backend from ${BACKEND_REPO}@${BACKEND_REF} into ${BACKEND_DIR}"
  git clone --depth 1 --branch "$BACKEND_REF" "$BACKEND_REPO" "$BACKEND_DIR"
else
  echo "No BACKEND_REPO provided; falling back to BACKEND_INIT_CMD"
  # Initialize backend using Medusa create tool (configurable via BACKEND_INIT_CMD in .env)
  init_backend() {
    local cmd_template=${BACKEND_INIT_CMD:-"npx create-medusa-app@latest {dir}"}
    local cmd="$cmd_template"
    if [[ "$cmd" == *"{dir}"* ]]; then
      cmd="${cmd//\{dir\}/$BACKEND_DIR}"
    else
      cmd+=" $BACKEND_DIR"
    fi
    echo "Initializing backend using: $cmd"
    eval "$cmd"
  }
  init_backend
fi

echo "Bootstrapping storefront from ${STOREFRONT_REPO}@${STOREFRONT_REF} into ${STOREFRONT_DIR}"
reset_dir "$STOREFRONT_DIR"

git clone --depth 1 --branch "$STOREFRONT_REF" "$STOREFRONT_REPO" "$STOREFRONT_DIR"

"$SCRIPT_DIR"/apply-patches.sh "$BACKEND_DIR" "$STOREFRONT_DIR"

# Ensure .env exists based on .env.template if present
if [[ -f ".env.template" && ! -f ".env" ]]; then
  cp .env.template .env
  echo "Created .env from .env.template"
fi

echo "Bootstrap complete. Run: docker compose up --build"
