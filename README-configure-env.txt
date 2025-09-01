Como usar (Windows)
====================
1) Copie a pasta "scripts" para a RAIZ do seu projeto (onde tem package.json).
2) Clique duas vezes em scripts\configure-env.cmd
   - Cole o IG_ACCESS_TOKEN (longo) SEM aspas
   - Cole o IG_USER_ID (ex.: 1784...)
   O script grava .env.local e valida nas rotas /me, /{IG_USER_ID} e /{IG_USER_ID}/media
3) Rode npm run dev
   - API:   http://localhost:3000/api/instagram?limit=3&raw=1
   - Página: http://localhost:3000/instagram
4) Qualquer dúvida, rode scripts\test-ig.cmd para repetir os testes.

Observações
-----------
- O console **não fecha** sozinho: tem PAUSE no final para você ver o resultado.
- O script usa a base v20: https://graph.facebook.com/v20.0
- Campos solicitados: /me -> id,name   | IG User -> id,username,media_count
- Se der erro code 190 (token), gere um novo long-lived e rode de novo o configure-env.cmd.
