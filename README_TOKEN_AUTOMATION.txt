VR ABANDONADA — Automação de Token Instagram

Arquivos:
- scripts/refresh-ig-token.cmd  -> Inicia o PowerShell com execução liberada
- scripts/refresh-ig-token.ps1  -> TROCA token curto -> LONGO, valida em /me, e atualiza .env.local
- scripts/configure-env.cmd      -> Abre o .env.local no Notepad (opcional)
- .env.example                   -> Modelo de referência

Como usar:
1) Dê duplo clique em scripts\refresh-ig-token.cmd
   - Cole APP ID e APP SECRET (guarda em cache em scripts/.ig_app.json)
   - Cole o TOKEN CURTO (Graph Explorer)
   - O script obtém o token LONGO, valida, e atualiza .env.local

2) Rode local:
   npm run dev

3) Testes:
   - http://localhost:3000/api/instagram/debug  -> deve mostrar has_token: true
   - http://localhost:3000/instagram            -> deve renderizar os posts
   - http://localhost:3000/api/instagram?limit=3&raw=1 -> JSON cru
