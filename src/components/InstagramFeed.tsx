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
    const base =
      typeof window === 'undefined'
        ? ''
        : (process.env.NEXT_PUBLIC_SITE_URL &&
            /^https?:\/\//.test(process.env.NEXT_PUBLIC_SITE_URL)
            ? process.env.NEXT_PUBLIC_SITE_URL
            : '');

    const initialUrl = `${base || ''}/api/instagram`;

    async function getJsonWithRedirect(u: string, maxHops = 3): Promise<any> {
      let url = u;
      for (let i = 0; i < maxHops; i++) {
        const res = await fetch(url, { cache: 'no-store', redirect: 'manual' as RequestRedirect });
        // 200 OK
        if (res.status >= 200 && res.status < 300) {
          try {
            return await res.json();
          } catch (e) {
            const t = await res.text();
            throw new Error(`Resposta não-JSON: ${t.slice(0, 200)}`);
          }
        }
        // Redirects 301/302/307/308
        if ([301, 302, 307, 308].includes(res.status)) {
          const loc = res.headers.get('Location');
          if (!loc) throw new Error(`HTTP ${res.status} sem Location`);
          // Resolve relativo ao origin atual
          const nextUrl = new URL(loc, window.location.origin).toString();
          url = nextUrl;
          continue;
        }
        // Outros erros
        const text = await res.text();
        throw new Error(`HTTP ${res.status} - ${text.slice(0, 300)}`);
      }
      throw new Error(`Muitos redirecionamentos (>${maxHops})`);
    }

    getJsonWithRedirect(initialUrl)
      .then((json) => {
        const data: Item[] = Array.isArray(json?.data) ? json.data : [];
        setItems(limit ? data.slice(0, limit) : data);
      })
      .catch((e: any) => setError(e?.message ?? String(e)))
      .finally(() => setLoading(false));
  }, [limit]);

  if (loading) return <div className="p-4">Carregando feed…</div>;
  if (error) {
    return (
      <div className="p-4 text-sm">
        <div className="text-red-600 font-medium mb-1">Erro ao carregar Instagram</div>
        <pre className="whitespace-pre-wrap break-words bg-neutral-100 dark:bg-neutral-900 p-3 rounded">
          {error}
        </pre>
        <div className="text-neutral-600 dark:text-neutral-400 mt-2">
          Dica: abra <code>/api/instagram</code> no navegador. Se abrir JSON, a lista renderiza aqui.
        </div>
      </div>
    );
  }
  if (!items.length) return <div className="p-4">Nenhuma mídia encontrada.</div>;

  return (
    <div className={`grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 ${className}`}>
      {items.map((m) => {
        const imgSrc = m.media_type === 'VIDEO' ? m.thumbnail_url ?? m.media_url : m.media_url;
        return (
          <a
            key={m.id}
            href={m.permalink}
            target="_blank"
            rel="noopener noreferrer"
            className="group block rounded-lg overflow-hidden border"
          >
            <div className="aspect-square bg-neutral-200 dark:bg-neutral-800">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                alt={m.caption?.slice(0, 120) ?? 'post'}
                src={imgSrc}
                className="w-full h-full object-cover group-hover:opacity-90 transition"
              />
            </div>
          </a>
        );
      })}
    </div>
  );
}
