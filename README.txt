Diagnostics Pack v1
Adiciona endpoints e página de diagnóstico para entender o erro do detalhe do post.

Adições:
- `src/app/api/diag/route.ts` -> ecoa headers/proto/host/vercel_url.
- `src/app/api/ig/route.ts` -> mantém a versão robusta e acrescenta `&_dump=1` para ver itens crus.
- `src/app/diag/page.tsx` -> painel que testa /api/ig, /api/ig?id=seed-1, /api/ig?id=seed-1&debug=1, /api/diag.
- `src/app/instagram/[id]/page.tsx` (client) -> modo debug quando `?debug=1`.

Scripts 1‑clique (Windows/Mac/Linux) com backup + commit + push; dispara deploy hook se presente.
