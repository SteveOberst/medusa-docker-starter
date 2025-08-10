# Stop and remove containers and network; optionally remove volumes with confirmation
param(
  [switch]$Prune
)
if ($Prune) {
  $answer = Read-Host "This will remove Docker volumes and delete persisted data. Continue? (y/N)"
  if ($answer -notin @('y','Y','yes','YES')) {
    Write-Host "Aborted."
    exit 1
  }
  docker compose down -v
} else {
  docker compose down
}
