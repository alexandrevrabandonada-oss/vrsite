// src/app/api/instagram/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { fetchMedia, simplify, IG_BASE } from '@/lib/ig';

export const runtime = 'nodejs';

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const limit = Number(searchParams.get('limit') || '9');
  const raw = searchParams.get('raw') === '1';

  // Overrides via query
  const overrideToken = searchParams.get('t') || undefined;
  const overrideUser = searchParams.get('id') || undefined;
  const overrideBase = searchParams.get('base') || undefined;

  const token = overrideToken || process.env.IG_ACCESS_TOKEN || '';
  const igUserId = overrideUser || process.env.IG_USER_ID || '';
  const base = (overrideBase || process.env.INSTAGRAM_GRAPH_BASE || IG_BASE).replace(/\/$/, '');

  if (!token || !igUserId) {
    return NextResponse.json(
      { error: 'Configuração ausente', detail: { hasToken: !!token, hasUserId: !!igUserId, message: 'Defina IG_ACCESS_TOKEN e IG_USER_ID ou use ?t= e ?id= para teste.' }},
      { status: 400 }
    );
  }

  try {
    const json = await fetchMedia({ token, igUserId, limit, base });
    if (raw) return NextResponse.json(json, { status: 200 });
    const items = simplify(json.data || []);
    return NextResponse.json({ data: items }, { status: 200 });
  } catch (err: any) {
    return NextResponse.json(
      { error: 'Falha ao buscar feed', status: err?.status || 500, detail: err?.detail || String(err) },
      { status: err?.status || 500 }
    );
  }
}
