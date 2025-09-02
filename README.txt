Diag SS Fix Import (v3)
-----------------------
Corrige o erro de import e evita o problema "Copy-Item ... por ele mesmo" escrevendo o arquivo via here-string.

Instruções:
1) Extraia na **raiz do repositório**.
2) Windows: execute `_APPLY-DIAG-FIX.bat`
   macOS/Linux: `bash apply-diag-fix.sh`
3) Aguarde o deploy. Teste: /api/diag/ss?id=seed-1
