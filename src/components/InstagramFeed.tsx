import Image from 'next/image'

type Media = {
  id: string
  caption?: string
  media_url: string
  media_type: 'IMAGE'|'VIDEO'|'CAROUSEL_ALBUM'
  thumbnail_url?: string
  permalink: string
}

async function getFeed() {
  try {
    const res = await fetch(`${process.env.NEXT_PUBLIC_SITE_URL ?? ''}/api/instagram`, { next: { revalidate: 3600 } })
    if (!res.ok) throw new Error('bad status')
    const data = await res.json()
    return data.items as Media[]
  } catch {
    // Fallback mocked items for dev without token
    return [
      {
        id: 'mock1',
        caption: 'Post de exemplo (configure IG_ACCESS_TOKEN para feed real)',
        media_url: '/placeholder/insta1.jpg',
        media_type: 'IMAGE',
        permalink: '#',
      },
      {
        id: 'mock2',
        caption: 'Volta Redonda — exemplo de grid',
        media_url: '/placeholder/insta2.jpg',
        media_type: 'IMAGE',
        permalink: '#',
      },
    ] as Media[]
  }
}

export default async function InstagramFeed() {
  const items = await getFeed()
  return (
    <section className="space-y-4">
      <h1>Início</h1>
      <p className="opacity-80">Últimos posts do Instagram</p>
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        {items.map(item => (
          <a key={item.id} href={item.permalink} target="_blank" className="card no-underline">
            <div className="relative w-full aspect-square overflow-hidden rounded-xl">
              <Image
                src={item.media_type === 'VIDEO' ? (item.thumbnail_url ?? item.media_url) : item.media_url}
                alt={item.caption ?? 'Instagram post'}
                fill
                sizes="(max-width:768px) 100vw, 33vw"
                className="object-cover"
              />
            </div>
            {item.caption && <p className="mt-2 text-sm line-clamp-2">{item.caption}</p>}
          </a>
        ))}
      </div>
    </section>
  )
}
