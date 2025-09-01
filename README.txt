Search-MVP (v1)
Adiciona a página /search com busca simples (client + API) em um índice local.
- Rota: /search
- API:  GET /api/search?q=termo
- Fonte: src/data/seed.json (você pode substituir por seu conteúdo depois)

Como usar (1‑clique):
1) Coloque este ZIP na RAIZ do projeto (onde há .git) e descompacte.
2) Execute:
   - Windows:  _APPLY-SEARCH-WINDOWS.bat
   - macOS:    _APPLY-SEARCH-MAC.command
   - Linux:    ./apply-search-pack.sh

O que é copiado para seu projeto:
- src/app/search/page.tsx
- src/app/api/search/route.ts
- src/lib/text.ts (slug e extração de tags)
- src/lib/search.ts (engine simples)
- src/data/seed.json (exemplos — pode editar/remover)

Depois do deploy:
- Acesse /search
- Teste termos como: reforma, saude, educacao
