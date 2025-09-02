Hotfix: Ajusta imports de '@/src/*' para '@/*'
Motivo: seu tsconfig já usa baseUrl/path '@/*' apontando para 'src', então '@/src/...' quebra em build.

O script corrige:
- src/app/api/ig/route.ts  ('@/src/lib/ig-data' -> '@/lib/ig-data')
- src/app/instagram/[id]/page.tsx  ('@/src/lib/ig-data' -> '@/lib/ig-data')
- src/lib/ig-data.ts  ('@/src/data/ig-seed.json' -> '@/data/ig-seed.json')

Como usar:
1) Descompacte na raiz do repositório.
2) Rode um dos aplicadores:
   - Windows:  _APPLY-FIX-IMPORTS-WINDOWS.bat
   - macOS:    _APPLY-FIX-IMPORTS-MAC.command
   - Linux:    ./apply-fix-imports.sh
Os scripts fazem backup, commit, push e (se existir) chamam o Deploy Hook no Vercel.
