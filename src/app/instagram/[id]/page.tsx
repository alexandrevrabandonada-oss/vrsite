import { notFound } from "next/navigation";

async function fetchPost(id: string, base: string, token: string) {
  const u = new URL(`${base}/${id}`);
  u.searchParams.set(
    "fields",
    "id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username,children{media_type,media_url,thumbnail_url,permalink}",
  );
  u.searchParams.set("access_token", token);
  const res = await fetch(u.toString(), { cache: "no-store" });
  if (!res.ok) return null;
  return res.json();
}

export default async function Page({
  params,
  searchParams,
}: {
  params: { id: string };
  searchParams: Record<string, string>;
}) {
  const base =
    process.env.INSTAGRAM_GRAPH_BASE || "https://graph.instagram.com";
  const token = (
    process.env.IG_ACCESS_TOKEN ||
    process.env.IG_LONG_LIVED_TOKEN ||
    ""
  ).trim();
  const tokenOverride = (searchParams?.t || "").trim();
  const tokenUse = tokenOverride || token;
  if (!tokenUse) notFound();

  const post = await fetchPost(params.id, base, tokenUse);
  if (!post) notFound();

  const isVideo = post.media_type === "VIDEO";

  return (
    <main className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">@{post.username}</h1>
      <div className="rounded-lg overflow-hidden border border-white/10">
        {isVideo ? (
          <video src={post.media_url} controls className="w-full h-auto" />
        ) : (
          <img
            src={post.media_url}
            alt={post.caption || "Post"}
            className="w-full h-auto"
          />
        )}
      </div>
      {post.caption && (
        <p className="mt-4 whitespace-pre-wrap">{post.caption}</p>
      )}
      <div className="mt-3 text-sm opacity-70">
        {post.timestamp ? new Date(post.timestamp).toLocaleString() : ""}
      </div>
    </main>
  );
}
