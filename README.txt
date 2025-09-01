UI Search Hotfix — v2 (sem regex com aspas)
Corrige o erro de parsing no PowerShell e injeta a barra de busca na home com verificações simples.

O que muda nesta versão:
- Evita regex com aspas/escapes: usa `.Contains(...)` e `IndexOf(...)`.
- Não usa a variável reservada `$HOME` (usa `$homeFile`).
- Insere `<HomeSearchBar />` antes do primeiro `<main>`; se não existir, após `return (`.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Execute:
   - Windows:  _APPLY-UI-SEARCH-HOTFIX2-WINDOWS.bat
   - macOS:    _APPLY-UI-SEARCH-HOTFIX2-MAC.command
   - Linux:    ./apply-ui-search-hotfix2.sh
