'use client'
import { useEffect, useMemo, useRef, useState } from 'react'

type Props = {
  basePath: string // e.g. /hqs/minha-serie/cap-1
  totalPages: number
  rightToLeft?: boolean
}

export default function MangaReader({ basePath, totalPages, rightToLeft=false }: Props) {
  const [page, setPage] = useState(1)
  const containerRef = useRef<HTMLDivElement>(null)

  const src = useMemo(() => `${basePath}/${String(page).padStart(3,'0')}.webp`, [basePath, page])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight') next()
      if (e.key === 'ArrowLeft') prev()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [page, totalPages, rightToLeft])

  function next() {
    setPage(p => Math.min(totalPages, p + 1))
  }
  function prev() {
    setPage(p => Math.max(1, p - 1))
  }

  // Preload next image
  useEffect(() => {
    const n = page + 1
    if (n <= totalPages) {
      const img = new Image()
      img.src = `${basePath}/${String(n).padStart(3,'0')}.webp`
    }
  }, [page, basePath, totalPages])

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button className="px-3 py-1 rounded-lg border" onClick={rightToLeft ? next : prev}>Anterior</button>
        <div className="text-sm opacity-80">Página {page} / {totalPages}</div>
        <button className="px-3 py-1 rounded-lg border" onClick={rightToLeft ? prev : next}>Próxima</button>
        <button className="ml-auto px-3 py-1 rounded-lg border" onClick={() => containerRef.current?.requestFullscreen?.()}>Tela cheia</button>
      </div>
      <div ref={containerRef} className="card flex justify-center">
        <img src={src} alt={`Página ${page}`} className="w-full h-auto object-contain" />
      </div>
    </div>
  )
}
