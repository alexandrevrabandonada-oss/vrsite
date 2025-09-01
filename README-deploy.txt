# Deploy VR Abandonada

Este pacote serve para facilitar o deploy do site no Vercel.

Passos:

1. Tenha o Git configurado e logado no seu projeto (já está, pois o Vercel usa o repositório).
2. Coloque os arquivos `deploy.cmd` e `deploy.ps1` na raiz do projeto.
3. Faça as alterações no código normalmente.
4. Quando quiser enviar para produção:
   - Clique duas vezes em `deploy.cmd` (CMD tradicional)
   - ou clique com botão direito em `deploy.ps1` → Executar com PowerShell

O script vai:
- Adicionar todas as mudanças (`git add .`)
- Criar um commit com mensagem "Deploy automático VR Abandonada"
- Enviar para o repositório (`git push`)
- O Vercel vai detectar e iniciar o deploy automático.
