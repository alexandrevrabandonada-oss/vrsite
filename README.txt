Client Detail Fallback (v1)
Resolve o erro do servidor movendo a página de detalhe para um componente **client** em `/instagram/[id]`.
O fetch passa a ser feito no navegador (origem relativa), eliminando a exceção SSR.

O que muda:
- `src/app/instagram/[id]/page.tsx` (client) — busca `/api/ig?id=...` no client.
- `src/components/HomeFeed.tsx` — passa a linkar para `/instagram/{id}`.
- Mantém `/api/ig` como está.

Como aplicar:
1) Descompacte na RAIZ do projeto.
2) Rode um dos scripts:
   - Windows:  _APPLY-CLIENT-DETAIL-FALLBACK-WINDOWS.bat
   - macOS:    _APPLY-CLIENT-DETAIL-FALLBACK-MAC.command
   - Linux:    ./apply-client-detail-fallback.sh
