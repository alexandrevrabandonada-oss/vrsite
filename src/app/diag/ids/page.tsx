import { listIgItems } from '@/lib/ig-data'
export const dynamic = 'force-dynamic'
export default async function DiagIds() {
  const items = await listIgItems()
  return (<main className="min-h-screen p-6"><div className="max-w-3xl mx-auto space-y-4"><h1 className="text-lg font-semibold">Diag: IDs visÃ­veis pela app</h1><pre className="p-3 rounded bg-neutral-900 text-neutral-100 overflow-auto">{JSON.stringify(items.map(x => x.id), null, 2)}</pre><ul className="list-disc pl-6">{items.map(x => (<li key={x.id}><a className="underline" href={`/diag/itemid/${encodeURIComponent(x.id)}`}>{x.id}</a></li>))}</ul></div></main>)
}
