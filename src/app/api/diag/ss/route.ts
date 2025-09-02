import { NextResponse } from "next/server";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const id = searchParams.get("id") || "seed-1";

  try {
    // Teste de import
    const mod = await import("@/src/lib/ig-data").catch((err) => {
      throw { stage: "import", message: err.message, stack: err.stack };
    });

    let item = null;
    try {
      item = await mod.getIgItemById(id);
    } catch (err: any) {
      throw { stage: "call", message: err.message, stack: err.stack };
    }

    return NextResponse.json({
      ok: true,
      id,
      item,
      diag: {
        node: process.version,
        cwd: process.cwd(),
      },
    });
  } catch (err: any) {
    return NextResponse.json({
      ok: false,
      error: err,
    });
  }
}
