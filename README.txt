Hotfix SEO-Pack (v1)
Corrige imports incorretos '@/src/lib/seo' -> '@/lib/seo' em:
- src/app/robots.ts
- src/app/sitemap.ts

Como usar:
1) Coloque o zip na RAIZ do projeto (onde tem .git) e descompacte.
2) Execute:
   - Windows:  _APPLY-HOTFIX-WINDOWS.bat
   - macOS:    _APPLY-HOTFIX-MAC.command
   - Linux:    ./apply-hotfix.sh
O script faz backup, aplica a troca, commit + push e (opcional) deploy hook.
