import { NextResponse } from 'next/server';

const sanitize = (s: string) => (s || '').trim().replace(/\s+/g, '');
const FALLBACK_TOKEN = sanitize(process.env.IG_ACCESS_TOKEN || '');
const FALLBACK_USER  = sanitize(process.env.IG_USER_ID || '');

export const runtime = 'nodejs'; // garante Node (env + fetch externo)

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);

    // overrides pra debug: ?t=TOKEN & uid=USER_ID
    const token = sanitize(searchParams.get('t') || FALLBACK_TOKEN);
    const userId = sanitize(searchParams.get('uid') || FALLBACK_USER);

    if (!token || !userId) {
      return NextResponse.json(
        { error: 'Faltam credenciais', hasToken: !!token, hasUser: !!userId },
        { status: 400 }
      );
    }

    const fields = [
      'id',
      'caption',
      'media_type',
      'media_url',
      'permalink',
      'thumbnail_url',
      'timestamp',
      'username',
      'children{media_type,media_url,thumbnail_url,id}'
    ].join(',');

    const url =
      `https://graph.facebook.com/v23.0/${userId}` +
      `/media?fields=${encodeURIComponent(fields)}&access_token=${token}`;

    const r = await fetch(url, { next: { revalidate: 300 } }); // cache 5 min
    const text = await r.text();

    if (!r.ok) {
      return NextResponse.json(
        { error: 'Falha ao buscar feed', detail: text },
        { status: r.status }
      );
    }

    return NextResponse.json(JSON.parse(text), { status: 200 });
  } catch (e: any) {
    return NextResponse.json(
      { error: 'Erro inesperado', detail: String(e?.message || e) },
      { status: 500 }
    );
  }
}
