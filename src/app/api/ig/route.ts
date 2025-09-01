import { NextResponse } from 'next/server'
import data from '@/data/ig-seed.json' assert { type: 'json' }

export const runtime = 'nodejs'

export async function GET(req: Request) {
  const url = new URL(req.url)
  const id = url.searchParams.get('id')

  const items = (data as any[]).slice(0, 50)

  if (id) {
    const item = items.find((x:any) => String(x.id) === String(id))
    if (!item) return NextResponse.json({ error: 'not_found' }, { status: 404 })
    return NextResponse.json({ item })
  }

  return NextResponse.json({ items })
}
