// sr// src/app/api/instagram/route.ts
import { NextResponse, NextRequest } from 'next/server';

export const runtime = 'nodejs';        // usa Node (permite fetch externo e process.env)
export const dynamic = 'force-dynamic'; // não cacheia no build

type IgChild = {
  id: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM';
  media_url?: string;
  thumbnail_url?: string;
};

type IgItem = {
  id: string;
  caption?: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM';
  media_url?: string;
  permalink: string;
  thumbnail_url?: string;
  timestamp?: string;
  username?: string;
  children?: { data: IgChild[] };
};

function maskToken(tok?: string | null, keep = 5) {
  if (!tok) return '';
  const t = tok.trim();
  if (t.length <= keep * 2) return '*'.repeat(t.length);
  return `${t.slice(0, keep)}…${t.slice(-keep)}`;
}

function getEnvToken() {
  return (process.env.IG_LONG_LIVED_TOKEN || process.env.IG_ACCESS_TOKEN || '').trim();
}

function getEnvUserId() {
  return (process.env.IG_USER_ID || '').trim();
}

function buildGraphUrl(userId: string, token: string, limit = 15) {
  const base = 'https://graph.facebook.com/v20.0';
  const fields =
    'id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username,children{media_type,media_url,id}';
  const params = new URLSearchParams({
    fields,
    access_token: token,
    limit: String(limit),
  });
  return `${base}/${encodeURIComponent(userId)}/media?${params.toString()}`;
}

function mapItem(i: IgItem) {
  const thumb =
    i.thumbnail_url ||
    (i.media_type === 'VIDEO' ? i.thumbnail_url : i.media_url) ||
    (i.children?.data || []).find((c) => c.media_type !== 'VIDEO')?.media_url ||
    '';
  return {
    id: i.id,
    caption: i.caption || '',
    media_type: i.media_type,
    media_url: i.media_url || '',
    permalink: i.permalink,
    thumbnail_url: thumb || '',
    timestamp: i.timestamp || '',
    username: i.username || '',
    children: i.children?.data || [],
  };
}

async function fetchWithTimeout(resource: string, ms = 15000) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms);
  try {
    const res = await fetch(resource, { signal: ctrl.signal, cache: 'no-store' });
    return res;
  } finally {
    clearTimeout(t);
  }
}

export async function GET(req: NextRequest) {
  const u = new URL(req.url);

  // Overrides por query (útil em dev): ?t=TOKEN&id=USERID&limit=12&debug=1
  const qToken = (u.searchParams.get('t') || '').trim();
  const qId = (u.searchParams.get('id') || '').trim();
  const limitParam = Number(u.searchParams.get('limit') || '') || 15;
  const wantDebug = u.searchParams.get('debug') === '1';

  const token = (qToken || getEnvToken()).trim();
  const userId = (qId || getEnvUserId()).trim();

  // validações básicas
  const problems: string[] = [];
  if (!token) problems.push('IG token ausente (defina IG_LONG_LIVED_TOKEN no ambiente ou passe ?t=).');
  if (!userId) problems.push('IG user id ausente (defina IG_USER_ID no ambiente ou passe ?id=).');
  if (token && token.length < 100) {
    problems.push('IG token parece curto demais — verifique se é de **longa duração**.');
  }
  if (problems.length) {
    const body: any = {
      error: 'Configuração ausente',
      detail: {
        message: 'Revise as variáveis ou use ?t= e ?id= para testar.',
        problems,
      },
    };
    if (wantDebug) {
      body.debug = {
        env: {
          IG_USER_ID: userId || '(vazio)',
          IG_LONG_LIVED_TOKEN_masked: maskToken(token),
          tokenLen: token.length || 0,
          nodeEnv: process.env.NODE_ENV,
        },
      };
    }
    return NextResponse.json(body, { status: 400 });
  }

  const url = buildGraphUrl(userId, token, limitParam);

  try {
    const res = await fetchWithTimeout(url, 20000);

    // Se houver redirecionamento, trate explicitamente (evita "Failed to fetch" no frontend)
    if (res.status >= 300 && res.status < 400) {
      const location = res.headers.get('location');
      return NextResponse.json(
        { error: `HTTP ${res.status}`, detail: { location } },
        { status: 502 }
      );
    }

    const text = await res.text();

    if (!res.ok) {
      // tenta interpretar JSON de erro do Graph
      let detail: any = null;
      try {
        detail = JSON.parse(text);
      } catch {
        detail = text.slice(0, 500);
      }
      const payload: any = {
        error: 'Falha ao buscar feed',
        status: res.status,
        detail,
      };
      if (wantDebug) {
        payload.debug = {
          requestedUrl: url.replace(token, maskToken(token, 3)), // não vaza token
          tokenMasked: maskToken(token),
          tokenLen: token.length,
          userId,
        };
      }
      return NextResponse.json(payload, { status: 502 });
    }

    // sucesso
    let json: { data: IgItem[] } = { data: [] as IgItem[] };
    try {
      json = JSON.parse(text);
    } catch {
      // caso raro: Graph não mandou JSON
      return NextResponse.json(
        { error: 'Resposta inesperada do Graph', snippet: text.slice(0, 500) },
        { status: 502 }
      );
    }

    const items = (json.data || []).map(mapItem);

    const payload: any = { data: items };

    if (wantDebug) {
      payload.debug = {
        count: items.length,
        sample: items[0] || null,
        requestedUrl: url.replace(token, maskToken(token, 3)),
        env: {
          nodeEnv: process.env.NODE_ENV,
        },
      };
    }

    const resOk = NextResponse.json(payload, { status: 200 });
    // cache de 15 min no edge/proxy; sem cache no navegador
    resOk.headers.set('Cache-Control', 'public, s-maxage=900, stale-while-revalidate=60');
    return resOk;
  } catch (err: any) {
    const payload: any = {
      error: 'Exceção ao buscar feed',
      detail: err?.name === 'AbortError' ? 'timeout' : (err?.message || String(err)),
    };
    if (wantDebug) {
      payload.debug = {
        requestedUrl: url.replace(token, maskToken(token, 3)),
        tokenMasked: maskToken(token),
        tokenLen: token.length,
        userId,
      };
    }
    return NextResponse.json(payload, { status: 500 });
  }
}
