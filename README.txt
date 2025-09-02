Bracket Paths Fixer (v1)
------------------------
Em Windows/PowerShell, colchetes `[` `]` são curingas, e copiar arquivos para pastas como `[id]` falha silenciosamente.
Este patch:
1) Regrava — com APIs .NET (LiteralPath) — os arquivos de rotas dinâmicas:
   - src/app/instagram/[id]/page.tsx
   - src/app/diag/item/[id]/page.tsx
2) Também cria um alias redundante sem colchetes:
   - src/app/diag/itemid/[id]/page.tsx  (e links em /diag/ids apontam para este alias)
Assim você consegue testar mesmo que um dos caminhos esteja com problema.

Como usar:
1) Descompacte na **raiz do repo**.
2) Rode:
   - Windows:  _APPLY-BRACKETS-FIX-WINDOWS.bat
   - macOS:    _APPLY-BRACKETS-FIX-MAC.command
   - Linux:    ./apply-brackets-fix.sh
Os scripts fazem backup, escrevem os arquivos via *System.IO* (Windows) e fazem commit/push + opcional Deploy Hook.
