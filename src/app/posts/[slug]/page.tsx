
import { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

type IGItem = {
  id: string;
  media_type: string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

async function getItem(id: string) {
  const base = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000';
  const url = `${base}/api/instagram?limit=1&raw=1&id=${id}`; // our route ignores id, but we'll use permalink page with client list; keeping placeholder
  // For simplicity, use Graph per-id here:
  const IG_BASE = process.env.INSTAGRAM_GRAPH_BASE || 'https://graph.facebook.com/v20.0';
  const token = process.env.IG_ACCESS_TOKEN || '';
  const fields = ['id','caption','media_type','media_url','thumbnail_url','permalink','timestamp','username'].join(',');
  const res = await fetch(`${IG_BASE}/${id}?fields=${fields}&access_token=${encodeURIComponent(token)}`, { cache: 'no-store' });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json() as Promise<IGItem>;
}

export async function generateMetadata({ params }:{ params:{ slug: string } }): Promise<Metadata> {
  try {
    const item = await getItem(params.slug);
    const title = item.caption?.slice(0, 60) || 'Post do Instagram';
    const image = item.thumbnail_url || item.media_url;
    return {
      title: `${title} • VR Abandonada`,
      description: item.caption,
      openGraph: {
        title,
        description: item.caption,
        images: image ? [{ url: image }] : undefined,
      },
      twitter: {
        card: 'summary_large_image',
        title,
        description: item.caption,
        images: image ? [image] : undefined,
      },
    };
  } catch {
    return { title: 'Post • VR Abandonada' };
  }
}

export default async function Page({ params }:{ params:{ slug: string } }) {
  const item = await getItem(params.slug);

  const image = item.thumbnail_url || item.media_url;

  return (
    <main className="px-4 py-8 mx-auto max-w-3xl">
      <Link href="/instagram" className="text-sm text-zinc-400 hover:text-zinc-200">← Voltar</Link>
      <article className="mt-4 space-y-4">
        <h1 className="text-2xl font-semibold">{item.caption?.slice(0, 80) || 'Post'}</h1>
        <div className="relative w-full aspect-square rounded-lg overflow-hidden border border-zinc-800">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={image} alt={item.caption || 'Imagem do post'} className="object-cover w-full h-full" />
        </div>
        {item.caption && <p className="whitespace-pre-wrap text-zinc-200">{item.caption}</p>}
        <a href={item.permalink} target="_blank" className="text-sm text-blue-400 underline">Ver no Instagram</a>
      </article>
    </main>
  );
}
