import { describe, it, expect } from "vitest";
import { contentHash } from "./content-hash.js";

describe("contentHash", () => {
  it("is stable for identical data regardless of key order", () => {
    expect(contentHash({ a: 1, b: 2 })).toBe(contentHash({ b: 2, a: 1 }));
  });

  it("changes when the data changes", () => {
    expect(contentHash({ a: 1 })).not.toBe(contentHash({ a: 2 }));
  });

  it("is a short hex string", () => {
    expect(contentHash({ a: 1 })).toMatch(/^[0-9a-f]{16}$/);
  });
});
