Home Feed MVP (v1)
Traz de volta um feed na Home. Por enquanto usa um endpoint local `/api/ig`
que lê um `seed.json`. Depois, trocamos pelo Instagram Graph API real (Pacote Instagram).

O que adiciona:
- `src/components/HomeFeed.tsx` (client) — cards com imagens, legendas e tags
- `src/app/api/ig/route.ts` — API simples que retorna `src/data/ig-seed.json`
- `src/data/ig-seed.json` — 6 posts de exemplo
- Atualiza `src/app/page.tsx` para incluir o feed + link para /search
- Faz backup, commit + push e (se houver) dispara Deploy Hook do Vercel

Como usar:
1) Coloque este ZIP na RAIZ do projeto (onde tem `.git`) e descompacte.
2) Execute um dos scripts:
   - Windows:  _APPLY-HOME-FEED-WINDOWS.bat
   - macOS:    _APPLY-HOME-FEED-MAC.command
   - Linux:    ./apply-home-feed.sh

Depois do deploy, abra a Home — os cards aparecem. Quando formos integrar o IG real,
o componente já está pronto; só troca a API.
