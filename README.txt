Deploy-Now (v1)
One‑click para: git add . → commit (com data/hora) → push origin main → opcionalmente disparar Deploy Hook do Vercel.

Como usar:
1) Coloque o zip na RAIZ do projeto (onde existe .git) e descompacte.
2) Execute:
   - Windows:  _DEPLOY-NOW-WINDOWS.bat
   - macOS:    _DEPLOY-NOW-MAC.command
   - Linux:    ./deploy-now.sh

Deploy Hook (opcional):
- Crie um Deploy Hook no Vercel e salve a URL no arquivo .env.vercel como:
  VERCEL_DEPLOY_HOOK_URL=https://api.vercel.com/v1/integrations/deploy/XXXXX
- Os scripts já vão ler essa variável e chamar o hook após o push.
