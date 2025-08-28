// src/app/api/instagram/route.ts
// Next.js App Router (API Route) — /api/instagram

export const runtime = 'nodejs'; // evita Edge p/ requests externos + envs

type IgMediaItem = {
  id: string;
  caption?: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM';
  media_url: string;
  permalink: string;
  timestamp: string; // ISO
};

type IgMediaResponse =
  | { data: IgMediaItem[] }
  | { error: { message: string; type: string; code: number; fbtrace_id?: string } };

// Util: pega env sem espaços/quebras
const env = (k: string) => (process.env[k] || '').trim();

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);

    // Permite testar sem mexer nas envs:
    //   /api/instagram?t=SEU_TOKEN&id=IG_USER_ID
    const token = (searchParams.get('t') || env('IG_ACCESS_TOKEN')).trim();
    const igUserId = (searchParams.get('id') || env('IG_USER_ID')).trim();

    if (!token || !igUserId) {
      return Response.json(
        {
          error: 'Missing environment variables',
          detail: {
            has_token: Boolean(token),
            has_ig_user_id: Boolean(igUserId),
            hint: 'Defina IG_ACCESS_TOKEN e IG_USER_ID nas Environment Variables da Vercel.',
          },
        },
        { status: 500 }
      );
    }

    // Monta chamada à Graph API
    const url = new URL(`https://graph.facebook.com/v23.0/${igUserId}/media`);
    url.searchParams.set('fields', 'caption,media_type,media_url,permalink,timestamp');
    url.searchParams.set('access_token', token);

    const r = await fetch(url.toString(), {
      method: 'GET',
      // evita cache em produção
      cache: 'no-store',
      headers: { 'Accept': 'application/json' },
    });

    const data: IgMediaResponse = await r.json();

    // Se API do Meta retornou erro, repassa com status adequado
    if (!r.ok || 'error' in data) {
      const status =
        'error' in data && data.error.code === 190 /* OAuthException (token) */ ? 401 : 500;

      return Response.json(
        {
          error: 'Falha ao buscar feed',
          detail: data,
          tips:
            status === 401
              ? 'Token inválido/expirado. Gere um long-lived e atualize IG_ACCESS_TOKEN (sem espaços/linhas).'
              : undefined,
        },
        { status }
      );
    }

    // Sucesso
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-store',
      },
    });
  } catch (err: any) {
    return Response.json(
      { error: 'Erro inesperado', detail: String(err?.message || err) },
      { status: 500 }
    );
  }
}
