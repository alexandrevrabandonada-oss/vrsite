Text Library Replace (v1)
Substitui diretamente `src/lib/text.ts` por uma versão compatível (sem flag `u`).

O que faz:
- Copia `payload/src/lib/text.ts` -> `src/lib/text.ts` (com backup).
- Commit + push e (se houver) dispara Deploy Hook do Vercel.

Como usar:
1) Descompacte este ZIP na **raiz do projeto** (onde tem `.git`).
2) Execute:
   - Windows:  _APPLY-TEXT-LIB-REPLACE-WINDOWS.bat
   - macOS:    _APPLY-TEXT-LIB-REPLACE-MAC.command
   - Linux:    ./apply-text-lib-replace.sh
