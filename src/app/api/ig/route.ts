import { NextRequest } from 'next/server'
import { listIgItems, getIgItemById } from '@/src/lib/ig-data'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url)
  const id = searchParams.get('id')
  const debug = searchParams.get('debug') === '1'
  const dump = searchParams.get('_dump') === '1'

  if (id) {
    const item = await getIgItemById(id)
    if (!item) {
      const body = debug ? { error: 'not_found', id } : { item: null }
      return new Response(JSON.stringify(body), { status: 200, headers: { 'content-type': 'application/json' } })
    }
    const payload = dump ? { item, _diagnostic: { id } } : { item }
    return new Response(JSON.stringify(payload), { status: 200, headers: { 'content-type': 'application/json' } })
  }

  const items = await listIgItems()
  const payload = dump ? { items, _diagnostic: { count: items.length, ids: items.map(x => x.id) } } : { items }
  return new Response(JSON.stringify(payload), { status: 200, headers: { 'content-type': 'application/json' } })
}
