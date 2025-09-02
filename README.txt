Instagram Detail Robust Fetch (v2)
Faz a página /instagram/[id] buscar o post de forma resiliente:
1) Tenta **fetch('/api/ig?id=...')** relativo (recomendado pelo Next).
2) Se falhar, resolve **origin** via headers e tenta **fetch('${origin}/api/ig?id=...')**.
3) Se ainda falhar e **debug=1**, mostra status, corpo do erro e a lista de ids que a API enxerga.

Como usar:
1) Descompacte na RAIZ do repo.
2) Rode o script do seu sistema para aplicar, commitar, pushar e (se houver Deploy Hook) redeploy.
