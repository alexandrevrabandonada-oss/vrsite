IG Unified Data Layer (v1)
---------------------------------
Objetivo: parar de chamar a própria API a partir do Server Component.
Em vez disso, mover a lógica para `src/lib/ig-data.ts` e reutilizar tanto
na rota `/api/ig` quanto na página `/instagram/[id]`.

Conteúdo:
- payload/src/lib/ig-data.ts
- payload/src/app/api/ig/route.ts   (reimplementado para usar a lib)
- payload/src/app/instagram/[id]/page.tsx  (usa a lib direta, com debug robusto)
- aplicadores 1‑clique (Win/Mac/Linux)

Como usar:
1) Descompacte o ZIP na **raiz do repo**.
2) Rode um dos scripts de aplicação.
3) Faça o deploy.
