// Reader for a [hero][context] category. Context-specificity outranks hero:
// walk the context chain (raid:123 -> raid -> all), trying [hero] then "all".
import { WILDCARD } from "./enums.js";

export function contextChain(context: string): string[] {
  const chain = [context];
  const sep = context.indexOf(":");
  if (sep > 0) chain.push(context.slice(0, sep));
  if (context !== WILDCARD) chain.push(WILDCARD);
  return chain.filter((c, i) => chain.indexOf(c) === i);
}

export interface Resolved<T> {
  value: T;
  hero: string;
  context: string;
}

export function resolve<T>(
  category: Record<string, Record<string, T>> | undefined,
  hero: string,
  context: string,
): Resolved<T> | undefined {
  if (!category) return undefined;
  const heroes = hero === WILDCARD ? [WILDCARD] : [hero, WILDCARD];
  for (const ctx of contextChain(context)) {
    for (const h of heroes) {
      const value = category[h]?.[ctx];
      if (value !== undefined) return { value, hero: h, context: ctx };
    }
  }
  return undefined;
}
