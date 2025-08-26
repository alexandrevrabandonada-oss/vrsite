'use client'
import dynamic from 'next/dynamic'

const PdfViewer = dynamic(() => import('@/components/PdfViewer'), { ssr: false })

type Props = { params: { slug: string } }

export default function ArtigoPage({ params }: Props) {
  const url = `/artigos/${params.slug}.pdf`
  return (
    <section className="space-y-4">
      <h1>Artigo: {params.slug}</h1>
      <PdfViewer url={url} />
    </section>
  )
}
