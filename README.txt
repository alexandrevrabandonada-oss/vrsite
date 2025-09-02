InstagramID Alias Route (v1)
----------------------------
Cria uma rota alternativa **/instagramid/[id]** com o mesmo código "safe" e painel de debug.
Útil quando a rota original /instagram/[id] está quebrando por cache/caminho.

Como usar:
1) Descompacte na **raiz** do repo.
2) Rode um dos aplicadores:
   - Windows:  _APPLY-INSTAGRAMID-ALIAS-WINDOWS.bat
   - macOS:    _APPLY-INSTAGRAMID-ALIAS-MAC.command
   - Linux:    ./apply-instagramid-alias.sh
3) Depois do deploy, acesse: /instagramid/seed-1?debug=1
