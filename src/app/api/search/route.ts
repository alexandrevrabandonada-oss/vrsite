import { NextResponse } from 'next/server'
import { searchDocs } from '@/src/lib/search'

export const runtime = 'nodejs' // permite pacote comum

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const q = searchParams.get('q') || ''
  const results = searchDocs(q, 50)
  return NextResponse.json({ q, count: results.length, results })
}
