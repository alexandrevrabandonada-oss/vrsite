# apply-instagram-patch.ps1 - versão ASCII simples

$ErrorActionPreference = "Stop"
$root   = Get-Location
$envPath = Join-Path $root ".env.local"

# ====== SEUS DADOS (edite aqui se precisar) ======
$IG_ACCESS_TOKEN = @"
EAAScb5ZAhWZAcBPeU2gbiPLgDAXHUBJ0iGNfOO044mkIcJBJ58U8jVdHzIeMB63ZBwOm4okZCKCG0BJs7BZBW7ENv4lM1zO4EV95NyFRLwRLz3UQWRe5RId9VeGZBuYzmbnihgGyDRetjSvZCo4BVIZA9AtK3qqbQQU9X5oAdyRoZCPQZCgXMmiBZAIZALIfmuj0nsB6LCiCUETuREIywu2M
"@.Trim()

$IG_USER_ID = "17841446140635566"
$INSTAGRAM_GRAPH_BASE = "https://graph.instagram.com"

function Clean-Str([string]$s) {
  if (-not $s) { return "" }
  $x = $s.Trim()
  $x = $x -replace '(^"+|"+$)',''
  $x = $x -replace "(^'+|'+$)",''
  return $x
}

$IG_ACCESS_TOKEN = Clean-Str $IG_ACCESS_TOKEN
if (-not $IG_ACCESS_TOKEN) { throw "IG_ACCESS_TOKEN vazio" }
if (-not $IG_USER_ID) { throw "IG_USER_ID vazio" }

# ====== 1) .env.local ======
$envContent = @"
IG_ACCESS_TOKEN=$IG_ACCESS_TOKEN
IG_USER_ID=$IG_USER_ID
INSTAGRAM_GRAPH_BASE=$INSTAGRAM_GRAPH_BASE
"@.Trim() + "`r`n"
Set-Content -Path $envPath -Value $envContent -Encoding UTF8
Write-Host "[ok] .env.local escrito"

# ====== helper p/ salvar arquivos ======
function Write-TextFile($relativePath, $text) {
  $full = Join-Path $root $relativePath
  $dir  = Split-Path $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Set-Content -Path $full -Value $text -Encoding UTF8
  Write-Host "[ok] " $relativePath
}

# ====== 2) src/lib/ig.ts ======
$ig_ts = @'
import type { NextRequest } from "next/server";

export const IG_BASE =
  (process.env.INSTAGRAM_GRAPH_BASE || "https://graph.instagram.com").trim();

function clean(s?: string | null) {
  return (s ?? "").trim().replace(/^"+|"+$/g, "").replace(/^'+|'+$/g, "");
}

export function getToken(req?: NextRequest): string | null {
  const t = req?.nextUrl?.searchParams?.get("t");
  if (t && clean(t)) return clean(t);
  const envTok = clean(process.env.IG_ACCESS_TOKEN);
  return envTok || null;
}

export function getUserId(req?: NextRequest): string | null {
  const q = req?.nextUrl?.searchParams?.get("id");
  if (q && clean(q)) return clean(q);
  const envId = clean(process.env.IG_USER_ID);
  return envId || null;
}

export async function igMedia(token: string, userId: string, limit = 12) {
  const url = new URL("/me/media", IG_BASE);
  url.searchParams.set("fields", "id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username");
  url.searchParams.set("access_token", token);
  url.searchParams.set("limit", String(limit));

  const res = await fetch(url.toString(), { next: { revalidate: 60 } });
  const data = await res.json();
  if (!res.ok) {
    throw new Error(JSON.stringify({ status: res.status, body: data }));
  }
  return data;
}
'@
Write-TextFile "src/lib/ig.ts" $ig_ts

# ====== 3) src/app/api/instagram/route.ts ======
$route_ts = @'
import { NextResponse, NextRequest } from "next/server";
import { IG_BASE, getToken, getUserId, igMedia } from "@/lib/ig";

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  try {
    const token = getToken(req);
    const userId = getUserId(req);
    const url = new URL(req.nextUrl);
    const limit = Number(url.searchParams.get("limit") || "12");
    const raw = url.searchParams.get("raw") === "1";

    if (!token || !userId) {
      return NextResponse.json(
        {
          error: "Configuracao ausente",
          detail: {
            hasToken: Boolean(token),
            hasUserId: Boolean(userId),
            message: "Defina IG_ACCESS_TOKEN e IG_USER_ID (.env.local/Vercel) ou use ?t= e ?id= para teste."
          }
        },
        { status: 400 }
      );
    }

    let me: any = null;
    let meErr: any = null;
    try {
      const m = await fetch(`${IG_BASE}/me?fields=id,username&access_token=${encodeURIComponent(token)}`);
      if (m.ok) me = await m.json();
      else meErr = { status: m.status, body: await m.text() };
    } catch (e: any) {
      meErr = { error: e?.message || String(e) };
    }

    const data = await igMedia(token, userId, limit);

    if (raw) {
      return NextResponse.json(
        {
          hasToken: true,
          tokenLen: token.length,
          tokenPreview: token.slice(0,6)+"..."+token.slice(-6),
          igUserId: userId,
          base: IG_BASE,
          me,
          meErr,
          data
        },
        { status: 200 }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (err: any) {
    return NextResponse.json(
      { error: "Falha ao buscar feed", detail: err?.message || String(err) },
      { status: 500 }
    );
  }
}
'@
Write-TextFile "src/app/api/instagram/route.ts" $route_ts

# ====== 4) src/components/InstagramFeed.tsx ======
$feed_tsx = @'
"use client";
import { useEffect, useState } from "react";
import Image from "next/image";

type Item = {
  id: string;
  caption?: string;
  media_type: string;
  media_url: string;
  permalink: string;
  thumbnail_url?: string;
  timestamp?: string;
  username?: string;
};

export default function InstagramFeed({ limit = 9 }: { limit?: number }) {
  const [items, setItems] = useState<Item[]>([]);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const url = `/api/instagram?limit=${limit}&raw=1`;
    fetch(url)
      .then(async (r) => {
        const j = await r.json();
        if (!r.ok) throw new Error(JSON.stringify(j));
        const arr = j?.data?.data ?? [];
        setItems(arr);
        setLoading(false);
      })
      .catch((e) => {
        setErr(e.message);
        setLoading(false);
      });
  }, [limit]);

  if (loading) return <p>Carregando…</p>;
  if (err) return <pre className="whitespace-pre-wrap break-all text-red-600">{err}</pre>;

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
      {items.map((it) => {
        const isVideo = it.media_type === "VIDEO";
        const src = it.media_type === "IMAGE" ? it.media_url : (it.thumbnail_url || it.media_url);
        return (
          <a key={it.id} href={it.permalink} target="_blank" rel="noopener noreferrer" className="block">
            {src.includes("scontent") ? (
              <Image
                src={src}
                alt={it.caption || "Post do Instagram"}
                width={600}
                height={600}
                className="w-full h-auto object-cover rounded-lg"
                unoptimized
              />
            ) : (
              <img
                src={src}
                alt={it.caption || "Post do Instagram"}
                className="w-full h-auto object-cover rounded-lg"
                loading="lazy"
              />
            )}
            {isVideo && (
              <span className="mt-1 block text-xs text-zinc-500">Video - abre no Instagram</span>
            )}
          </a>
        );
      })}
    </div>
  );
}
'@
Write-TextFile "src/components/InstagramFeed.tsx" $feed_tsx

# ====== 5) src/app/instagram/page.tsx ======
$page_tsx = @'
import InstagramFeed from "@/components/InstagramFeed";

export const metadata = {
  title: "Instagram - VR Abandonada",
  description: "Ultimas publicacoes do Instagram da VR Abandonada, com pre-visualizacao no proprio site."
};

export default function Page() {
  return (
    <main className="p-6">
      <h1 className="text-xl font-bold mb-4">Instagram (preview)</h1>
      <p className="text-sm text-zinc-500 mb-4">
        Esta pagina e apenas para testar o componente. Em producao, use o componente onde quiser.
      </p>
      <InstagramFeed limit={9} />
    </main>
  );
}
'@
Write-TextFile "src/app/instagram/page.tsx" $page_tsx

# ====== 6) tsconfig.json ======
$tsconfig = @'
{
  "compilerOptions": {
    "target": "esnext",
    "module": "esnext",
    "jsx": "preserve",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
'@
Write-TextFile "tsconfig.json" $tsconfig

# ====== 7) next.config.js ======
$nextcfg = @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "scontent.cdninstagram.com", pathname: "/**" },
      { protocol: "https", hostname: "scontent-*.cdninstagram.com", pathname: "/**" },
      { protocol: "https", hostname: "scontent-iad3-1.cdninstagram.com", pathname: "/**" },
      { protocol: "https", hostname: "scontent-iad3-2.cdninstagram.com", pathname: "/**" }
    ],
  },
};
module.exports = nextConfig;
'@
Write-TextFile "next.config.js" $nextcfg

# ====== 8) limpar cache .next ======
$nextCache = Join-Path $root ".next"
if (Test-Path $nextCache) {
  try { Remove-Item $nextCache -Recurse -Force }
  catch { Write-Host "Aviso: nao consegui apagar .next (ok continuar): $($_.Exception.Message)" }
}

Write-Host ""
Write-Host "Tudo pronto."
Write-Host "1) npm run dev"
Write-Host "2) Testar pagina: http://localhost:3000/instagram"
Write-Host "3) Testar API:   http://localhost:3000/api/instagram?limit=3&raw=1"
Write-Host ""
