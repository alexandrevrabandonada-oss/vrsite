import { NextResponse } from 'next/server'
import data from '@/src/data/ig-seed.json' assert { type: 'json' }

export const runtime = 'nodejs'

export async function GET() {
  const items = (data as any[]).slice(0, 12)
  return NextResponse.json({ items })
}
