import Medusa from "@medusajs/js-sdk"

const PUBLIC_URL = process.env.NEXT_PUBLIC_MEDUSA_BACKEND_URL
// Prefer container-only internal URL; fall back for legacy env var names
const SERVER_URL =
  process.env.MEDUSA_INTERNAL_BACKEND_URL ||
  process.env.MEDUSA_BACKEND_URL ||
  "http://medusa:9000"

// Use browser URL on client, server URL on SSR
const isBrowser = typeof window !== "undefined"
const BASE_URL = isBrowser ? PUBLIC_URL || "http://localhost:9000" : SERVER_URL

export const sdk = new Medusa({
  baseUrl: BASE_URL,
  debug: process.env.NODE_ENV === "development",
  publishableKey: process.env.NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY,
})
