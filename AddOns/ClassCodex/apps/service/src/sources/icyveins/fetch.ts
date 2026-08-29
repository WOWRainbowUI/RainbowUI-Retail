// Icy Veins fetch layer. Icy Veins sits behind Cloudflare; hitting the public
// hostname gets challenged. We instead pin the connection to the origin IP
// (ICYVEINS_ORIGIN_IP, default 51.68.72.78) while keeping the SNI/Host as
// www.icy-veins.com — the exact equivalent of `curl --resolve www.icy-veins.com:443:<ip>`.
// Set ICYVEINS_ORIGIN_IP to an empty string to disable pinning and use ordinary
// DNS (leaving it unset keeps the default IP).
import { Agent, fetch as undiciFetch } from "undici";

const ORIGIN_IP = process.env.ICYVEINS_ORIGIN_IP ?? "51.68.72.78";
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

// A dispatcher that resolves every hostname to the pinned origin IP. The origin
// serves the real cert for www.icy-veins.com over SNI, but to match the `-k` in
// the reference curl (origin may present a Cloudflare/edge cert) we don't reject
// on validation for this scoped, deliberately-pinned dispatcher.
function pinnedDispatcher(ip: string): Agent {
  const lookup = (_hostname: string, options: { all?: boolean } | undefined, cb: (...a: any[]) => void) => {
    if (options && options.all) cb(null, [{ address: ip, family: 4 }]);
    else cb(null, ip, 4);
  };
  return new Agent({ connect: { rejectUnauthorized: false, lookup: lookup as never } });
}

const dispatcher = ORIGIN_IP ? pinnedDispatcher(ORIGIN_IP) : undefined;

/** Fetch a page as text. Returns null on any non-2xx or network error (a spec
 * that 404s is a real miss the caller records — one page failing must not sink
 * the whole ingest). */
export async function fetchText(url: string): Promise<string | null> {
  try {
    const resp = await undiciFetch(url, {
      headers: { "User-Agent": USER_AGENT, Accept: "text/html" },
      dispatcher,
    });
    if (!resp.ok) {
      // Log the reason immediately so a missing surface is never a silent null —
      // a 404 (IV renamed/removed the page) reads very differently from a 403
      // (Cloudflare block / bad origin IP).
      console.warn(`icyveins: HTTP ${resp.status} ${url}`);
      return null;
    }
    return await resp.text();
  } catch (err) {
    console.warn(`icyveins: fetch error ${url}: ${err instanceof Error ? err.message : String(err)}`);
    return null;
  }
}

/** Run `fn` over `items` with bounded concurrency, preserving input order. */
export async function mapPool<T, R>(
  items: readonly T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>,
): Promise<R[]> {
  const results = new Array<R>(items.length);
  let next = 0;
  const workers = Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    for (;;) {
      const i = next++;
      if (i >= items.length) return;
      results[i] = await fn(items[i], i);
    }
  });
  await Promise.all(workers);
  return results;
}
