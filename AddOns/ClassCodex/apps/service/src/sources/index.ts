// The source registry. Wiring a new source = implement SourceProvider and add it
// here (or register() it in a test). Empty by default — real sources (u.gg, Icy
// Veins, Blizzard PvP) land in their own PRs.
import type { SourceProvider } from "./types.js";

const registry = new Map<string, SourceProvider>();

export function register(provider: SourceProvider): void {
  registry.set(provider.name, provider);
}

export function getProvider(name: string): SourceProvider | undefined {
  return registry.get(name);
}

export function listSources(): string[] {
  return [...registry.keys()].sort();
}

export type { SourceProvider } from "./types.js";
