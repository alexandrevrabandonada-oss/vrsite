PASSO A PASSO — PATCH VR ABANDONADA (Instagram + Base URL)

1) Extraia estes arquivos na raiz do projeto, preservando pastas:
   - src/lib/baseUrl.ts
   - src/app/instagram/page.tsx
   - .env.local

2) Confira o alias no tsconfig.json (não incluso no patch). Deve ter:
   {
     "compilerOptions": {
       "baseUrl": ".",
       "paths": { "@/*": ["src/*"] }
     }
   }
   Se você ajustar o tsconfig, pare e reinicie o servidor dev.

3) Rodar localmente:
   npm run dev
   Abra http://localhost:3000/instagram

4) Teste do endpoint (se der 400):
   - Verifique .env.local (sem aspas, sem espaços, 1 var por linha).
   - Teste override: http://localhost:3000/api/instagram?limit=3&raw=1&t=TOKEN_URL_ENCODED&id=17841446140635566
     IMPORTANTE: faça URL-encode do token antes de colar na URL.

5) Produção (Vercel):
   - Em “Project Settings > Environment Variables”, crie as mesmas variáveis:
     INSTAGRAM_GRAPH_BASE, IG_ACCESS_TOKEN, IG_USER_ID, NEXT_PUBLIC_SITE_URL (https://vrabandonada.com.br)
   - Faça um deploy.
