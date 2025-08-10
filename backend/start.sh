#!/bin/sh
set -e

# Determine environment (defaults to development)
NODE_ENV=${NODE_ENV:-development}

echo "Running database migrations..."
npx medusa db:migrate

if [ "$NODE_ENV" = "production" ]; then
  echo "Building Medusa app..."
  npm run build
  echo "Starting Medusa production server..."
  npm run start
else
  echo "Starting Medusa development server..."
  npm run dev
fi
#!/bin/sh
set -e

# Determine environment (defaults to development)
NODE_ENV=${NODE_ENV:-development}

echo "Running database migrations..."
npx medusa db:migrate

# Seed only in non-production by default (override with SEED_DB=true/false)
if [ "$NODE_ENV" != "production" ] && [ "${SEED_DB:-true}" = "true" ]; then
	echo "Seeding database..."
	npm run seed || echo "Seeding failed, continuing..."
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