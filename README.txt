Post Page Metadata-Safe Hotfix (v1)
Elimina o uso de `headers()`/`fetch` dentro de `generateMetadata`, que pode causar exceções no servidor
em algumas execuções. O fetch do post fica somente no componente da página.

Como usar:
1) Descompacte na RAIZ do projeto.
2) Execute:
   - Windows:  _APPLY-POST-PAGE-METADATA-SAFE-WINDOWS.bat
   - macOS:    _APPLY-POST-PAGE-METADATA-SAFE-MAC.command
   - Linux:    ./apply-post-page-metadata-safe.sh
