App Files Hotfix (v1)
Corrige erros de sintaxe/encoding em `src/app/layout.tsx` e `src/app/page.tsx`.

O que este pacote faz:
- Substitui `src/app/layout.tsx` por uma versão limpa (Next.js 14, com `metadata` e `RootLayout`).
- Substitui `src/app/page.tsx` por uma home mínima e válida, com acentuação correta (UTF-8).
- Faz backup dos arquivos antigos, commit + push e (se houver) dispara Deploy Hook do Vercel.

Como usar:
1) Coloque o ZIP na RAIZ do projeto (onde tem `.git`) e descompacte.
2) Execute:
   - Windows:  _APPLY-FIX-APP-FILES-WINDOWS.bat
   - macOS:    _APPLY-FIX-APP-FILES-MAC.command
   - Linux:    ./apply-fix-app-files.sh
