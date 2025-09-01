Text Regex Flag Hotfix (v2)
Corrige o erro: "This regular expression flag is only available when targeting 'es6' or later."
Tira o flag **u** de expressões `/[\u0300-\u036f]/gu` -> `/[\u0300-\u036f]/g`.

O que faz:
- Varre `src/**/*.ts*` e troca `([\u0300-\u036f])/gu` por `\1/g`.
- Faz backup, commit + push e (opcional) aciona Deploy Hook.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Rode:
   - Windows:  _APPLY-TEXT-REGEX-FLAG-HOTFIX-WINDOWS.bat
   - macOS:    _APPLY-TEXT-REGEX-FLAG-HOTFIX-MAC.command
   - Linux:    ./apply-text-regex-flag-hotfix.sh
