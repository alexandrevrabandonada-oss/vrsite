'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';

type Item = {
  id: string;
  media_type: string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

export default function InstagramFeed({ limit = 9 }: { limit?: number }) {
  const [items, setItems] = useState<Item[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const run = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(`/api/instagram?limit=${limit}`);
        const json = await res.json();
        if (!res.ok) {
          setError(JSON.stringify(json));
          return;
        }
        setItems(json.data || []);
      } catch (e: any) {
        setError(String(e));
      } finally {
        setLoading(false);
      }
    };
    run();
  }, [limit]);

  if (loading) return <p>Carregando Instagram…</p>;
  if (error) return <p>Erro ao carregar Instagram: {error}</p>;

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {items.map((it) => (
        <article key={it.id} className="rounded-xl overflow-hidden border border-neutral-200 bg-white">
          <div className="relative aspect-square">
            <Image
              src={it.thumbnail_url || it.media_url}
              alt={it.caption || 'Post do Instagram'}
              fill
              sizes="(max-width: 768px) 100vw, 33vw"
              style={{ objectFit: 'cover' }}
            />
          </div>
          <div className="p-3 space-y-2">
            <h3 className="font-semibold text-sm line-clamp-2">{it.caption || 'Sem legenda'}</h3>
            <div className="text-xs text-neutral-500">{new Date(it.timestamp || '').toLocaleString() || ''}</div>
            <Link href={it.permalink} target="_blank" className="text-blue-600 text-sm underline">
              Ver no Instagram
            </Link>
          </div>
        </article>
      ))}
    </div>
  );
}
