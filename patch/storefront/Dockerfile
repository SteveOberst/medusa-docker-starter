FROM node:20-alpine
WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
RUN corepack prepare yarn@3.2.3 --activate \
    && yarn install

COPY . .

EXPOSE 8000
CMD ["yarn", "dev", "-p", "8000", "-H", "0.0.0.0"]
