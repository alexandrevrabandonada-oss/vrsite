'use client';

import Link from 'next/link';
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
    const base =
      typeof window === 'undefined'
        ? process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'
        : window.location.origin;

    fetch(`${base}/api/instagram`)
      .then(async (r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        const j = await r.json();
        const data: Item[] = Array.isArray(j?.data) ? j.data : [];
        setItems(data.slice(0, limit));
      })
      .catch((e) => setError(String(e)))
      .finally(() => setLoading(false));
  }, [limit]);

  if (loading) return <div className={className}>Carregando Instagram…</div>;
  if (error) return <div className={className}>Erro ao carregar Instagram: {error}</div>;
  if (!items.length) return <div className={className}>Nenhum post encontrado.</div>;

  return (
    <div
      className={`grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 ${className}`}
    >
      {items.map((item) => {
        const isVideo = item.media_type === 'VIDEO';
        const thumb = isVideo ? item.thumbnail_url || item.media_url : item.media_url;
        return (
          <Link
            key={item.id}
            href={`/instagram/${item.id}`}
            className="group relative block overflow-hidden rounded-xl bg-neutral-100 shadow hover:shadow-lg dark:bg-neutral-900"
          >
            <img
              src={thumb}
              alt={item.caption || 'Post do Instagram'}
              className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.03]"
              loading="lazy"
            />
            {isVideo && (
              <span className="absolute bottom-2 right-2 rounded bg-black/60 px-2 py-1 text-xs text-white">
                Vídeo
              </span>
            )}
          </Link>
        );
      })}
    </div>
  );
}
