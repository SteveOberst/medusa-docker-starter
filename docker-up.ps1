# Build and start all services in detached mode
param(
  [switch]$Rebuild
)
if ($Rebuild) {
  docker compose up --build -d
} else {
  docker compose up -d
}
