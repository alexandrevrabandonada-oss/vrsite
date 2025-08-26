import { NextResponse } from 'next/server'

export const revalidate = 3600 // cache 1h

export async function GET() {
  const token = process.env.IG_ACCESS_TOKEN
  const userId = process.env.IG_USER_ID

  // If no token, return mock to help local dev
  if (!token) {
    return NextResponse.json({
      items: [
        { id: 'mock1', caption: 'Configure IG_ACCESS_TOKEN para feed real', media_url: '/placeholder/insta1.jpg', media_type: 'IMAGE', permalink: '#' },
        { id: 'mock2', caption: 'Mais um exemplo', media_url: '/placeholder/insta2.jpg', media_type: 'IMAGE', permalink: '#' },
      ]
    }, { status: 200 })
  }

  try {
    const fields = 'id,caption,media_url,thumbnail_url,permalink,media_type'
    const endpoint = userId
      ? `https://graph.instagram.com/${userId}/media?fields=${fields}&access_token=${token}`
      : `https://graph.instagram.com/me/media?fields=${fields}&access_token=${token}`

    const res = await fetch(endpoint, { cache: 'no-store' })
    if (!res.ok) throw new Error(await res.text())
    const data = await res.json()
    return NextResponse.json({ items: data.data ?? [] })
  } catch (e) {
    return NextResponse.json({ error: 'Falha ao buscar feed', detail: String(e) }, { status: 500 })
  }
}
