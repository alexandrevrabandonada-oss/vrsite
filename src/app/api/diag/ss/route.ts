import { NextResponse } from "next/server";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const id = searchParams.get("id") || "seed-1";

  try {
    const mod = await import("@/lib/ig-data").catch((err) => {
      throw { stage: "import", message: err?.message || String(err), stack: err?.stack || "" };
    });

    const getter = (mod as any).getIgItemById || (mod as any)?.default?.getIgItemById;
    if (typeof getter !== "function") {
      throw { stage: "fn-missing", message: "getIgItemById nÃ£o encontrado no mÃ³dulo ig-data" };
    }

    let item = null;
    try {
      item = await getter(id);
    } catch (err: any) {
      throw { stage: "call", message: err?.message || String(err), stack: err?.stack || "" };
    }

    return NextResponse.json({
      ok: true,
      id,
      item,
      diag: { node: process.version, cwd: process.cwd() },
    });
  } catch (err: any) {
    return NextResponse.json({ ok: false, error: err });
  }
}
