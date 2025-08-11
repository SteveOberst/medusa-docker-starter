FROM node:20-alpine
WORKDIR /server

# Enable Corepack for Yarn/PNPM support
RUN corepack enable

# Copy the full context so lockfiles are available for installation
COPY . .

# Install dependencies based on the available lockfile
RUN set -eux; \
		if [ -f package-lock.json ]; then \
			npm ci; \
		elif [ -f pnpm-lock.yaml ]; then \
			corepack pnpm install --frozen-lockfile || corepack pnpm install; \
		elif [ -f yarn.lock ]; then \
			corepack yarn install --immutable || corepack yarn install; \
		else \
			npm install; \
		fi

# Normalize line endings and ensure start script is executable
RUN sed -i 's/\r$//' ./start.sh && chmod +x ./start.sh

EXPOSE 9000
CMD ["./start.sh"]
