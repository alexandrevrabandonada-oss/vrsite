'use client'
import * as React from 'react'

type Item = { id: string; media_url: string; permalink?: string; caption?: string; timestamp?: string }

export default function HomeFeed() {
  const [items, setItems] = React.useState<Item[]>([])
  const [loading, setLoading] = React.useState(true)

  React.useEffect(() => {
    let active = true
    ;(async () => {
      try {
        const res = await fetch('/api/ig', { cache: 'no-store' })
        const json = await res.json()
        if (!active) return
        const arr: Item[] = Array.isArray(json.items) ? json.items : []
        setItems(arr)
      } catch {
        setItems([])
      } finally {
        if (active) setLoading(false)
      }
    })()
    return () => { active = false }
  }, [])

  if (loading) return <div className="text-center text-sm text-gray-500">Carregando feed…</div>
  if (!items.length) return <div className="text-center text-sm text-gray-500">Sem posts por enquanto.</div>

  return (
    <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((it) => {
        const id = String(it?.id ?? '').trim() || 'seed-1'
        const href = `/instagram/${encodeURIComponent(id)}?debug=1`
        return (
          <article key={id} className="border rounded-xl overflow-hidden bg-white dark:bg-neutral-800">
            <a href={href}>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={it.media_url} alt={it.caption || 'Post'} className="w-full h-56 object-cover" />
            </a>
            <div className="p-3">
              <div className="text-[11px] uppercase tracking-wide opacity-60">ID: {id}</div>
              <a href={href} className="text-sm font-medium hover:underline">Abrir detalhes</a>
              <p className="mt-1 text-sm text-gray-700 dark:text-gray-200 line-clamp-3">{it.caption}</p>
              <div className="mt-2 text-xs text-gray-500">
                {it.timestamp ? new Date(it.timestamp).toLocaleDateString() : null}
              </div>
            </div>
          </article>
        )
      })}
    </section>
  )
}
