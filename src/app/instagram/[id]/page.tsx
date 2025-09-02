import { notFound } from 'next/navigation'
import { getIgItemById } from '@/lib/ig-data'
export const dynamic = 'force-dynamic'

export default async function InstagramDetail({ params, searchParams }: any) {
  const id = String(params?.id || '')
  const debug = (searchParams?.debug === '1') || (Array.isArray(searchParams?.debug) && searchParams?.debug[0] === '1')
  const item = await getIgItemById(id)
  if (!item) {
    if (debug) {
      return <main className="min-h-screen p-6"><div className="max-w-3xl mx-auto space-y-4"><h1 className="text-lg font-semibold">Post nÃ£o encontrado (debug)</h1><p className="text-sm opacity-70">id recebido: <code>{id}</code></p></div></main>
    }
    notFound()
  }
  return (<main className="min-h-screen p-6"><div className="max-w-3xl mx-auto space-y-4"><a href="/" className="text-sm opacity-75 hover:opacity-100">â† Voltar</a><img src={item.media_url} alt={item.caption || 'Post'} className="w-full rounded-xl border object-cover" /><article className="border rounded-xl p-4"><p className="whitespace-pre-wrap">{item.caption || ''}</p></article></div></main>)
}
