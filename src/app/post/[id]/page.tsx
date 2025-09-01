// src/app/post/[id]/page.tsx
import { notFound } from "next/navigation";
import { getBaseUrl } from "@/lib/baseUrl";

type Item = {
  id: string;
  media_type: string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  timestamp?: string;
  username?: string;
  children?: { data: { id: string; media_type: string; media_url: string }[] };
};

async function getFeed(): Promise<{ data?: Item[]; error?: any }> {
  const base = getBaseUrl();
  const url = `${base}/api/instagram?limit=50`;
  const res = await fetch(url, { cache: "no-store" });
  if (!res.ok) return { error: await res.text() };
  return res.json();
}

export async function generateMetadata({ params }: { params: { id: string } }) {
  const feed = await getFeed();
  const item = feed.data?.find((i) => i.id === params.id);
  if (!item) return { title: "Post nÃ£o encontrado â€¢ VR Abandonada" };
  const title = item.caption ? item.caption.slice(0, 60) : "Post do Instagram";
  const image = item.thumbnail_url || item.media_url;
  return {
    title: `${title} â€¢ VR Abandonada`,
    description:
      item.caption?.slice(0, 160) || "MatÃ©ria integrada do Instagram.",
    openGraph: {
      title,
      images: image ? [image] : [],
    },
  };
}

export default async function PostPage({ params }: { params: { id: string } }) {
  const feed = await getFeed();
  const item = feed.data?.find((i) => i.id === params.id);
  if (!item) notFound();

  const isVideo = item.media_type === "VIDEO";
  const isCarousel = item.media_type === "CAROUSEL_ALBUM";

  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <article>
        <header className="mb-6">
          <h1 className="text-2xl font-bold mb-2">
            {item.caption ? item.caption.split("\n")[0] : "Post do Instagram"}
          </h1>
          <p className="text-sm text-neutral-600 dark:text-neutral-400">
            {item.timestamp ? new Date(item.timestamp).toLocaleString() : null}
          </p>
        </header>

        <section className="rounded-lg overflow-hidden border bg-black aspect-video mb-4 flex items-center justify-center">
          {isVideo ? (
            <video
              src={item.media_url}
              controls
              playsInline
              className="w-full h-full object-contain bg-black"
              preload="metadata"
            />
          ) : isCarousel ? (
            <div className="space-y-3 w-full">
              {item.children?.data?.map((ch) => (
                <div key={ch.id} className="w-full">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={ch.media_url}
                    alt={item.caption || "Imagem do carrossel"}
                    className="w-full"
                  />
                </div>
              ))}
            </div>
          ) : (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={item.media_url}
              alt={item.caption || "Imagem do post"}
              className="w-full h-auto object-contain bg-black"
            />
          )}
        </section>

        {item.caption ? (
          <div className="prose dark:prose-invert max-w-none">
            {item.caption.split("\n").map((line, i) => (
              <p key={i}>{line}</p>
            ))}
          </div>
        ) : null}

        <footer className="mt-6 text-sm">
          <a
            href={item.permalink}
            target="_blank"
            rel="noopener noreferrer"
            className="underline text-neutral-700 dark:text-neutral-300"
          >
            Ver no Instagram
          </a>
        </footer>
      </article>
    </main>
  );
}
