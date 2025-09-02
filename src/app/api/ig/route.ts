import { NextResponse } from 'next/server'
import { promises as fs } from 'node:fs'
import path from 'node:path'

export const runtime = 'nodejs'

async function loadSeed() {
  const candidates = [
    path.join(process.cwd(), 'src', 'data', 'ig-seed.json'),
    path.join(process.cwd(), 'data', 'ig-seed.json'),
    path.join(process.cwd(), 'public', 'ig-seed.json'),
  ]
  for (const p of candidates) {
    try {
      const buf = await fs.readFile(p, 'utf8')
      return JSON.parse(buf)
    } catch {}
  }
  // fallback embutido
  return Array.from({ length: 6 }).map((_, i) => ({
    id: `seed-${i + 1}`,
    media_url: '/og-default.png',
    permalink: 'https://instagram.com/',
    caption: `Post de exemplo ${i + 1}`,
    timestamp: '2024-07-20',
  }))
}

function normalizeId(v: any) {
  return String(v ?? '').trim()
}

export async function GET(req: Request) {
  const url = new URL(req.url)
  const id = normalizeId(url.searchParams.get('id'))
  const debug = url.searchParams.get('debug')

  const raw = await loadSeed()
  const items = Array.isArray(raw) ? raw : (raw?.items ?? [])
  const norm = items.map((x:any) => ({ ...x, id: normalizeId(x.id) }))

  if (id) {
    const item = norm.find((x:any) => x.id === id)
    if (!item) {
      if (debug) {
        return NextResponse.json({
          error: 'not_found',
          requested: id,
          available: norm.map((x:any) => x.id),
        }, { status: 404 })
      }
      return NextResponse.json({ error: 'not_found' }, { status: 404 })
    }
    return NextResponse.json({ item })
  }

  return NextResponse.json({ items: norm.slice(0, 50) })
}
