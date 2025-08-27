"use client";

import { useEffect, useRef, useState } from "react";
import { GlobalWorkerOptions, getDocument, version as pdfjsVersion } from "pdfjs-dist";

type Props = { url: string };

export default function PdfViewer({ url }: Props) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [pageNum, setPageNum] = useState(1);
  const [numPages, setNumPages] = useState<number | null>(null);
  const [scale, setScale] = useState(1.2);

  // Configura o worker via CDN para evitar problemas de bundler
  useEffect(() => {
    // exemplo: //cdnjs.cloudflare.com/ajax/libs/pdf.js/4.7.76/pdf.worker.min.js
    GlobalWorkerOptions.workerSrc = `https://cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsVersion}/pdf.worker.min.js`;
  }, []);

  // Carrega e renderiza a página atual
  useEffect(() => {
    let cancelled = false;

    (async () => {
      const loadingTask = getDocument(url);
      const pdf = await loadingTask.promise;
      if (cancelled) return;

      if (!numPages) setNumPages(pdf.numPages);

      const page = await pdf.getPage(pageNum);
      const viewport = page.getViewport({ scale });
      const canvas = canvasRef.current;
      if (!canvas) return;

      const ctx = canvas.getContext("2d");
      if (!ctx) return;

      canvas.width = viewport.width;
      canvas.height = viewport.height;

      await page.render({ canvasContext: ctx, viewport }).promise;
    })().catch((err) => {
      console.error("Erro ao renderizar PDF:", err);
    });

    return () => {
      cancelled = true;
    };
  }, [url, pageNum, scale, numPages]);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <button className="px-3 py-1 rounded-lg border" onClick={() => setPageNum((p) => Math.max(1, p - 1))} disabled={pageNum <= 1}>
          Anterior
        </button>
        <span className="text-sm opacity-80">Página {pageNum} / {numPages ?? "…"}</span>
        <button className="px-3 py-1 rounded-lg border" onClick={() => setPageNum((p) => (numPages ? Math.min(numPages, p + 1) : p + 1))} disabled={!!numPages && pageNum >= numPages}>
          Próxima
        </button>
        <div className="ml-4 flex items-center gap-2">
          <button className="px-2 py-1 rounded-lg border" onClick={() => setScale((s) => Math.max(0.5, s - 0.2))}>-</button>
          <span>{Math.round(scale * 100)}%</span>
          <button className="px-2 py-1 rounded-lg border" onClick={() => setScale((s) => Math.min(3, s + 0.2))}>+</button>
        </div>
        <a href={url} className="ml-auto px-3 py-1 rounded-lg border no-underline" download>
          Baixar PDF
        </a>
      </div>

      <canvas ref={canvasRef} className="w-full h-auto rounded-xl shadow" />
    </div>
  );
}
