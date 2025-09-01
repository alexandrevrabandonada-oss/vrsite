VR Abandonada – Scripts Instagram (Graph v20)
===================================================

Arquivos:
- scripts/configure-env.cmd  -> rode este (Windows) para configurar .env.local
- scripts/configure-env.ps1   idem (script principal)
- scripts/test-ig.cmd         -> teste rápido dos endpoints
- scripts/test-ig.ps1

O que fazem:
1) Validação segura do token em /me?fields=id,name
2) Validação do IG user em /{IG_USER_ID}?fields=id,username,media_count
3) Teste de /media (3 itens)
4) Geração de .env.local com:
   IG_ACCESS_TOKEN=...
   IG_USER_ID=...
   INSTAGRAM_GRAPH_BASE=https://graph.facebook.com/v20.0

Uso:
- Dê duplo-clique em scripts/configure-env.cmd e cole o token longo e o IG_USER_ID.
- Depois execute scripts/test-ig.cmd (opcional).
- Em seguida: npm run dev
- Teste: http://localhost:3000/api/instagram?limit=3&raw=1
