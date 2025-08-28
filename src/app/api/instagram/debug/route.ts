import { NextResponse } from "next/server";

export async function GET() {
  const t = process.env.IG_ACCESS_TOKEN || "";
  const id = process.env.IG_USER_ID || "";

  // máscara: mostra só início/fim p/ comparar sem expor
  const masked =
    t.length > 16 ? `${t.slice(0, 6)}...${t.slice(-6)}` : t;

  return NextResponse.json({
    hasToken: Boolean(t),
    tokenLen: t.length,
    tokenPreview: masked,
    igUserId: id,
    vercelEnv: process.env.VERCEL_ENV || "unknown",
  });
}
