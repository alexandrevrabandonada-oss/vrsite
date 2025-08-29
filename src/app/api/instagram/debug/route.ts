// src/app/api/instagram/route.ts
// API: GET /api/instagram  (suporta override via ?t=TOKEN&id=IG_USER_ID)

export const runtime = 'nodejs'; // usar Node (envs + fetch externo)

type IgMediaItem = {
  id: string;
  caption?: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM';
  media_url: string;
  permalink: string;
  timestamp: string;
};
type IgOk = { data: IgMediaItem[]; paging?: unknown };
type IgErr = { error: { message: string; type: string; code: number; fbtrace_id?: string } };

const env = (k: string) => (process.env[k] || '').trim();
const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    },
  });

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const token = (searchParams.get('t') || env('IG_ACCESS_TOKEN')).trim();
    const igUserId = (searchParams.get('id') || env('IG_USER_ID')).trim();

    if (!token || !igUserId) {
      return json(
        {
          error: 'Missing environment variables',
          detail: {
            has_token: Boolean(token),
            has_ig_user_id: Boolean(igUserId),
            hint: 'Defina IG_ACCESS_TOKEN e IG_USER_ID nas Environment Variables da Vercel.',
          },
        },
        500
      );
    }

    const url = new URL(`https://graph.facebook.com/v23.0/${igUserId}/media`);
    url.searchParams.set('fields', 'caption,media_type,media_url,permalink,timestamp');
    url.searchParams.set('access_token', token);

    const r = await fetch(url.toString(), { method: 'GET', cache: 'no-store' });
    const data: IgOk | IgErr = await r.json();

    if (!r.ok || 'error' in data) {
      const status = 'error' in data && data.error.code === 190 ? 401 : 500;
      return json(
        {
          error: 'Falha ao buscar feed',
          detail: data,
          tips:
            status === 401
              ? 'Token inválido/expirado. Gere long-lived e atualize IG_ACCESS_TOKEN (sem espaços/linhas).'
              : undefined,
        },
        status
      );
    }

    return json(data, 200);
  } catch (e: any) {
    return json({ error: 'Erro inesperado', detail: String(e?.message || e) }, 500);
  }
}
