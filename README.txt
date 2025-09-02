Instagram Detail Debug View (v3)
--------------------------------
Melhora a página /instagram/[id] com:
- Painel de debug quando `?debug=1` mostrando o JSON completo do item.
- Fallback de imagem (se media_url quebrar).
- Mensagem clara quando `item` vier null.
- Garante que og-default.png exista em /public.

Instalação:
1) Descompacte o ZIP na **raiz** do repo.
2) Execute:
   - Windows:  _APPLY-INSTAGRAM-DEBUG-WINDOWS.bat
   - macOS:    _APPLY-INSTAGRAM-DEBUG-MAC.command
   - Linux:    ./apply-instagram-debug.sh
