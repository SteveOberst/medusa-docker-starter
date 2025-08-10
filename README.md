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
- Storefront (browser): NEXT_PUBLIC_MEDUSA_BACKEND_URL (defaults to http://localhost:9000)
- Storefront (server/SSR/middleware): MEDUSA_INTERNAL_BACKEND_URL is injected by docker-compose (http://medusa:9000). Do not set MEDUSA_BACKEND_URL in .env.
- Optional: NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY (required for dynamic pages hitting the backend in the browser)
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
Single smoke test workflow ensures Docker stack boots and responds:
- .github/workflows/compose-smoke.yml
	- Creates a minimal .env for the runner
	- Builds and starts docker compose
	- Waits for backend /health (http://localhost:9000/health)
	- Pings storefront static asset (http://localhost:8000/favicon.ico) to bypass middleware and publishable key
	- Dumps logs on failure and tears down

Dependabot is kept for automated dependency checks.

## Production notes
- For production, run the backend with NODE_ENV=production to build and start the compiled server.
- Consider a multi-stage Dockerfile for the storefront to prebuild and serve with next start.
- Use strong JWT_SECRET and COOKIE_SECRET; set publishable keys via secrets.

## Troubleshooting
- Script perms inside containers: backend startup normalizes CRLF and chmod +x start.sh.
- Port conflicts: change published ports in docker-compose.yml.
- Admin redirecting to medusa:9000: remove MEDUSA_BACKEND_URL from .env; the browser must use NEXT_PUBLIC_MEDUSA_BACKEND_URL (localhost). Internal networking is handled via MEDUSA_INTERNAL_BACKEND_URL in docker-compose.
- Storefront empty data: add at least one Region and link it to a Sales Channel; set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY with access to that channel.
- CI missing .env: the smoke workflow creates it automatically; if running manually, create .env first.

## Contributing
- Keep env secrets out of the repo (.env is gitignored).
- Prefer small PRs and include a brief description and testing notes.
