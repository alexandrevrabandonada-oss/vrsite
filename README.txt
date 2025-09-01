SEO-Pack Cleanup (v2)
Corrige o build falhando por causa de arquivos dentro de `payload/`.

O que este pacote faz (1‑clique):
- Garante que `src/app/robots.ts` e `src/app/sitemap.ts` usem `@/lib/seo`.
- Adiciona `payload/` no `.gitignore`.
- Adiciona exclusões em `tsconfig.json`: `"payload/**"` (além de `**/backup-*/**` e `.backups/**`).
- Remove `payload/` do repositório (git rm --cached) e também do disco.
- Faz `commit + push` e (opcional) chama o Deploy Hook do Vercel.

Como usar:
1) Coloque o ZIP na RAIZ do projeto (onde tem `.git`) e descompacte.
2) Execute:
   - Windows:  _APPLY-CLEANUP2-WINDOWS.bat
   - macOS:    _APPLY-CLEANUP2-MAC.command
   - Linux:    ./apply-cleanup2.sh
