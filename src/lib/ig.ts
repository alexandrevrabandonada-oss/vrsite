export const IG_BASE = process.env.INSTAGRAM_GRAPH_BASE || 'https://graph.instagram.com';

export type RawMediaEdge = {
  id: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM' | string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

export type SimplifiedItem = {
  id: string;
  media_type: string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

export async function fetchMedia(args: {
  token: string;
  igUserId: string;
  limit?: number;
  base?: string;
}) {
  const { token, igUserId, limit = 9, base = IG_BASE } = args;
  const url = new URL(`${base.replace(/\/$/, '')}/${igUserId}/media`);
  url.searchParams.set('fields', [
    'id',
    'caption',
    'media_type',
    'media_url',
    'permalink',
    'thumbnail_url',
    'timestamp',
    'username'
  ].join(','));
  url.searchParams.set('access_token', token);
  url.searchParams.set('limit', String(limit));

  const res = await fetch(url.toString());
  const text = await res.text();
  if (!res.ok) {
    let detail: any = text;
    try { detail = JSON.parse(text); } catch {}
    const err: any = new Error('HTTP ' + res.status);
    err.status = res.status;
    err.detail = detail;
    throw err;
  }
  let json: any;
  try { json = JSON.parse(text); } catch {
    const err: any = new Error('Bad JSON from Graph');
    err.status = 502;
    err.detail = text;
    throw err;
  }
  return json;
}

export function simplify(items: RawMediaEdge[]): SimplifiedItem[] {
  return items.map((m) => ({
    id: m.id,
    media_type: m.media_type,
    media_url: m.media_url,
    thumbnail_url: m.thumbnail_url,
    permalink: m.permalink,
    caption: m.caption,
    username: m.username,
    timestamp: m.timestamp
  }));
}
