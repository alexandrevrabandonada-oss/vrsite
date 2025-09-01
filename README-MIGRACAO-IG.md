# VR Abandonada — Instagram Graph (Facebook Graph)

**O que mudou**: O Instagram **Basic Display API** foi descontinuado. Agora usamos **Instagram Graph API** (domínio `graph.facebook.com`) que requer **conta Profissional (Business/Creator)** conectada a uma **Página do Facebook** e **token de Facebook Login** com escopos `instagram_basic` e `pages_show_list` (pelo menos).

## Variáveis (.env.local)

```
IG_USER_ID=17841446140635566
IG_ACCESS_TOKEN=SEU_TOKEN_LONGO_FACEBOOK_GRAPH
INSTAGRAM_GRAPH_BASE=https://graph.facebook.com
INSTAGRAM_GRAPH_VERSION=v21.0
```

> Em **desenvolvimento**, você pode passar `?t=` (token) e `?id=` (IG user) na rota `/api/instagram` para testar rapidamente.

## Rotas

- `/api/instagram?limit=12` — retorna feed normalizado.
  - `raw=1` para payload bruto do Graph.
- `/api/instagram/debug` — mostra status das variáveis e valida `/me` no Graph.

## Scripts (Windows)
- `scripts\configure-env.cmd` — cria/atualiza `.env.local` interativo.
- `scripts\refresh-ig-token.ps1` — troca token curto -> longo e grava `.env.local`.

## Problemas comuns
- **400 / 190 Cannot parse access token**: token do **Basic Display** ou com caracteres extras (aspas/que bra). Gere com **Facebook Login** e escopos corretos.
- **Sem mídia**: conta precisa ser **Creator/Business** e estar conectada a uma **Página**. Obtenha `IG_USER_ID` via `/{page-id}?fields=instagram_business_account`.