SEO-Pack (v3)
Correções:
- Os arquivos do pack ficam em `payload/` e são copiados para a RAIZ do projeto.
- PowerShell e Bash: evitam copiar quando src == dst (resolve path) e fazem backup com caminhos relativos.

Como usar:
1) Coloque este ZIP na RAIZ do seu projeto (onde existe .git) e descompacte.
2) Execute:
   - Windows:  _APPLY-SEO-WINDOWS.bat
   - macOS:    _APPLY-SEO-MAC.command
   - Linux:    ./apply-seo-pack.sh
3) Isso vai copiar os arquivos de `payload/` para as mesmas rotas na raiz do projeto.
