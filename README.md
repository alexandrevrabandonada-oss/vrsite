# Volta Redonda — Starter (Next.js + Tailwind)

Este projeto traz as seções pedidas:

- Início com feed do Instagram
- Jogos jogáveis (iframe para `/public/games/<slug>/index.html`)
- HQs/Mangás com leitor por páginas
- Artigos com visualização (PDF.js) e download

## Como rodar localmente

```bash
pnpm i # ou npm i ou yarn
pnpm dev # http://localhost:3000
```

## Publicar (Vercel)

1. Crie um repositório no GitHub e faça push deste projeto.
2. Na Vercel, **Import Project** → selecione o repositório.
3. Em **Environment Variables**, adicione:
   - `IG_ACCESS_TOKEN` (token de longa duração da Instagram Graph API)
   - `IG_USER_ID` (opcional, se você preferir usar /{ig-user-id}/media)
4. Deploy. Na Vercel, adicione seu domínio (depois de apontar DNS).

## Domínio (registro.br)

- Se usar Vercel: no painel do Vercel, **Domains** → Add → siga instruções (CNAME para `cname.vercel-dns.com` e, se o raiz for A/ALIAS, siga o IP sugerido). Depois ative SSL automático.
- Se usar outro host, aponte A/CNAME conforme instruções do provedor.

## Estrutura de conteúdo

- **Instagram**: `src/app/api/instagram/route.ts` busca seu feed. Sem token, usa dados de exemplo.
- **Jogos**: coloque o build do seu jogo em `public/games/<slug>/index.html`.
- **HQs**: coloque imagens por capítulo em `public/hqs/<serie>/<cap>/<001>.webp`…
- **Artigos**: coloque PDFs em `public/artigos/<slug>.pdf`.

## Notas

- `PdfViewer` usa `pdfjs-dist` sem SSR (carregado dinamicamente).
- `MangaReader` faz pré-carregamento da próxima página e atalhos ←/→.
- Ajuste `totalPages` na rota do capítulo.

Bom dev! 🎮📚
