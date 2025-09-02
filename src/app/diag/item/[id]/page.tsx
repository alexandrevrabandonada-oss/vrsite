import { getIgItemById } from '@/lib/ig-data'
export const dynamic = 'force-dynamic'
export default async function DiagItem({ params }: { params: { id: string }}) {
  const id = String(params?.id || '')
  const item = await getIgItemById(id)
  return (<main className="min-h-screen p-6"><div className="max-w-3xl mx-auto space-y-4"><h1 className="text-lg font-semibold">Diag: item por id</h1><pre className="p-3 rounded bg-neutral-900 text-neutral-100 overflow-auto">{JSON.stringify({ exists: !!item, item }, null, 2)}</pre></div></main>)
}
