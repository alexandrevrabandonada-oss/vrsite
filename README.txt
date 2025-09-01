Text Regex Hotfix (v1)
Corrige regex Unicode Property (\p{Diacritic}) para compatibilidade com targets < ES2018.
Substitui por faixa de combinantes: /[\u0300-\u036f]/g

O que faz:
- Procura em src/**/*.ts e src/**/*.tsx por "\p{Diacritic}" e troca para "[\u0300-\u036f]".
- Faz backup, commit + push e (opcional) aciona Deploy Hook.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Execute:
   - Windows:  _APPLY-TEXT-REGEX-HOTFIX-WINDOWS.bat
   - macOS:    _APPLY-TEXT-REGEX-HOTFIX-MAC.command
   - Linux:    ./apply-text-regex-hotfix.sh
