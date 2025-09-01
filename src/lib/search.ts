import seed from '@/src/data/seed.json' assert { type: 'json' }
import { slugify } from '@/src/lib/text'

export type Doc = {
  id: string
  title: string
  excerpt?: string
  slug: string
  tags?: string[]
  date?: string
  image?: string
  source?: string
}

function norm(s: unknown) {
  return (String(s || '')).toLowerCase()
}

function scoreDoc(d: Doc, q: string) {
  const nQ = norm(q)
  let score = 0
  if (norm(d.title).includes(nQ)) score += 3
  if (norm(d.excerpt).includes(nQ)) score += 2
  if (d.tags?.some(t => norm(t).includes(nQ))) score += 1
  if (d.slug && slugify(d.slug).includes(slugify(nQ))) score += 1
  return score
}

export function getAllDocs(): Doc[] {
  // No futuro: carregar do Instagram/DB/etc. Por enquanto: seed local.
  return (seed as Doc[]).map(d => ({ ...d, source: d.source || 'seed' }))
}

export function searchDocs(q: string, limit = 20) {
  const all = getAllDocs()
  if (!q || !q.trim()) return all.slice(0, limit)
  const scored = all
    .map(d => ({ d, s: scoreDoc(d, q) }))
    .filter(x => x.s > 0)
    .sort((a,b) => b.s - a.s)
    .slice(0, limit)
    .map(x => x.d)
  return scored
}
