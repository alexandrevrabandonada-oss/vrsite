import type { MetadataRoute } from 'next'
import { getSiteUrl } from '@/src/lib/seo'

export default function robots(): MetadataRoute.Robots {
  const site = getSiteUrl()
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/']
    },
    sitemap: `${site}/sitemap.xml`,
    host: site
  }
}
