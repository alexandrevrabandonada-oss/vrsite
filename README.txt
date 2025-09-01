Search-MVP Hotfix (v3)
Compatibilidade com PowerShell antigo (sem usar -Raw).

O que faz:
- Corrige todos os imports "@/src/" -> "@/"" em src/**/*.ts e src/**/*.tsx usando .NET (sem -Raw).
- Garante resolveJsonModule=true no tsconfig.json (via .NET + conversão simples).
- Commit + push e (opcional) chama Deploy Hook do Vercel.

Uso:
1) Descompacte na RAIZ do projeto (.git).
2) Rode:
   - Windows:  _APPLY-SEARCH-HOTFIX3-WINDOWS.bat
   - macOS:    _APPLY-SEARCH-HOTFIX3-MAC.command
   - Linux:    ./apply-search-hotfix3.sh
