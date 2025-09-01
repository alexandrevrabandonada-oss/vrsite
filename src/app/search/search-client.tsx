'use client'

import * as React from 'react'
import { useSearchParams, useRouter } from 'next/navigation'

type Doc = {
  id: string
  title: string
  excerpt?: string
  slug: string
  tags?: string[]
  date?: string
  image?: string
  source?: string
}

export default function SearchClient() {
  const params = useSearchParams()
  const router = useRouter()
  const [q, setQ] = React.useState(params.get('q') || '')
  const [loading, setLoading] = React.useState(false)
  const [results, setResults] = React.useState<Doc[]>([])

  const run = React.useCallback(async (query: string) => {
    setLoading(true)
    try {
      const res = await fetch(`/api/search?q=${encodeURIComponent(query)}`, { cache: 'no-store' })
      const json = await res.json()
      setResults(json.results || [])
    } catch (e) {
      console.error(e)
      setResults([])
    } finally {
      setLoading(false)
    }
  }, [])

  React.useEffect(() => {
    const initial = params.get('q') || ''
    setQ(initial)
    run(initial)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  function onSubmit(e: React.FormEvent) {
    e.preventDefault()
    const next = `/search?q=${encodeURIComponent(q)}`
    router.push(next)
    run(q)
  }

  return (
    <main className="max-w-4xl mx-auto p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Buscar</h1>

      <form onSubmit={onSubmit} className="flex gap-2">
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Digite um termo (ex.: educacao, saude, trabalho)"
          className="flex-1 border rounded-lg px-3 py-2"
        />
        <button
          type="submit"
          className="px-4 py-2 rounded-lg border shadow-sm"
          disabled={loading}
        >
          {loading ? 'Buscando...' : 'Buscar'}
        </button>
      </form>

      <div className="text-sm text-gray-500">
        {loading ? 'Carregando...' : `Resultados: ${results.length}`}
      </div>

      <section className="grid gap-4">
        {results.map((r) => (
          <article key={r.id} className="border rounded-xl p-4 hover:shadow-sm transition">
            <div className="flex items-start gap-4">
              {r.image ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={r.image} alt={r.title} className="w-24 h-24 object-cover rounded-lg" />
              ) : null}
              <div className="flex-1">
                <a href={`/posts/${r.slug}`} className="text-lg font-medium hover:underline">
                  {r.title}
                </a>
                {r.excerpt ? <p className="mt-1 text-sm text-gray-700">{r.excerpt}</p> : null}
                <div className="mt-2 flex flex-wrap gap-2">
                  {(r.tags || []).map(t => (
                    <span key={t} className="text-xs px-2 py-1 rounded-full border">
                      #{t}
                    </span>
                  ))}
                </div>
                <div className="mt-2 text-xs text-gray-500">
                  {r.date ? new Date(r.date).toLocaleDateString() : null} {r.source ? `• ${r.source}` : ''}
                </div>
              </div>
            </div>
          </article>
        ))}
      </section>
    </main>
  )
}
