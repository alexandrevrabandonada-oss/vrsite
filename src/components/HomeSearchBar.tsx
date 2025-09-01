'use client'

import * as React from 'react'
import { useRouter } from 'next/navigation'

export default function HomeSearchBar() {
  const [q, setQ] = React.useState('')
  const router = useRouter()

  function onSubmit(e: React.FormEvent) {
    e.preventDefault()
    router.push(`/search?q=${encodeURIComponent(q)}`)
  }

  return (
    <section className="w-full bg-gray-50 border-b">
      <div className="max-w-5xl mx-auto px-4 py-10">
        <h1 className="text-2xl sm:text-3xl font-semibold">Pesquisar conteúdos</h1>
        <p className="text-sm text-gray-600 mt-1">Busque por temas como educação, saúde, trabalho…</p>
        <form onSubmit={onSubmit} className="mt-4 flex gap-2">
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Digite um termo…"
            className="flex-1 border rounded-lg px-3 py-2"
          />
          <button type="submit" className="px-4 py-2 rounded-lg border shadow-sm">Buscar</button>
        </form>
      </div>
    </section>
  )
}
