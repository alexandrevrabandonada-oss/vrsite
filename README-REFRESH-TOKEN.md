# VR Abandonada — Pipeline automático para renovar IG_ACCESS_TOKEN

Este pacote configura uma **automação 100% sem intervenção manual** para:
1. Renovar o *token de longa duração* do Instagram Graph.
2. Validar o token (checando `/me`).
3. Atualizar a **Environment Variable** `IG_ACCESS_TOKEN` no Vercel (todas as targets).
4. (Opcional) Disparar um **Deploy Hook** no Vercel para publicar a alteração imediatamente.

Funciona via **GitHub Actions** (agendado e manual).

---

## 🔐 Segredos que você precisa configurar no GitHub (Repository → Settings → Secrets and variables → Actions → *New repository secret*)

Crie estes **Secrets** (exactamente com estes nomes):

- `FB_APP_ID` → *App ID* do app Facebook/Instagram que você já tem.
- `FB_APP_SECRET` → *App Secret* do app.
- `IG_ACCESS_TOKEN` → **Token longo atual** (servirá como ponto de partida para o refresh).
- `VERCEL_TOKEN` → Token de acesso da API do Vercel (User Settings → Tokens).
- `VERCEL_ORG_ID` → ID da sua organização no Vercel.
- `VERCEL_PROJECT_ID` → ID do projeto Vercel (vrsite).
- `VERCEL_DEPLOY_HOOK_URL` *(opcional, recomendado)* → Deploy Hook do Vercel para o projeto/produção.

> **Dica:** para descobrir `VERCEL_ORG_ID` e `VERCEL_PROJECT_ID`, rode localmente `vercel link` e depois `vercel projects ls --json` (ou pegue no dashboard do Vercel → Project Settings → General).

---

## 🧩 O que é instalado

- `.github/workflows/refresh-ig-token.yml`
  - Agenda diária (04:00 UTC) + disparo manual.
  - Roda o script Node que faz refresh/validação/atualização no Vercel.
- `scripts/refresh-ig-token-ci.mjs`
  - Faz o refresh via `oauth/access_token` (fb_exchange_token) usando seu *long-lived token atual*.
  - Valida o novo token no `graph.instagram.com/me`.
  - Atualiza **IG_ACCESS_TOKEN** em todas as *targets* (Production/Preview/Development) via API do Vercel.
  - Se `VERCEL_DEPLOY_HOOK_URL` estiver definido, dispara um deploy imediato.

---

## 🚀 Como instalar

1. Extraia este ZIP na **raiz do seu repositório** (onde já existem as pastas `.github/` e `src/`).
2. *Commit* e *push*:
   ```bash
   git add .github/workflows/ scripts/
   git commit -m "chore(ci): refresh automático do IG_ACCESS_TOKEN"
   git push
   ```
3. No GitHub, crie os **Secrets** listados acima.
4. Para testar agora, vá em **Actions → Refresh Instagram Long-Lived Token → Run workflow**.
5. Depois rode localmente:
   ```bash
   vercel env pull .env.local
   npm run dev
   ```

---

## ♻️ Renovação contínua

O workflow roda **diariamente**. Tokens de longa duração têm validade de ~60 dias, mas o “refresh” prolonga a validade. Você não precisa mais colar token manualmente.

---

## 🧯 Diagnóstico rápido

- **Falhou no refresh** → cheque `FB_APP_ID`, `FB_APP_SECRET` e o valor atual de `IG_ACCESS_TOKEN` (se expirar por completo, gere um token curto no Graph Explorer e substitua o Secret `IG_ACCESS_TOKEN` com o longo novo manualmente uma única vez; depois o fluxo automático assume).
- **Atualizou no Vercel mas o site não refletiu** → confirme que `VERCEL_DEPLOY_HOOK_URL` está setado (senão o deploy ficará para a próxima alteração ou você pode recriar manualmente no dashboard).
- **Local 400 e produção ok** → rode `vercel env pull .env.local` para puxar o token novo para seu dev local.

---

## 📄 Licença
Uso livre neste projeto.