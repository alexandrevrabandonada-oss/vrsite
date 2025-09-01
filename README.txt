Search Suspense Hotfix (v1)
Corrige o erro: "useSearchParams() should be wrapped in a suspense boundary" na página /search.
Solução aplicada:
- Adiciona boundary <Suspense> no nível da página.
- Isola a lógica em <SearchClient/> (client component).
- Define `export const dynamic = "force-dynamic"` para evitar prerender.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Rode:
   - Windows:  _APPLY-SEARCH-SUSPENSE-WINDOWS.bat
   - macOS:    _APPLY-SEARCH-SUSPENSE-MAC.command
   - Linux:    ./apply-search-suspense.sh
