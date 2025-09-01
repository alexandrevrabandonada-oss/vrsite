# Pacote Instagram API (VR Abandonada)

Este pacote inclui:
- `src/app/api/instagram/route.ts`: endpoint `/api/instagram` com tratamento de erro, override por query `?t=` e `?id=`, suporte a `?limit=` e `?raw=1`.
- `src/app/api/instagram/debug/route.ts`: endpoint `/api/instagram/debug` para inspeção do token e do `GET /me`.
- `src/lib/ig.ts`: helpers centralizados (base URL, validação e chamadas).
- `scripts/refresh-ig-token.ps1` e `scripts/refresh-ig-token.cmd`: refresh do *long-lived token*.

## Como instalar

1) **Descompacte** este ZIP na raiz do seu projeto (vai criar/mesclar `src/` e `scripts/`).  
2) Confirme que suas variáveis estão corretas:
   - `IG_ACCESS_TOKEN` (long-lived, sem aspas, uma única linha)
   - `IG_USER_ID` (ex: 17841446140635566)
   - `INSTAGRAM_GRAPH_BASE` (opcional, padrão `https://graph.instagram.com`)

   Exemplos em `.env.local`:
   ```env
   IG_ACCESS_TOKEN=COLOQUE_SEU_TOKEN_AQUI
   IG_USER_ID=17841446140635566
   INSTAGRAM_GRAPH_BASE=https://graph.instagram.com
   ```

3) Rode o projeto:
   ```bash
   npm run dev
   ```

4) **Teste**:
   - `http://localhost:3000/api/instagram/debug`
   - `http://localhost:3000/api/instagram?limit=6`
   - `http://localhost:3000/api/instagram?limit=3&raw=1`
   - Override (útil para diagnosticar): `http://localhost:3000/api/instagram?limit=3&t=SEU_TOKEN&id=IG_USER_ID`

## Refresh automático do token (manual simples)

Quando o token longo estiver perto de expirar (90 dias), rode:
```cmd
scripts\refresh-ig-token.cmd
```
Ele vai:
- pedir o **token longo atual**;
- chamar o endpoint oficial `refresh_access_token`;
- atualizar o `.env.local` com o novo token.

> Observação: Este script **não** troca token curto por longo; ele **apenas** renova o *long-lived* existente.

## Notas importantes

- Se `debug` mostrar `meErr` com `code 190`, o token é inválido/expirado. Gere outro longo e teste com override:
  `http://localhost:3000/api/instagram?raw=1&t=NOVO_TOKEN&id=17841446140635566`
- Em produção (Vercel), defina as mesmas envs em **Project Settings → Environment Variables**.
- Para evitar erros de imagem do Next.js, garanta que seu `next.config.js` inclua domínios do Instagram CDN.
