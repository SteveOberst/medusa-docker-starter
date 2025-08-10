#!/bin/bash
# Simple readiness check for the Medusa backend in CI
# Tries up to 6 times (30s total) to get a non-000 HTTP code from /store/products

set -euo pipefail

for i in {1..6}; do
  echo "Attempt $i/6"
  status_code=$(curl \
    -X GET \
    --write-out %{http_code} \
    --silent \
    --output /dev/null \
    http://localhost:9000/store/products || true)

  echo "HTTP: $status_code"
  if [[ "$status_code" != "000" ]]; then
    echo "Backend is responding"
    exit 0
  fi
  sleep 5
done

echo "Timed out waiting for backend"
exit 1
