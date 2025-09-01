Alias Fix (HomeFeed) v1
Corrige imports que ficaram como '@/src/...'. No seu projeto o alias '@' já aponta para 'src/',
então o correto é '@/...'.

O que o script faz:
- Procura em **src/app/page.tsx**, **src/app/api/ig/route.ts** e **src/components/HomeFeed.tsx**
  e troca '@/src/' -> '@/'. (Se algum dos arquivos não existir, ele ignora.)
- Faz commit + push e, se houver `VERCEL_DEPLOY_HOOK_URL` em `.env.vercel`, dispara redeploy.

Como usar:
1) Coloque o ZIP na RAIZ do projeto e descompacte.
2) Rode:
   - Windows:  _APPLY-ALIAS-FIX-HOMEFEED-WINDOWS.bat
   - macOS:    _APPLY-ALIAS-FIX-HOMEFEED-MAC.command
   - Linux:    ./apply-alias-fix-homefeed.sh
