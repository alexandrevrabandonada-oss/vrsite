# VR Abandonada — Pacote de Correção (Instagram + ENV)

Este pacote inclui:
- `src/app/api/instagram/route.ts` (rota robusta com overrides e erros claros)
- `src/lib/baseUrl.ts` (função utilitária)
- `scripts/refresh-ig-token.ps1` (PowerShell para trocar e validar token no **endpoint correto do Instagram**)
- `scripts/configure-env.cmd` (Batch para salvar variáveis e validar localmente)
- `.env.local.example` (modelo)

## Como usar (rápido)

1. **Troque seu token curto por LONGO (Instagram Basic Display):**
   - Abra `PowerShell` na pasta do projeto
   - Rode: `.\scripts\refresh-ig-token.ps1`
   - Informe `APP_SECRET` e **o token curto** quando solicitado
   - O script valida em `/me` e salva em `.env.local` (IG_ACCESS_TOKEN).

2. **Preencha `.env.local` (ou edite a sua):**
   - Copie o conteúdo de `.env.local.example`
   - Ajuste `IG_USER_ID`, `IG_ACCESS_TOKEN`, `NEXT_PUBLIC_SITE_URL` (opcional), `INSTAGRAM_GRAPH_BASE` (opcional)
   - **Sem aspas, sem espaços extras e em linha única.**

3. **Rodar local:**
   ```bash
   npm run dev
   # Teste:
   http://localhost:3000/api/instagram?limit=3&raw=1
   ```

4. **Vercel (produção):**
   - Em *Project → Settings → Environment Variables* defina os mesmos pares:
     - IG_ACCESS_TOKEN, IG_USER_ID, NEXT_PUBLIC_SITE_URL, INSTAGRAM_GRAPH_BASE
   - Salve e **Redeploy**.

## Dicas
- Se `debug` mostra JSON e `/api/instagram` dá 400, quase sempre é **token inválido/antigo** em memória. Atualize `.env.local` e reinicie o dev server.
- Para renovar o token longo mais tarde:
  ```bash
  curl -G "https://graph.instagram.com/refresh_access_token"     -d "grant_type=ig_refresh_token"     -d "access_token=SEU_TOKEN_LONGO"
  ```