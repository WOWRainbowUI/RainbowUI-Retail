// Service-wide knobs. Everything here is overridable by env so the same image
// runs locally and on Coolify without code changes.

/** Content flavors — independent datasets, each a path segment. Retail today. */
export const FLAVORS = ["retail"] as const;
export type Flavor = (typeof FLAVORS)[number];
export const isFlavor = (v: string): v is Flavor => (FLAVORS as readonly string[]).includes(v);

function num(name: string, fallback: number): number {
  const v = process.env[name];
  const n = v ? Number(v) : NaN;
  return Number.isFinite(n) ? n : fallback;
}

export const config = {
  port: num("PORT", 8080),
  // Short cache: a built source is reused for this long before the next request
  // rebuilds fresh — just to keep repeated hits off upstream. See cache.ts.
  cacheTtlMs: num("SERVICE_CACHE_SECONDS", 300) * 1000,
  // If set, all /:flavor/* endpoints require this key (X-API-Key or Bearer).
  // Unset = open (dev). /health is always open.
  apiKey: process.env.SERVICE_API_KEY,
};
