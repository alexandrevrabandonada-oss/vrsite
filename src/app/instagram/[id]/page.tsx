import { notFound } from 'next/navigation'
import { getIgItemById } from '@/lib/ig-data'
export const dynamic = 'force-dynamic'

function toBool(v:any){ return v===true || v==='1' || (Array.isArray(v) && v[0]==='1') }

export default async function InstagramDetail({ params, searchParams }: any) {
  const id = String(params?.id || '')
  const debug = toBool(searchParams?.debug)
  const item = await getIgItemById(id)

  if (!item) {
    if (debug) {
      return (
        <main className="min-h-screen p-6">
          <div className="max-w-3xl mx-auto space-y-4">
            <a href="/" className="text-sm opacity-75 hover:opacity-100">&larr; Voltar</a>
            <div className="rounded-xl border p-6">
              <h1 className="text-lg font-semibold">Post não encontrado</h1>
              <pre className="p-3 rounded bg-neutral-900 text-neutral-100 overflow-auto">{JSON.stringify({ id, item }, null, 2)}</pre>
              <p className="text-xs opacity-70">Dica: confira <a className="underline" href={`/diag/item/${encodeURIComponent(id)}`} target="_blank">/diag/item/{id}</a> e <a className="underline" href={`/api/ig?id=${encodeURIComponent(id)}&debug=1&_dump=1`} target="_blank">/api/ig?id={id}</a></p>
            </div>
          </div>
        </main>
      )
    }
    notFound()
  }

  // render
  return (
    <main className="min-h-screen p-6 bg-gray-50 dark:bg-neutral-900">
      <div className="max-w-3xl mx-auto space-y-4">
        <a href="/" className="inline-block text-sm opacity-75 hover:opacity-100">&larr; Voltar</a>
        {debug ? (
          <details open className="rounded-xl border p-4 bg-white/60 dark:bg-black/30">
            <summary className="cursor-pointer font-medium">Debug</summary>
            <pre className="p-3 rounded bg-neutral-900 text-neutral-100 overflow-auto text-xs">{JSON.stringify(item, null, 2)}</pre>
          </details>
        ) : null}

        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={item.media_url || '/og-default.png'}
          alt={item.caption || 'Post'}
          onError={(e:any)=>{ e.currentTarget.src='/og-default.png' }}
          className="w-full rounded-xl border object-contain bg-white"
        />

        <article className="bg-white dark:bg-neutral-800 border rounded-xl p-4">
          <p className="whitespace-pre-wrap text-gray-800 dark:text-gray-100">{item.caption || ''}</p>
          <div className="mt-3 text-xs text-gray-500">
            {item.timestamp ? new Date(item.timestamp).toLocaleString('pt-BR') : null}
          </div>
          {item.permalink ? (
            <a href={item.permalink} target="_blank" rel="noreferrer" className="mt-4 inline-block px-4 py-2 rounded-lg border shadow-sm hover:shadow transition">
              Ver no Instagram
            </a>
          ) : null}
        </article>
      </div>
    </main>
  )
}
