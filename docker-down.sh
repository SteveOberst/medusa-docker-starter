#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--prune" ]]; then
  read -r -p "This will remove Docker volumes and delete persisted data. Continue? (y/N) " answer
  case "$answer" in
    [yY][eE][sS]|[yY])
      docker compose down -v
      ;;
    *)
      echo "Aborted."
      exit 1
      ;;
  esac
else
  docker compose down
fi
