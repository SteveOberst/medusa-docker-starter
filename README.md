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
This repo ships with empty backend/ and storefront/ folders on purpose. Use the bootstrap scripts to scaffold a fresh Medusa storefront and apply our Docker/config patches.

1) Copy env template and customize (the bootstrap scripts will do this automatically):
```powershell
Copy-Item .env.template .env
```

2) Bootstrap the apps to populate storefront/ and apply patches to both apps

Windows PowerShell
```powershell
# default Medusa starter
./scripts/bootstrap.ps1

# custom storefront repo and branch/tag
./scripts/bootstrap.ps1 -StorefrontRepo "https://github.com/your-org/your-nextjs-storefront" -StorefrontRef "main"
# alternatively, set STOREFRONT_REPO/STOREFRONT_REF in .env and just run ./scripts/bootstrap.ps1
```

macOS/Linux (Bash)
```bash
# default Medusa starter
./scripts/bootstrap.sh

# custom storefront repo and branch/tag
STOREFRONT_REPO="https://github.com/your-org/your-nextjs-storefront" \
STOREFRONT_REF="main" \
./scripts/bootstrap.sh
# alternatively, set STOREFRONT_REPO/STOREFRONT_REF in .env and just run ./scripts/bootstrap.sh
```

What the bootstrap does
- Clones the storefront into storefront/ (resets that folder)
- Initializes a fresh Medusa backend in backend/ using Medusa's create tool (configurable)
- Copies our patches from patch/storefront into storefront/
- Creates .env from .env.template at the repo root if missing

Important: generate a publishable API key
- After bootstrapping, create at least one Region and Sales Channel in your Medusa backend.
- Generate a Publishable API Key for that Sales Channel and set it in your .env as NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY.
- Without this key, most dynamic storefront pages will return empty data.

Key vars:
- Database: POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- Backend: JWT_SECRET, COOKIE_SECRET, STORE_CORS, ADMIN_CORS, AUTH_CORS
- Storefront (browser): NEXT_PUBLIC_MEDUSA_BACKEND_URL (defaults to http://localhost:9000)
- Storefront (server/SSR/middleware): MEDUSA_INTERNAL_BACKEND_URL is injected by docker-compose (http://medusa:9000). Do not set MEDUSA_BACKEND_URL in .env.
- Optional: NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY (required for dynamic pages hitting the backend in the browser)
- Misc: NODE_ENV (development|production), SEED_DB (false by default)

Bootstrap configuration in .env (optional):
- STOREFRONT_REPO: Git URL for the storefront to clone (defaults to Medusa starter)
- STOREFRONT_REF: Branch/tag to checkout (defaults to main)
- BACKEND_DIR, STOREFRONT_DIR: target folders (default backend, storefront)
- BACKEND_INIT_CMD: command template to initialize the backend (default uses npx @medusajs/create-medusa-app@latest {dir})

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

Apply patches only (if you already have apps):

- Windows
```powershell
./scripts/apply-patches.ps1
```

- macOS/Linux
```bash
./scripts/apply-patches.sh
```

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
- Backend init E404: If you see an npm 404 for @medusajs/create-medusa-app, use the unscoped package. The default BACKEND_INIT_CMD uses "npx create-medusa-app@latest {dir}".

## Repo layout notes
- backend/ and storefront/ are initially empty; the bootstrap will populate them.
- Our Dockerfiles and config live under patch/backend and patch/storefront and are applied on top of upstream starters. This keeps upgrades simple.

## Contributing
- Keep env secrets out of the repo (.env is gitignored).
- Prefer small PRs and include a brief description and testing notes.
