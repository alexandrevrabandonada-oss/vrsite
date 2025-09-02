Next Diagnostics Kit (v1)
-------------------------
Cria duas páginas de diagnóstico (SSR) que usam a *mesma* camada de dados do Instagram:

1) /diag/ids
   - Lista todos os IDs que a app enxerga via `listIgItems()`

2) /diag/item/[id]
   - Mostra o JSON retornado por `getIgItemById(id)` (sem passar pela /api)

Instalação:
1) Descompacte este ZIP na **raiz** do repo.
2) Execute:
   - Windows:  _APPLY-NEXT-DIAG-WINDOWS.bat
   - macOS:    _APPLY-NEXT-DIAG-MAC.command
   - Linux:    ./apply-next-diag.sh
3) Faça o deploy (os scripts já committam/pusham e disparam Deploy Hook se existir).
