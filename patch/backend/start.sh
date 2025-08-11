#!/bin/sh
set -e

# Determine environment (defaults to development)
NODE_ENV=${NODE_ENV:-development}

echo "Running database migrations..."
npx medusa db:migrate

# Seed only on first launch in non-production when enabled
SEED_MARKER="/server/.seeded"
if [ "$NODE_ENV" != "production" ] && [ "${SEED_DB:-false}" = "true" ]; then
	if [ ! -f "$SEED_MARKER" ]; then
		echo "Seeding database (first launch)..."
		if npm run seed; then
			echo "Seed completed. Marking as seeded."
			touch "$SEED_MARKER"
		else
			echo "Seeding failed, continuing without seed."
		fi
	else
		echo "Seed already applied (marker present). Skipping."
	fi
fi

if [ "$NODE_ENV" = "production" ]; then
	echo "Building Medusa app..."
	npm run build
	echo "Starting Medusa production server..."
	npm run start
else
	echo "Starting Medusa development server..."
	npm run dev
fi
