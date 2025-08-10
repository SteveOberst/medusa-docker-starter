# Medusa-Store: Docker Compose (backend + storefront)

This repo now includes a root-level `docker-compose.yml` that spins up:
- PostgreSQL (5432)
- Redis (6379)
- Medusa backend (9000)
 - Next.js storefront (8000)

## Quick start

```powershell
# From repo root
docker compose up --build
```

Then visit:
- Backend health: http://localhost:9000/health
- Storefront: http://localhost:8000

The storefront consumes the backend URL from `MEDUSA_BACKEND_URL` (default http://localhost:9000) and requires `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY`.

### Notes
- The backend service mounts `./backend` for fast dev iteration and uses your existing Dockerfile/start script.
- The storefront is a minimal Next.js app used as a placeholder. Replace it with your real storefront if you have one.
- Postgres credentials default to `postgres/postgres` and DB `medusa-store`. Override with env vars.

## Environment variables

Copy `.env.template` to `.env` at the root and adjust values as needed. Compose loads it automatically.

## Helper scripts (cross-platform)

- Windows PowerShell
	- `./docker-up.ps1` (add `-Rebuild` to force image rebuild)
	- `./docker-down.ps1` (add `-Prune` to also remove volumes)
	- `./docker-restart.ps1`

- Linux/macOS
	- `./docker-up.sh` (pass `--rebuild` to force image rebuild)
	- `./docker-down.sh` (pass `--prune` to also remove volumes)
	- `./docker-restart.sh`
 - Root scripts available: `docker-up.ps1`, `docker-down.ps1`, `docker-restart.ps1`.
 - Copy `.env.template` to `.env` at the root to customize variables.
