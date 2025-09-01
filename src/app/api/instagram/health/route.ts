/**
 * src/app/api/instagram/health/route.ts
 * Retorna 200 somente se /me(id,name) e /{IG_USER_ID} estiverem OK.
 */
import { NextResponse } from "next/server";
import { getToken, getUserId, fbMe, igAccount } from "@/lib/ig";

export const runtime = "nodejs";

export async function GET(request: Request) {
  const token = getToken(request);
  const igUserId = getUserId(request);

  if (!token || !igUserId) {
    return NextResponse.json(
      { ok: false, reason: "MISSING_ENV" },
      { status: 503 },
    );
  }
  const me = await fbMe(token);
  if (me.status !== 200) {
    return NextResponse.json(
      { ok: false, where: "me", status: me.status, body: me.body },
      { status: 502 },
    );
  }
  const ig = await igAccount(igUserId, token);
  if (ig.status !== 200) {
    return NextResponse.json(
      { ok: false, where: "igUser", status: ig.status, body: ig.body },
      { status: 502 },
    );
  }
  return NextResponse.json({ ok: true }, { status: 200 });
}
