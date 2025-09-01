export const siteConfig = {
  siteName: 'VR Abandonada',
  siteUrl: process.env.NEXT_PUBLIC_SITE_URL || (typeof window === 'undefined'
    ? (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:3000')
    : window.location.origin),
  defaultTitle: 'VR Abandonada',
  defaultDescription: 'Portal VR Abandonada — posts, jogos, artigos e HQs.',
  twitterUser: '@seu_user',
  authorName: 'VR Abandonada',
}

export function getSiteUrl() {
  const url = siteConfig.siteUrl
  if (!url) return 'http://localhost:3000'
  return /^https?:\/\//i.test(url) ? url : `https://${url}`
}

export function ogDefaults() {
  const site = getSiteUrl()
  return {
    title: siteConfig.defaultTitle,
    description: siteConfig.defaultDescription,
    openGraph: {
      title: siteConfig.defaultTitle,
      description: siteConfig.defaultDescription,
      images: [`${site}/og-default.png`],
      url: site,
      type: 'website',
    },
    twitter: {
      card: 'summary_large_image',
      site: siteConfig.twitterUser,
      creator: siteConfig.twitterUser
    }
  } as const
}

export function jsonLdPerson(opts: { name: string; url: string; image?: string; sameAs?: string[] }) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Person',
    name: opts.name,
    url: opts.url,
    image: opts.image,
    sameAs: opts.sameAs || []
  }
}

export function jsonLdArticle(opts: {
  title: string
  description?: string
  url: string
  image?: string
  datePublished?: string
  authorName: string
}) {
  const data: any = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: opts.title,
    url: opts.url,
    author: { '@type': 'Person', name: opts.authorName },
  }
  if (opts.description) data.description = opts.description
  if (opts.image) data.image = [opts.image]
  if (opts.datePublished) data.datePublished = opts.datePublished
  return data
}
