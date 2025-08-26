'use client'
import { useEffect, useRef, useState } from 'react'
import * as pdfjs from 'pdfjs-dist'

// @ts-ignore - worker entry shipped in package
import workerSrc from 'pdfjs-dist/build/pdf.worker.mjs'
// @ts-ignore
pdfjs.GlobalWorkerOptions.workerSrc = workerSrc

type Props = { url: string }

export default function PdfViewer({ url }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [pdf, setPdf] = useState<pdfjs.PDFDocumentProxy | null>(null)
  const [pageNum, setPageNum] = useState(1)
  const [scale, setScale] = useState(1.2)

  useEffect(() => {
    let mounted = true
    ;(async () => {
      const loadingTask = pdfjs.getDocument(url)
      const doc = await loadingTask.promise
      if (!mounted) return
      setPdf(doc)
    })()
    return () => { mounted = false }
  }, [url])

  useEffect(() => {
    const render = async () => {
      if (!pdf || !canvasRef.current) return
      const page = await pdf.getPage(pageNum)
      const viewport = page.getViewport({ scale })
      const canvas = canvasRef.current
      const ctx = canvas.getContext('2d')!
      canvas.width = viewport.width
      canvas.height = viewport.height
      await page.render({ canvasContext: ctx, viewport }).promise
    }
    render()
  }, [pdf, pageNum, scale])

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <button className="px-3 py-1 rounded-lg border" onClick={() => setPageNum(p => Math.max(1, p-1))}>Anterior</button>
        <span className="text-sm opacity-80">Página {pageNum} / {pdf?.numPages ?? '?'}</span>
        <button className="px-3 py-1 rounded-lg border" onClick={() => setPageNum(p => Math.min((pdf?.numPages ?? p), p+1))}>Próxima</button>
        <div className="ml-4 flex items-center gap-2">
          <button className="px-2 py-1 rounded-lg border" onClick={() => setScale(s => Math.max(0.5, s-0.2))}>-</button>
          <span>{Math.round(scale*100)}%</span>
          <button className="px-2 py-1 rounded-lg border" onClick={() => setScale(s => Math.min(3, s+0.2))}>+</button>
        </div>
        <a href={url} className="ml-auto px-3 py-1 rounded-lg border no-underline" download>Baixar PDF</a>
      </div>
      <canvas ref={canvasRef} className="w-full h-auto rounded-xl shadow" />
    </div>
  )
}
