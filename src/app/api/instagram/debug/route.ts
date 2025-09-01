/**
 * src/app/api/instagram/debug/route.ts
 */
import { NextRequest, NextResponse } from "next/server";
import { IG_GRAPH_BASE, getToken, getUserId, fbMe, igAccount } from "@/lib/ig";

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  const token = getToken(req);
  const igUserId = getUserId(req);

  const me = token ? await fbMe(token) : null;
  const ig = (token && igUserId) ? await igAccount(igUserId, token) : null;

  return NextResponse.json({
    hasToken: !!token,
    hasUserId: !!igUserId,
    env: process.env.VERCEL_ENV || "development",
    base: IG_GRAPH_BASE,
    meStatus: me?.status ?? null,
    me: me?.body ?? null,
    igStatus: ig?.status ?? null,
    ig: ig?.body ?? null
  });
}
