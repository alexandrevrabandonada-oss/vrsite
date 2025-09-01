import type { MetadataRoute } from 'next'
import { getSiteUrl } from '@/src/lib/seo'

export default function sitemap(): MetadataRoute.Sitemap {
  const site = getSiteUrl()
  const now = new Date().toISOString()

  const routes = [
    '',
    '/posts',
    '/about',
    '/contact',
    '/games',
    '/artigos',
    '/hqs'
  ]

  return routes.map((r) => ({
    url: `${site}${r}`,
    lastModified: now,
    changeFrequency: 'weekly',
    priority: r === '' ? 1 : 0.6
  }))
}
