API IG Robust Hotfix (v1)
Deixa o endpoint `/api/ig` mais resistente:
- Não importa mais JSON via `import ... assert { type: 'json' }`.
- Lê `src/data/ig-seed.json` do disco se existir; caso contrário usa um seed embutido.
- Normaliza `id` (string/trim) e aceita `?id=` para retornar 1 item.
- Adiciona `?debug=1` para ver porque um `id` não foi encontrado.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Execute:
   - Windows:  _APPLY-API-IG-ROBUST-WINDOWS.bat
   - macOS:    _APPLY-API-IG-ROBUST-MAC.command
   - Linux:    ./apply-api-ig-robust.sh
Depois acesse `/api/ig` e `/api/ig?id=seed-1`.
