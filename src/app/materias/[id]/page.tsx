import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { headers } from "next/headers";
import Link from "next/link";

type Child = {
  id?: string;
  media_type: string;
  media_url: string;
  thumbnail_url?: string;
};

type Item = {
  id: string;
  media_type: "IMAGE" | "VIDEO" | "CAROUSEL_ALBUM" | string;
  media_url: string;
  thumbnail_url?: string;
  permalink: string;
  caption?: string;
  username?: string;
  timestamp?: string;
  children?: { data: Child[] };
};

function getOrigin(): string {
  const h = headers();
  const proto = h.get("x-forwarded-proto") ?? "https";
  const host = h.get("x-forwarded-host") ?? h.get("host");
  if (host) return `${proto}://${host}`;
  const envSite = process.env.NEXT_PUBLIC_SITE_URL;
  if (envSite) return envSite.replace(/\/$/, "");
  const vercel = process.env.VERCEL_URL;
  if (vercel) return `https://${vercel}`;
  return "http://localhost:3000";
}

async function fetchFeed(): Promise<Item[]> {
  const origin = getOrigin();
  const url = `${origin}/api/instagram?raw=1`;
  const res = await fetch(url, { next: { revalidate: 120 } });
  if (!res.ok) {
    throw new Error(`API ${res.status}`);
  }
  const json = await res.json();
  const data = Array.isArray(json) ? json : Array.isArray(json?.data) ? json.data : [];
  return (data ?? []) as Item[];
}

async function fetchItem(id: string): Promise<Item | null> {
  const list = await fetchFeed();
  return list.find((x) => x.id === id) ?? null;
}

function pickImageForOg(item: Item): string | undefined {
  if (item.media_type === "IMAGE") return item.media_url;
  if (item.media_type === "VIDEO") return item.thumbnail_url ?? item.media_url;
  if (item.media_type === "CAROUSEL_ALBUM") {
    const first = item.children?.data?.[0];
    if (!first) return item.thumbnail_url ?? undefined;
    return first.thumbnail_url ?? first.media_url;
  }
  return item.thumbnail_url ?? undefined;
}

function toPlain(text?: string): string {
  if (!text) return "";
  return text.replace(/\s+/g, " ").trim();
}

export async function generateMetadata({
  params,
}: {
  params: { id: string };
}): Promise<Metadata> {
  try {
    const item = await fetchItem(params.id);
    if (!item) {
      return { title: "Matéria não encontrada • VR Abandonada" };
    }
    const titleBase =
      toPlain(item.caption)?.slice(0, 80) || "Matéria • VR Abandonada";
    const title = `${titleBase}${titleBase.length >= 80 ? "…" : ""}`;
    const description = item.caption
      ? toPlain(item.caption).slice(0, 160)
      : "Publicação do Instagram renderizada como matéria no site VR Abandonada.";
    const origin = getOrigin();
    const canonical = `${origin}/materias/${encodeURIComponent(item.id)}`;
    const ogImage = pickImageForOg(item);

    return {
      title,
      description,
      alternates: { canonical },
      openGraph: {
        title,
        description,
        url: canonical,
        siteName: "VR Abandonada",
        type: "article",
        images: ogImage ? [{ url: ogImage }] : undefined,
      },
      twitter: {
        card: "summary_large_image",
        title,
        description,
        images: ogImage ? [ogImage] : undefined,
      },
      robots: {
        index: true,
        follow: true,
      },
    };
  } catch {
    return { title: "Matéria • VR Abandonada" };
  }
}

export default async function MateriaPage({
  params,
}: {
  params: { id: string };
}) {
  const item = await fetchItem(params.id);
  if (!item) {
    notFound();
  }

  const published =
    item.timestamp ? new Date(item.timestamp).toLocaleString("pt-BR") : null;

  return (
    <article className="mx-auto max-w-3xl px-4 py-8 prose prose-neutral dark:prose-invert">
      <header>
        <h1 className="text-3xl font-bold leading-tight">
          {item.caption ? item.caption.split("\n")[0] : "Matéria"}
        </h1>
        <div className="mt-2 text-sm text-neutral-500 flex gap-2 flex-wrap">
          {item.username && <span>@{item.username}</span>}
          {published && (
            <time dateTime={item.timestamp ?? undefined}>{published}</time>
          )}
          <Link
            href={item.permalink}
            target="_blank"
            rel="noopener nofollow"
            className="underline"
            aria-label="Ver publicação no Instagram (abre em nova aba)"
          >
            Ver no Instagram
          </Link>
        </div>
      </header>

      <section className="mt-6">
        {/* Mídia */}
        {item.media_type === "IMAGE" && (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={item.media_url}
            alt={toPlain(item.caption) || "Imagem da matéria"}
            className="w-full rounded-xl border border-neutral-200 dark:border-neutral-800"
            loading="eager"
          />
        )}

        {item.media_type === "VIDEO" && (
          <video
            className="w-full rounded-xl border border-neutral-200 dark:border-neutral-800"
            controls
            preload="metadata"
            poster={item.thumbnail_url}
          >
            <source src={item.media_url} />
            Seu navegador não suporta vídeo HTML5.
          </video>
        )}

        {item.media_type === "CAROUSEL_ALBUM" && (
          <div className="grid gap-3 sm:grid-cols-2">
            {item.children?.data?.map((c, idx) => (
              <figure key={c.id ?? idx}>
                {c.media_type === "VIDEO" ? (
                  <video
                    className="w-full rounded-xl border border-neutral-200 dark:border-neutral-800"
                    controls
                    preload="metadata"
                    poster={c.thumbnail_url}
                  >
                    <source src={c.media_url} />
                    Seu navegador não suporta vídeo HTML5.
                  </video>
                ) : (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={c.media_url}
                    alt={`Slide ${idx + 1}`}
                    className="w-full rounded-xl border border-neutral-200 dark:border-neutral-800"
                    loading={idx === 0 ? "eager" : "lazy"}
                  />
                )}
              </figure>
            ))}
          </div>
        )}
      </section>

      {item.caption && (
        <section className="mt-6">
          <h2 className="text-xl font-semibold mb-2">Descrição</h2>
          <p style={{ whiteSpace: "pre-line" }}>{item.caption}</p>
        </section>
      )}

      <hr className="my-8 border-neutral-200 dark:border-neutral-800" />

      <nav className="text-sm">
        <Link href="/instagram" className="underline">
          ← Voltar para o feed
        </Link>
      </nav>
    </article>
  );
}