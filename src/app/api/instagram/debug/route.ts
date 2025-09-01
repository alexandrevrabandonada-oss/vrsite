// src/app/api/instagram/debug/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { IG_BASE } from '@/lib/ig';

export const runtime = 'nodejs';

export async function GET(req: NextRequest) {
  const base = process.env.INSTAGRAM_GRAPH_BASE || IG_BASE;
  const token = process.env.IG_ACCESS_TOKEN || '';
  const igUserId = process.env.IG_USER_ID || '';

  const info: any = {
    hasToken: !!token,
    tokenLen: token ? token.length : 0,
    tokenPreview: token ? token.slice(0, 6) + '...' + token.slice(-5) : null,
    igUserId: igUserId || null,
    base,
    vercelEnv: process.env.VERCEL_ENV || 'development',
    me: null,
    meErr: null
  };

  if (token) {
    try {
      const url = new URL(base.replace(/\/$/, '') + '/me');
      url.searchParams.set('fields', 'id,username');
      url.searchParams.set('access_token', token);
      const res = await fetch(url.toString());
      const body = await res.text();
      if (res.ok) info.me = JSON.parse(body);
      else info.meErr = { status: res.status, body };
    } catch (e: any) {
      info.meErr = { message: String(e) };
    }
  }

  return NextResponse.json(info, { status: 200 });
}
