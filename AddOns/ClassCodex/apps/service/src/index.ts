// Boot the HTTP service. Coolify (or any Node host) runs this.
import { serve } from "@hono/node-server";
import { config } from "./config.js";
import { SourceCache } from "./cache.js";
import { createApp } from "./http/app.js";
import { listSources, register } from "./sources/index.js";
import { IcyVeinsProvider } from "./sources/icyveins/index.js";

register(new IcyVeinsProvider());

const app = createApp(new SourceCache(config.cacheTtlMs), { apiKey: config.apiKey });

serve({ fetch: app.fetch, port: config.port }, (info) => {
  const sources = listSources();
  console.log(`class-codex service on :${info.port}`);
  console.log(`  sources: ${sources.length ? sources.join(", ") : "(none wired yet)"}`);
  console.log(`  auth:    ${config.apiKey ? "API key required" : "OPEN — set SERVICE_API_KEY"}`);
});
