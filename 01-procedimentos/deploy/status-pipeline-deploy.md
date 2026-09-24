# Status — Pipeline de deploy, frontends e identidade

> **Última atualização:** 2026-09-24
> **Responsável:** Lucas Cid
> **Escopo:** entrega `monorepo` → VPS (`make deploy`), os três frontends, e a
> identidade dos apps que autenticam.
> **Estado:** 🟡 três PRs abertas, uma em draft por bloqueio externo.

---

## 🩺 Resumo

O deploy local→VPS funcionava, mas estava **travado por um serviço que não ia
subir**: o gate de segredos reprovava a entrega inteira por causa de chave
obrigatória vazia de quem não estava no deploy. Isso foi corrigido — agora se
declara no momento do deploy o que sobe. Em paralelo, os frontends Vite voltaram
ao pipeline (config em runtime) e o `assistente-admin` sai do Supabase Auth.

Nada disso está mergeado ainda. O que entra primeiro depende de uma ação manual
no Mac (seções novas no master de segredos).

## 📊 Situação por frente

| Frente | Estado | Onde |
|---|---|---|
| Deploy parcial por declaração (`TAGS`/`SERVICOS`/`EXCLUIR`) | 🟢 PR pronta | monorepo #1035 (fecha #1034) |
| Frontends com `VITE_*` em runtime, de volta ao pipeline | 🟡 PR em draft — bloqueada pelo master | monorepo #1032 (fecha #994) |
| Lint do repo (18 erros num script) | 🟢 PR pronta | monorepo #1033 |
| Identidade do `assistente-admin` → Better Auth | 🟡 código pronto em ramo, build não rodado | monorepo #1038 |
| Login com Google no admin | 🔴 decisão pendente | monorepo #1037 |
| `sales_coach_api` com chaves vazias | 🔴 decisão pendente | monorepo #1041 |
| Campo `segredos:` do manifesto é inerte | 🔴 decisão pendente | monorepo #1039 |
| Chave do Resend literal em template | 🔴 decisão pendente (girar a chave) | monorepo #1036 |
| Seções `formly_web`/`blu_web_v2` no master | 🔴 depende do dono (Mac) | monorepo #1040 |

## 🔑 Decisões tomadas

| # | Decisão | Onde |
|---|---|---|
| 1 | Deploy passa a aceitar **declaração do que sobe** (`make deploy TAGS=api,front`, ou nome de serviço, ou `EXCLUIR=`). Com declaração, o gate de segredos valida **apenas** quem sobe. Sem declaração, nada muda: faz tudo. | monorepo #1034 / PR #1035 |
| 2 | Nome de serviço **e** tag valem no mesmo parâmetro, porque é como se pensa no momento ("o que eu quero subir") — e porque o help do Makefile já anunciava `TAGS=<nomes>` antes de existir código que o honrasse. | PR #1035 |
| 3 | Valor desconhecido é **erro**, nunca seleção vazia: typo não pode virar um deploy que não sobe nada em silêncio. | PR #1035 |
| 4 | Config dos frontends passa a ser de **runtime** (`envsubst` no start do container → `window.__APP_CONFIG__`), não mais inlinada no bundle. Elimina a classe de defeito em que trocar uma URL exigia rebuild, e nenhum `ARG`/`ENV` de `VITE_*` fica gravado na imagem. | PR #1032 |
| 5 | O `assistente-admin` autentica no **Better Auth self-hosted** (AS = `brain-web`, base no Neon), não no Supabase. A sessão anda por **Bearer**, não por cookie: o admin vive em outro domínio, e cookie `SameSite=Lax` não atravessa domínio. | #1038 |
| 6 | Origem do authorization server no CSP do admin vem do **ambiente**, não literal — domínio em dois lugares é declaração duplicada que diverge em silêncio. | PR do admin, commit `e6cb399` |

## 🚧 Bloqueios e o que depende do dono

1. **Master de segredos (Mac).** As seções `formly_web` e `blu_web_v2` precisam existir no master publicado; sem elas o gate reprova e a #1032 fica em draft. Comandos prontos na monorepo #1040.
2. **Rodar o deploy de verdade.** O script exige `sops`, `age`, o master e o ssh do tailnet — só existem no Mac. A lógica de seleção e o escopo do gate estão testados; o laço de build/entrega/up não foi exercitado.
3. **Decidir** o `sales_coach_api` (#1041) e o campo `segredos:` (#1039).
4. **Google no admin** (#1037): a escolha anterior era manter, mas o fluxo por redirect não entrega sessão a uma SPA cross-origin. Virou escolha entre relaxar o cookie do AS inteiro, instalar plugin de popup, ou tirar o botão.

## 🎯 Próximas ações

**Ordem sugerida de merge:** #1033 (lint) → #1035 (deploy parcial) → #1032 (frontends) → ramo do admin.

- [ ] **Lucas** — publicar as seções no master e empurrar o cifrado (monorepo #1040)
- [ ] **Lucas** — `make deploy EXCLUIR=sales_coach_api` (ou `TAGS=...`) e validar de ponta a ponta
- [ ] **Lucas** — decidir `sales_coach_api` (#1041), campo `segredos:` (#1039) e o caminho do Google (#1037)
- [ ] **Lucas** — girar a chave do Resend e esvaziar o literal no template (#1036)
- [ ] **Hermes** — `docker build` do `assistente-admin` (prova o `npm ci` com o lockfile novo) e `nginx -t` no CSP renderizado
- [ ] **Hermes** — regenerar/comitar o `compose.prod.yml` para acompanhar os `vps_env: true` novos

## ⚠️ Drift conhecido nestes documentos

`plano-versao-estavel.md` e `prompt-execucao-nova-sessao.md`, nesta mesma pasta,
descrevem a era **GCP/Cloud Run** (gcloud rodando no Mac, `-rj`/`-ue`, SSM,
`make auth-service-deploy`). A produção hoje é **uma VPS** com cloudflared +
Caddy + docker compose, e a entrega é `docker save | ssh docker load` sem
registry. Ler aqueles dois como se fossem o presente induz a erro — o
procedimento vigente está em `ambientes-deploy.md`.

## 📅 Histórico

| Data | Atualização |
|---|---|
| 2026-09-24 | Deploy parcial por declaração implementado (monorepo #1035). Gate de segredos passa a validar só quem sobe. Frontends com config em runtime (#1032). Lint do repo corrigido (#1033). Identidade do `assistente-admin` migrada para Better Auth, código pronto e typechecked (#1038). Cinco pendências registradas como issues (#1036, #1037, #1039, #1040, #1041). |
