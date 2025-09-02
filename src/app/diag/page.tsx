'use client'

import { useEffect, useState } from 'react'

type Res = any

export default function DiagPage() {
  const [diag, setDiag] = useState<Res | null>(null)
  const [list, setList] = useState<Res | null>(null)
  const [one, setOne] = useState<Res | null>(null)
  const [onedebug, setOneDebug] = useState<Res | null>(null)
  const q = new URLSearchParams(typeof window !== 'undefined' ? window.location.search : '')
  const testId = q.get('id') || 'seed-1'

  useEffect(() => {
    ;(async () => {
      const [d, l, o, od] = await Promise.all([
        fetch('/api/diag').then(r => r.json()).catch(() => null),
        fetch('/api/ig').then(r => r.json()).catch(() => null),
        fetch(`/api/ig?id=${encodeURIComponent(testId)}`).then(r => r.json()).catch(() => null),
        fetch(`/api/ig?id=${encodeURIComponent(testId)}&debug=1&_dump=1`).then(r => r.json()).catch(() => null),
      ])
      setDiag(d); setList(l); setOne(o); setOneDebug(od)
    })()
  }, [testId])

  return (
    <main className="min-h-screen p-6 bg-gray-50 dark:bg-neutral-900">
      <div className="max-w-4xl mx-auto space-y-6">
        <h1 className="text-2xl font-bold">Diagnóstico</h1>
        <p className="text-sm opacity-70">Teste de ambiente e API. Você pode passar <code>?id=SEU_ID</code> para testar outro item (padrão seed-1).</p>

        <section className="bg-white dark:bg-neutral-800 border rounded-xl p-4">
          <h2 className="font-semibold mb-2">/api/diag</h2>
          <pre className="text-xs overflow-auto">{JSON.stringify(diag, null, 2)}</pre>
        </section>

        <section className="bg-white dark:bg-neutral-800 border rounded-xl p-4">
          <h2 className="font-semibold mb-2">/api/ig (lista)</h2>
          <pre className="text-xs overflow-auto">{JSON.stringify(list, null, 2)}</pre>
        </section>

        <section className="bg-white dark:bg-neutral-800 border rounded-xl p-4">
          <h2 className="font-semibold mb-2">/api/ig?id={testId}</h2>
          <pre className="text-xs overflow-auto">{JSON.stringify(one, null, 2)}</pre>
        </section>

        <section className="bg-white dark:bg-neutral-800 border rounded-xl p-4">
          <h2 className="font-semibold mb-2">/api/ig?id={testId}&debug=1&_dump=1</h2>
          <pre className="text-xs overflow-auto">{JSON.stringify(onedebug, null, 2)}</pre>
        </section>

        <a className="text-sm underline" href="/">← Voltar para Home</a>
      </div>
    </main>
  )
}
