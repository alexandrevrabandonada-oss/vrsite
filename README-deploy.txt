VR Abandonada — Ferramentas de Deploy
=========================================

Arquivos neste pacote (2025-09-01 15:28:46):
- scripts\deploy.cmd .................... Deploy simples via Git (add/commit/push)
- scripts\deploy.ps1 .................... Versão PowerShell do deploy simples
- scripts\deploy-clean.cmd .............. Deploy LIMPO via Vercel CLI (força rebuild, sem cache)
- scripts\deploy-clean.ps1 .............. Versão PowerShell do deploy LIMPO
- scripts\deploy-git-clean.cmd .......... Envia um commit de 'cache-bust' para forçar rebuild no Git

Quando usar cada um?
--------------------
1) Quero só publicar o que já está ok no repo:
   -> use scripts\deploy.cmd

2) O Vercel está reutilizando cache e quero rebuild limpo:
   -> use scripts\deploy-clean.cmd  (requer: vercel login / vercel link)

3) O projeto está integrado via Git e só quero garantir novo deploy
   com uma pequena mudança para bustar cache:
   -> use scripts\deploy-git-clean.cmd

Pré-requisitos
--------------
- Git instalado e o repositório já configurado com 'origin'
- Para os scripts 'clean' (CLI): Vercel CLI instalado e autenticado
    npm i -g vercel
    vercel login
    vercel link   (apenas uma vez, na raiz do projeto)

Dúvidas? Rode qualquer .cmd com janela de administrador para evitar bloqueios.
