Instagram Post SSR Patch (v1)
Troca a página de detalhe para **Server Component** com origem segura via headers, usando:
- `x-forwarded-proto` + `x-forwarded-host` (Vercel) para montar a URL absoluta
- `dynamic = 'force-dynamic'` para evitar cache
- Tratamento de erros claro

Arquivos:
- payload/src/app/instagram/[id]/page.tsx  (novo)
- apply scripts (Win/Mac/Linux) que fazem backup, commit + push e chamam Deploy Hook se existir em `.env.vercel`

Como usar:
1) Descompacte este ZIP na **raiz** do repositório (onde fica a pasta `.git`).
2) Execute um dos scripts:
   - Windows:  _APPLY-INSTAGRAM-POST-SSR-PATCH-WINDOWS.bat
   - macOS:    _APPLY-INSTAGRAM-POST-SSR-PATCH-MAC.command
   - Linux:    ./apply-instagram-post-ssr-patch.sh
