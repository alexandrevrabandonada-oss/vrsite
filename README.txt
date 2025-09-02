Instagram Detail Safe Mode (v4)
-------------------------------
Substitui temporariamente a página /instagram/[id] por uma versão "à prova de crash":
- Tudo fica dentro de try/catch.
- Em `?debug=1` mostra `error.message` e `error.stack` (stringificados) além do `item` recebido.
- Renderização super simples (sem Tailwind obrigatório, sem toLocaleString, sem image handlers).

Como aplicar:
1) Descompacte este ZIP na **raiz do repo**.
2) Rode um dos aplicadores:
   - Windows:  _APPLY-INSTAGRAM-SAFE-WINDOWS.bat
   - macOS:    _APPLY-INSTAGRAM-SAFE-MAC.command
   - Linux:    ./apply-instagram-safe.sh
3) Depois do deploy, teste: /instagram/seed-1?debug=1
   - Cole aqui o bloco `error` (se aparecer) e o `item`.
