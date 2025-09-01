export function slugify(input: string) {
  return (input || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\\u0300-\\u036f]/gu, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

export function extractTags(text: string) {
  if (!text) return [] as string[]
  const base = text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\\u0300-\\u036f]/gu, ' ')
  const candidates = base.split(/[^a-z0-9]+/g).filter(Boolean)
  const stop = new Set(['a','o','e','de','da','do','das','dos','em','para','por','na','no','nas','nos','um','uma','uns','umas','com','sem','que','se'])
  const tags = new Set<string>()
  for (const w of candidates) {
    if (w.length < 3) continue
    if (stop.has(w)) continue
    tags.add(w)
  }
  return Array.from(tags).slice(0, 10)
}
