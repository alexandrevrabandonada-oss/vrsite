Post Page Origin Hotfix (v1)
Corrige o erro no servidor ao abrir `/posts/[id]`.
Causa: o fetch da página do post usava URL relativa/variável de ambiente ausente.
Solução: monta a origem a partir dos headers (`x-forwarded-proto` + `x-forwarded-host`)
e faz `fetch(`${origin}/api/ig?id=...`)`. Também força `dynamic` para evitar cache.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Execute:
   - Windows:  _APPLY-POST-PAGE-ORIGIN-WINDOWS.bat
   - macOS:    _APPLY-POST-PAGE-ORIGIN-MAC.command
   - Linux:    ./apply-post-page-origin.sh
