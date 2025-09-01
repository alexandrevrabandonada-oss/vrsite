"use client";
import { useEffect, useState } from "react";

type Item = {
  id: string;
  type: string;
  image?: string;
  caption?: string;
  permalink?: string;
  ts?: string;
  user?: string;
};

export default function InstagramFeed({ limit = 12 }: { limit?: number }) {
  const [items, setItems] = useState<Item[]>([]);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const url = `/api/instagram?limit=${limit}`;
    fetch(url, { cache: "no-store" })
      .then(r => r.json().then(j => ({ ok: r.ok, j })))
      .then(({ ok, j }) => {
        if (!ok) throw j;
        setItems(j.items || []);
      })
      .catch((e) => {
        setErr(typeof e === "string" ? e : JSON.stringify(e));
      })
      .finally(() => setLoading(false));
  }, [limit]);

  if (loading) return <p>Carregando Instagram…</p>;
  if (err) return <p>Erro ao carregar Instagram: {err}</p>;

  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((m) => (
        <a key={m.id} href={`/instagram/${m.id}`} className="card no-underline">
          {m.image && (
            // usamos <img> para evitar bloqueio de domínios no next/image
            <img src={m.image} alt={m.caption || "Post"} className="w-full h-auto rounded-xl" />
          )}
          <div className="mt-2 text-sm opacity-80 line-clamp-3">{m.caption}</div>
        </a>
      ))}
    </div>
  );
}
