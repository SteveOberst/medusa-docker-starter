FROM node:20-alpine
WORKDIR /app

# Enable Corepack and install Yarn 3.x as specified by packageManager in package.json
RUN corepack enable

# Copy only manifest files first for better caching
COPY package.json yarn.lock .yarnrc.yml ./

# Prepare the Yarn version and install deps
RUN corepack prepare yarn@3.2.3 --activate \
  && yarn install

# Copy the rest of the app
COPY . .

EXPOSE 8000

# Run in dev mode with Yarn
CMD ["yarn", "dev"]
