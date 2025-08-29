'use client';

import { useEffect, useState } from 'react';

type Item = {
  id: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM' | string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

export default function InstagramFeed({
  limit = 12,
  className = '',
}: {
  limit?: number;
  className?: string;
}) {
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    async function load() {
      try {
        setLoading(true);
        setError(null);

        // Base absoluto quando no server; relativo no client
        const base =
          typeof window === 'undefined'
            ? process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3000'
            : '';

        // Permite debug via query (?t= e ?id=) quando renderiza no client
        const search =
          typeof window !== 'undefined'
            ? new URLSearchParams(window.location.search)
            : null;

        const t = search?.get('t') ?? undefined;
        const id = search?.get('id') ?? undefined;

        const qs = new URLSearchParams();
        if (t) qs.set('t', t);
        if (id) qs.set('id', id);

        const url = `${base}/api/instagram${qs.toString() ? `?${qs.toString()}` : ''}`;

        const res = await fetch(url, {
          signal: controller.signal,
          // Em prod você pode trocar para { next: { revalidate: 900 } }
          cache: 'no-store',
        });

        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }

        const json = await res.json();
        const data: Item[] = Array.isArray(json) ? json : json.data ?? [];
        setItems(data.slice(0, limit));
      } catch (err: any) {
        if (err?.name !== 'AbortError') {
          setError(err?.message ?? 'Erro desconhecido');
        }
      } finally {
        setLoading(false);
      }
    }

    load();
    return () => controller.abort();
  }, [limit]);

  if (loading) {
    return <p className="text-sm text-neutral-500">Carregando Instagram…</p>;
  }

  if (error) {
    return (
      <div className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">
        Erro ao carregar Instagram: {error}
        <div className="mt-2 text-xs text-red-600/80">
          Dica: abra <code>/api/instagram</code> no navegador. Se abrir JSON, a lista renderiza aqui.
        </div>
      </div>
    );
  }

  if (!items?.length) {
    return <p className="text-sm text-neutral-500">Nenhuma mídia encontrada.</p>;
  }

  return (
    <div className={
      'grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 ' + className
    }>
      {items.map((item) => {
        const isVideo = item.media_type === 'VIDEO';
        const thumb = item.thumbnail_url ?? item.media_url;
        return (
          <a
            key={item.id}
            href={item.permalink}
            target="_blank"
            rel="noreferrer noopener"
            className="group relative block overflow-hidden rounded-xl border border-neutral-200/60 bg-white shadow-sm transition hover:shadow-md dark:border-neutral-800 dark:bg-neutral-900"
          >
            {/* thumb / poster */}
            <img
              src={thumb}
              alt={item.caption ?? 'Instagram'}
              className="h-36 w-full object-cover sm:h-40 md:h-44 lg:h-48"
              loading="lazy"
            />

            {/* badge de vídeo */}
            {isVideo && (
              <span className="absolute right-2 top-2 rounded-md bg-black/70 px-2 py-1 text-[10px] font-medium text-white">
                Vídeo
              </span>
            )}

            {/* legenda curta on hover */}
            {item.caption && (
              <div className="pointer-events-none absolute inset-x-0 bottom-0 max-h-20 translate-y-6 bg-gradient-to-t from-black/70 to-transparent p-3 text-xs text-white opacity-0 transition group-hover:translate-y-0 group-hover:opacity-100">
                <p className="line-clamp-3">{item.caption}</p>
              </div>
            )}
          </a>
        );
      })}
    </div>
  );
}
