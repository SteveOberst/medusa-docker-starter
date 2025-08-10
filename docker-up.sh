#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--rebuild" ]]; then
  docker compose up --build -d
else
  docker compose up -d
fi
