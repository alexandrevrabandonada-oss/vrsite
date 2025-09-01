SEO-Pack Cleanup (v1)
Resolve o erro do build por causa de pastas "backup-*" dentro do repositório.

O que este pacote faz (1‑clique):
- Remove quaisquer pastas "backup-*" já criadas e versionadas.
- Corrige (de novo, por garantia) imports em src/app/robots.ts e src/app/sitemap.ts para "@/lib/seo".
- Atualiza .gitignore para ignorar "backup-*/" e ".backups/".
- Atualiza tsconfig.json para excluir "**/backup-*/**" e ".backups/**".
- Faz commit + push e opcionalmente aciona o Deploy Hook do Vercel.

Como usar:
1) Coloque o ZIP na raíz do projeto (onde tem .git) e descompacte.
2) Execute:
   - Windows: _APPLY-CLEANUP-WINDOWS.bat
   - macOS:   _APPLY-CLEANUP-MAC.command
   - Linux:   ./apply-cleanup.sh
