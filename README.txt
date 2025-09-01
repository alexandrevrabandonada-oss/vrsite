Post Page MVP (v1)
Faz os cards do feed abrirem em uma página interna (`/posts/[id]`) ao invés de ir para o Instagram.

O que adiciona/atualiza:
- `src/app/posts/[id]/page.tsx` — página do post com imagem grande, legenda, data e link "Ver no Instagram".
- `src/app/api/ig/route.ts` — agora aceita `?id=...` para retornar 1 post.
- `src/components/HomeFeed.tsx` — passa a linkar para `/posts/{id}`.
- Scripts 1‑clique (Windows/Mac/Linux) com backup + commit + push e Deploy Hook opcional.

Como usar:
1) Descompacte este ZIP na RAIZ do projeto (onde tem `.git`).
2) Execute:
   - Windows:  _APPLY-POST-PAGE-WINDOWS.bat
   - macOS:    _APPLY-POST-PAGE-MAC.command
   - Linux:    ./apply-post-page.sh
Depois do deploy, a Home abrirá o detalhe no seu domínio.
