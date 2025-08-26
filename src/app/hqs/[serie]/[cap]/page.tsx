import MangaReader from '@/components/MangaReader'

type Props = { params: { serie: string, cap: string } }

export default function CapituloPage({ params }: Props) {
  const basePath = `/hqs/${params.serie}/${params.cap}`
  const totalPages = 3 // Atualize conforme seu capítulo
  return (
    <section className="space-y-4">
      <h1>{params.serie} — {params.cap}</h1>
      <MangaReader basePath={basePath} totalPages={totalPages} />
    </section>
  )
}
