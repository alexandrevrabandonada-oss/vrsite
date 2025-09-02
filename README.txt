Safe Links & Redirects (v1)
Objetivo: acabar com "Página não encontrada" ao clicar no card.
Ações:
1) Torna o HomeFeed mais explícito: mostra o ID e garante link robusto para /instagram/{id}?debug=1.
2) Cria /instagram (index) SSR listando itens vindos de /api/ig, com links corretos.
3) Adiciona rewrites via middleware.ts para rotas antigas:
   - /post/{id}     -> /instagram/{id}
   - /posts/{id}    -> /instagram/{id}
   - /materias/{id} -> /instagram/{id}

Scripts 1‑clique (Win/Mac/Linux) fazem backup, commit + push e chamam Deploy Hook se existir.
