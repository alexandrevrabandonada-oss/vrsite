import { Suspense } from 'react'
import SearchClient from './search-client'

export const dynamic = 'force-dynamic'

export default function Page() {
  return (
    <Suspense fallback={<main className="max-w-4xl mx-auto p-6">Carregando busca…</main>}>
      <SearchClient />
    </Suspense>
  )
}
