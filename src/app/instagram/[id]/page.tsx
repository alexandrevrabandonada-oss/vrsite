import { Metadata } from 'next';
import { notFound } from 'next/navigation';

type IGItem = {
  id: string;
  media_type: 'IMAGE' | 'VIDEO' | 'CAROUSEL_ALBUM' | string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
};

async function getAllPosts() {
  const base = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000';
  const res = await fetch(`${base}/api/instagram`, { next: { revalidate: 300 } });
  if (!res.ok) return null;
  const json = await res.json();
  const data: IGItem[] = Array.isArray(json?.data) ? json.data : [];
  return data;
}

async function getPostById(id: string) {
  const posts = await getAllPosts();
  if (!posts) return null;
  return posts.find((p) => p.id === id) || null;
}

export async function generateMetadata({
  params,
}: {
  params: { id: string };
}): Promise<Metadata> {
  const post = await getPostById(params.id);
  if (!post) {
    return {
      title: 'Post não encontrado • Instagram',
    };
  }

  const title =
    (post.caption && post.caption.slice(0, 60)) || 'Post do Instagram';
  const description =
    (post.caption && post.caption.slice(0, 155)) || 'Post do Instagram';
  const image =
    post.media_type === 'VIDEO' ? post.thumbnail_url || post.media_url : post.media_url;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      images: image ? [{ url: image }] : undefined,
      type: 'article',
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: image ? [image] : undefined,
    },
  };
}

export default async function InstagramPostPage({
  params,
}: {
  params: { id: string };
}) {
  const post = await getPostById(params.id);
  if (!post) return notFound();

  const isVideo = post.media_type === 'VIDEO';
  const cover = isVideo ? post.thumbnail_url || post.media_url : post.media_url;

  return (
    <main className="container mx-auto max-w-3xl p-6">
      <a
        href="/instagram"
        className="mb-4 inline-block text-sm text-blue-600 hover:underline"
      >
        ← Voltar ao feed
      </a>

      <article className="overflow-hidden rounded-xl bg-white shadow dark:bg-neutral-900">
        <div className="bg-black">
          {isVideo ? (
            <img
              src={cover}
              alt={post.caption || 'Vídeo do Instagram'}
              className="w-full object-contain"
            />
          ) : (
            <img
              src={post.media_url}
              alt={post.caption || 'Imagem do Instagram'}
              className="w-full object-contain"
            />
          )}
        </div>

        <div className="p-5">
          {post.username && (
            <div className="mb-2 text-sm text-neutral-500">@{post.username}</div>
          )}

          {post.caption && (
            <p className="whitespace-pre-line text-neutral-800 dark:text-neutral-200">
              {post.caption}
            </p>
          )}

          <div className="mt-4 flex flex-wrap items-center gap-3">
            <a
              className="rounded-lg bg-neutral-100 px-3 py-2 text-sm hover:bg-neutral-200 dark:bg-neutral-800 dark:hover:bg-neutral-700"
              href="/instagram"
            >
              Voltar ao feed
            </a>
            <a
              className="rounded-lg bg-blue-600 px-3 py-2 text-sm text-white hover:bg-blue-700"
              href={post.permalink}
              target="_blank"
              rel="noopener noreferrer"
            >
              Abrir no Instagram
            </a>
          </div>
        </div>
      </article>
    </main>
  );
}
