## Overview

One-command dev environment for Medusa v2 backend and a Next.js storefront using Docker Compose.

Services:
- PostgreSQL (5432)
- Redis (6379)
- Medusa backend (9000)
- Next.js storefront (8000)

## Prerequisites
- Docker Desktop
- Node 20+ installed locally only if you run apps outside Docker (optional)

## Setup
1) Copy env template and customize:
```powershell
Copy-Item .env.template .env
```

Key vars:
- Database: POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- Backend: JWT_SECRET, COOKIE_SECRET, STORE_CORS, ADMIN_CORS, AUTH_CORS
- Storefront: MEDUSA_BACKEND_URL (default http://medusa:9000 in Docker network), NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
- Misc: NODE_ENV (development|production), SEED_DB (false by default)

## Run
```powershell
docker compose up --build
```

Open:
- Backend health: http://localhost:9000/health
- Storefront: http://localhost:8000

## Helper scripts (Windows/macOS/Linux)
- Windows PowerShell
	- ./docker-up.ps1 [-Rebuild]
	- ./docker-down.ps1 [-Prune]
	- ./docker-restart.ps1
- Bash
	- ./docker-up.sh [--rebuild]
	- ./docker-down.sh [--prune]
	- ./docker-restart.sh

## CI/CD
GitHub Actions run backend CI on PRs:
- Install deps, build, run DB migrations
- Optionally seeds if src/scripts/seed.ts exists
- Starts backend and waits for readiness

Workflows:
- .github/workflows/test-cli.yml
- .github/workflows/update-preview-deps*.yml (on-demand dep bumps)

## Production notes
- For production, run the backend with NODE_ENV=production to build and start the compiled server.
- Consider a multi-stage Dockerfile for the storefront to prebuild and serve with next start.
- Use strong JWT_SECRET and COOKIE_SECRET; set publishable keys via secrets.

## Troubleshooting
- Script perms inside containers: backend startup normalizes CRLF and chmod +x start.sh.
- Port conflicts: change published ports in docker-compose.yml.
- Storefront 404s: ensure NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY is set and MEDUSA_BACKEND_URL is reachable from the container.

## Contributing
- Keep env secrets out of the repo (.env is gitignored).
- Prefer small PRs and include a brief description and testing notes.
