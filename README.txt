Instagram Client Detail (v1)
----------------------------
Substitui a página /instagram/[id] por uma versão **Client Component**.
Ela busca o item via `/api/ig?id=...` no navegador (fetch) e renderiza sem risco de crash de Server Component.
Inclui modo debug (?debug=1).

Como aplicar:
1) Extraia este ZIP na **raiz do repositório**.
2) Windows: rode `_APPLY-INSTAGRAM-CLIENT-WINDOWS.bat`
   macOS/Linux: `bash apply-instagram-client.sh`
3) Após o deploy, teste:
   - /instagram/seed-1?debug=1
   - /instagram/seed-2?debug=1
