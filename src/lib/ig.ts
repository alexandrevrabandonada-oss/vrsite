/**
 * src/lib/ig.ts
 * Camada de acesso ao Instagram Graph (via Facebook Graph v20.0).
 * - NÃO pede username no /me (apenas id,name).
 * - Para IG Business/Creator usa /{IG_USER_ID} com fields adequados.
 */

export const IG_GRAPH_BASE =
  process.env.INSTAGRAM_GRAPH_BASE ||
  "https://graph.facebook.com/v20.0"; // fonte única

export function getToken(req?: Request) {
  // Prioridade: querystring ?t= , depois env
  try {
    if (req) {
      const url = new URL(req.url);
      const t = url.searchParams.get("t");
      if (t && t.trim()) return t.trim();
    }
  } catch {}
  return process.env.IG_ACCESS_TOKEN || process.env.IG_LONG_LIVED_TOKEN || "";
}

export function getUserId(req?: Request) {
  try {
    if (req) {
      const url = new URL(req.url);
      const id = url.searchParams.get("id");
      if (id && id.trim()) return id.trim();
    }
  } catch {}
  return process.env.IG_USER_ID || "";
}

export async function fbMe(token: string) {
  const u = `${IG_GRAPH_BASE}/me?fields=id,name&access_token=${encodeURIComponent(token)}`;
  const r = await fetch(u, { cache: "no-store" });
  const js = await r.json().catch(() => ({}));
  return { status: r.status, body: js };
}

export async function igAccount(igUserId: string, token: string) {
  const fields = [
    "id",
    "username",
    "media_count",
    "account_type"
  ].join(",");
  const u = `${IG_GRAPH_BASE}/${igUserId}?fields=${fields}&access_token=${encodeURIComponent(token)}`;
  const r = await fetch(u, { cache: "no-store" });
  const js = await r.json().catch(() => ({}));
  return { status: r.status, body: js };
}

export type IgMediaItem = {
  id: string;
  caption?: string;
  media_type: "IMAGE" | "VIDEO" | "CAROUSEL_ALBUM" | string;
  media_url?: string;
  thumbnail_url?: string;
  permalink?: string;
  timestamp?: string;
  username?: string;
};

export async function fetchMedia(igUserId: string, token: string, limit = 12) {
  const fields = [
    "id",
    "caption",
    "media_type",
    "media_url",
    "thumbnail_url",
    "permalink",
    "timestamp",
    "username"
  ].join(",");

  const u = `${IG_GRAPH_BASE}/${igUserId}/media?fields=${fields}&limit=${limit}&access_token=${encodeURIComponent(token)}`;
  const r = await fetch(u, { cache: "no-store" });
  const js = await r.json().catch(() => ({}));
  if (!r.ok) {
    const err = js?.error || { message: "Unknown error", code: r.status };
    throw new Error(JSON.stringify({ status: r.status, error: err }));
  }
  const data: IgMediaItem[] = js?.data || [];
  return data;
}
