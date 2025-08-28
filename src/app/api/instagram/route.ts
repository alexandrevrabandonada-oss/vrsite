import { NextResponse } from "next/server";

const FIELDS = [
  "id",
  "caption",
  "media_type",
  "media_url",
  "thumbnail_url",
  "permalink",
  "timestamp",
].join(",");

export const revalidate = 3600; // cache ISR de 1h

export async function GET(req: Request) {
  const token = process.env.IG_ACCESS_TOKEN;
  const igUserId = process.env.IG_USER_ID;

  if (!token) return NextResponse.json({ error: "Faltando IG_ACCESS_TOKEN" }, { status: 500 });
  if (!igUserId) return NextResponse.json({ error: "Faltando IG_USER_ID" }, { status: 500 });

  const { searchParams } = new URL(req.url);
  const after = searchParams.get("after") ?? "";
  const limit = searchParams.get("limit") ?? "24";

  const url = new URL(`https://graph.facebook.com/v20.0/${igUserId}/media`);
  url.searchParams.set("fields", FIELDS);
  url.searchParams.set("access_token", token);
  url.searchParams.set("limit", limit);
  if (after) url.searchParams.set("after", after);

  const res = await fetch(url.toString(), { next: { revalidate: 3600 } });
  const text = await res.text();
  if (!res.ok) {
    return NextResponse.json({ error: "FB error", detail: text }, { status: res.status });
  }
  return NextResponse.json(JSON.parse(text));
}

}
