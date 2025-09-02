import { headers } from 'next/headers'

export const dynamic = 'force-dynamic'

function getOrigin() {
  const h = headers()
  const host = h.get('x-forwarded-host') || h.get('host') || process.env.VERCEL_URL || 'localhost:3000'
  const proto = h.get('x-forwarded-proto') || (process.env.VERCEL ? 'https' : 'http')
  return host.startsWith('http') ? host : `${proto}://${host}`
}

export default async function InstagramIndexPage() {
  const origin = getOrigin()
  let items: any[] = []
  try {
    const res = await fetch(`${origin}/api/ig`, { cache: 'no-store' })
    const json = await res.json()
    items = Array.isArray(json.items) ? json.items : []
  } catch {}

  return (
    <main className="min-h-screen p-6 bg-gray-50 dark:bg-neutral-900">
      <div className="max-w-4xl mx-auto space-y-6">
        <h1 className="text-2xl font-bold">Instagram — Lista</h1>
        {!items.length ? (
          <p className="opacity-70 text-sm">Sem posts.</p>
        ) : (
          <ul className="space-y-3">
            {items.map((it: any) => {
              const id = String(it?.id ?? '').trim()
              const href = id ? `/instagram/${encodeURIComponent(id)}?debug=1` : '#'
              return (
                <li key={id} className="border rounded-lg p-3 bg-white dark:bg-neutral-800 flex items-center gap-3">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={it.media_url} alt="" className="w-16 h-16 object-cover rounded" />
                  <div className="flex-1">
                    <div className="text-xs opacity-60">ID: {id}</div>
                    <a href={href} className="text-sm font-medium hover:underline">Abrir detalhes</a>
                    <div className="text-xs opacity-70">{it.timestamp ? new Date(it.timestamp).toLocaleString() : ''}</div>
                  </div>
                </li>
              )
            })}
          </ul>
        )}
      </div>
    </main>
  )
}
