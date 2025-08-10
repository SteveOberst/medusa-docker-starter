import { loadEnv, defineConfig, Modules } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    },
    databaseDriverOptions: {
      ssl: false,
      sslmode: "disable",
    },
  },
  modules: [
    {
      resolve: "@medusajs/cache-redis",
      options: {
        redisUrl: process.env.CACHE_REDIS_URL,
      },
  key: Modules.CACHE,
    },
    {
      resolve: "@medusajs/event-bus-redis",
      options: {
        redisUrl: process.env.EVENTS_REDIS_URL,
      },
  key: Modules.EVENT_BUS,
    },
  ],
})
