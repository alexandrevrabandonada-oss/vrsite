import { NextResponse } from 'next/server'

export const runtime = 'nodejs'

export async function GET(req: Request) {
  const url = new URL(req.url)
  const headers: Record<string, string> = {}
  ;(req as any).headers?.forEach?.((v: string, k: string) => { headers[k] = v })

  const host =
    headers['x-forwarded-host'] ||
    headers['host'] ||
    process.env.VERCEL_URL ||
    'localhost:3000'

  const proto =
    headers['x-forwarded-proto'] ||
    (process.env.VERCEL ? 'https' : 'http')

  return NextResponse.json({
    ok: true,
    method: 'GET',
    url: url.toString(),
    host,
    proto,
    origin: host.startsWith('http') ? host : `${proto}://${host}`,
    vercel: !!process.env.VERCEL,
    vercel_url: process.env.VERCEL_URL || null,
    node_env: process.env.NODE_ENV || null,
    headers,
  })
}
