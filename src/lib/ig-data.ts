export type IgItem = {
  id: string
  media_url: string
  permalink?: string
  caption?: string
  timestamp?: string
}

// Carrega seed local em runtime (Node)
async function loadSeed(): Promise<IgItem[]> {
  // Import dinÃ¢mico para nÃ£o entrar no bundle do client
  try {
    const mod = await import('@/data/ig-seed.json')
    const arr = (mod?.default ?? []) as any[]
    return Array.isArray(arr) ? arr as IgItem[] : []
  } catch {
    return []
  }
}

export async function listIgItems(): Promise<IgItem[]> {
  // Futuro: aqui entra Graph API / cache / DB.
  return await loadSeed()
}

export async function getIgItemById(id: string): Promise<IgItem | null> {
  if (!id) return null
  const items = await listIgItems()
  const found = items.find(x => String(x.id) === String(id))
  return found ?? null
}

