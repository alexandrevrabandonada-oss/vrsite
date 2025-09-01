/**
 * src/app/api/instagram/route.ts
 * Lista mídia do IG com queda-controlada e mensagens claras.
 */
import { NextRequest, NextResponse } from "next/server";
import { fetchMedia, getToken, getUserId } from "@/lib/ig";

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  const token = getToken(req);
  const igUserId = getUserId(req);

  if (!token || !igUserId) {
    return NextResponse.json(
      {
        error: "Configuração ausente",
        detail: {
          hasToken: !!token,
          hasUserId: !!igUserId,
          message:
            "Defina IG_ACCESS_TOKEN e IG_USER_ID ou use ?t= e ?id= para teste.",
        },
      },
      { status: 400 },
    );
  }

  const url = new URL(req.url);
  const limit = parseInt(url.searchParams.get("limit") || "12", 10);
  const raw = url.searchParams.get("raw");

  try {
    const data = await fetchMedia(igUserId, token, limit);

    if (raw) return NextResponse.json(data, { status: 200 });

    // resposta “reduzida” para o componente
    return NextResponse.json({
      ok: true,
      count: data.length,
      items: data.map((m) => ({
        id: m.id,
        type: m.media_type,
        image: m.media_url || m.thumbnail_url,
        caption: m.caption,
        permalink: m.permalink,
        ts: m.timestamp,
        user: m.username,
      })),
    });
  } catch (e: any) {
    // Normaliza o erro legível
    let payload: any = { error: "Falha ao buscar feed" };
    try {
      const parsed = JSON.parse(e.message);
      payload.detail = parsed;
    } catch {
      payload.detail = String(e.message || e);
    }
    return NextResponse.json(payload, { status: 400 });
  }
}
