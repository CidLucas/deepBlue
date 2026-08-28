# 🚢 Ambientes de Deploy — Deep Blue

> **Procedimento:** onde cada coisa roda, como se publica em cada ambiente, e
> os vícios/armadilhas medidos em cada um.
> **Status:** vigente (baseline 2026-08-28, primeiro deploy de staging verde).
> **Dono:** Lucas Cid · **Executor dos deploys:** dono, no Mac (`ssh mac`).
> **Fontes técnicas:** `docs/pipeline-local.md`, `docs/staging.md`,
> `docs/deploy-staging.md` e `scripts/local/*.sh` do monorepo (CidLucas/monorepo).

---

## 1. Mapa dos ambientes

```
                     ┌─ GCP blu-control-panel (sa-east1) ──────────────────────┐
 código (main)  ──▶  │ Cloud Run: agent-api, backend-api, routines-api,        │
                     │ tool-pool-api, formly-api, formly-web, ops-centro-api,  │
                     │ assistente-api, assistente-admin, brand-hub(-stg),      │
                     │ brand-hub-api, brain-web, formly-api-stg, formly-web-stg│
                     └──────────────────────────────────────────────────────────┘
 código (develop) ─▶ staging -stg (formly + brand-hub) — mesmo projeto GCP

 blu-web         ──▶ AWS S3 + CloudFront (deploy-web)
 memory_api      ──▶ AWS EC2 t3.small (deploy-memory, ECR + SSM)
 local/dev       ──▶ docker compose (formly-dev-up), stack local no Mac/VPS
 ops (ops-centro)──▶ GHCR + docker compose NA EC2 do Hermes (host-bound)
```

| # | Ambiente | O que roda | Quem faz deploy | Comando |
|---|---|---|---|---|
| 1 | **Produção GCP (Cloud Run)** | 8+ serviços do monorepo | Dono, no Mac | `make deploy SERVICOS="..."` |
| 2 | **Staging GCP (`-stg`)** | formly-api-stg, formly-web-stg, brand-hub-stg | Dono, no Mac | `ENV=staging make deploy SERVICOS="formly_api formly_web"` |
| 3 | **AWS — blu-web** | S3 + CloudFront | Dono, no Mac | `make deploy-web` |
| 4 | **AWS — memory_api** | ECR + EC2 via SSM | Dono, no Mac | `make deploy-memory` |
| 5 | **Cloud Run sem terraform** | brand-hub, brand-hub-api, brain-web | Dono, no Mac | `make brand-hub-deploy` / `brand-hub-api-deploy` / `brain-web-deploy` |
| 6 | **Local/dev** | formly stack completa (compose) | dev | `make formly-dev-up` |

**Regras transversais** (valem para todos):

1. **Nenhum deploy roda em CI.** Workflows do GitHub estão `disabled_manually`
   **de propósito** (cota free estourou em 2026-08, issue #78) — o pipeline
   inteiro é local via `make`, rodado pelo dono no Mac. **NUNCA rodar
   `gh workflow enable`** nos workflows do monorepo.
2. **Merge ≠ produção.** Com workflows desligados, mergear PR não publica
   nada. "Está em produção?" se responde com `scripts/check-versions.sh`
   (compara `/health` sha vs main), nunca assumindo.
3. **Todo deploy começa em `DRY_RUN=1`** — confere nomes/destino antes de
   tocar em qualquer coisa.
4. **Autorização explícita para comandos com secrets reais** — apresentar o
   comando completo à vista antes de rodar deploy com secrets (decisão do
   dono 19/08).
5. **Deploy não é substituto de apply**: PR de terraform mergeado precisa de
   `terraform apply` local (no Mac) para materializar outputs/recursos — até
   lá o deploy lê config velha ou trava (caso #530).
6. **Ordem migrations → código** (Formly): o gate `check-formly-migrations.sh`
   aborta o deploy se o banco tem migration pendente — aplique com `--apply`
   primeiro. Schema staging = `formly_stg` (secret `FORMLY_DATABASE_URL_STG`).

## 2. Ambiente 1 — Produção Cloud Run (o deploy.sh)

**O que é:** o `scripts/local/deploy.sh` do monorepo — o CD do repositório
rodando local. Mesma sequência do cd.yml (especificação congelada): árvore
limpa → gate CI (lint+test) → build amd64 → smokes (import, non-root, /health)
→ push registry → **revisão candidata SEM tráfego** → verifica pela URL da
tag → promove 100% → remove tag.

**Onde roda:** Mac do dono (`~/Documents/GitHub/monorepo`), clone na `main`.

**Pré-requisitos:** gcloud autenticado (`cid.lucas@gmail.com` /
`blu-control-panel`), Docker rodando, árvore limpa, `FORMLY_VITE_*` para
formly_web (do Secret Manager ou `apps/formly-web/.env`).

**Processo:**

```bash
ssh mac
cd ~/Documents/GitHub/monorepo
git checkout main && git pull

# 1. Dry-run primeiro — confere serviços deduzidos pelo diff
DRY_RUN=1 make deploy SERVICOS="formly_api formly_web"

# 2. Deploy de verdade (gate completo roda antes do build)
make deploy SERVICOS="formly_api formly_web"

# 3. Verificar alinhamento deploy vs main
./scripts/check-versions.sh
```

**Pacotes válidos:** `agents_api backend_api routines_api tool_pool_api
formly_api ops_centro formly_web assistente_api assistente_admin`.

**Verificação:** veredito do script (`✓ ... publicado — URL`), e
`/health` de cada serviço (expõe `GIT_SHA`); `check-versions.sh` fecha o
loop.

**Vícios medidos:**

- **Config da revisão vem do terraform** (`terraform output -json
  service_config` de `environments/production`) — nunca herdada do serviço.
  PR de terraform mergeado sem apply = deploy sobre config velha (bug
  26/08 do ENVIRONMENT=prod). Apply primeiro, sempre.
- `--platform linux/amd64` **obrigatório** no buildx (Mac é arm64; Cloud Run
  é x86_64). Imagem arm64 publica e só falha ao subir. O script já força, mas
  todo script novo precisa lembrar.
- `formly_web` exige `FORMLY_VITE_SUPABASE_URL/ANON_KEY` — sem elas o deploy
  aborta com mensagem clara (a ordem: env > Secret Manager > `.env` do produto).
- "Layer already exists" no push do segundo serviço é **normal** (camadas
  compartilhadas), não é erro.
- **Rollback:** revisões anteriores continuam no Cloud Run;
  `gcloud run services update-traffic <svc> --to-revision=<rev>` volta o
  tráfego. Imagens por SHA permitem redeploy de commit específico
  (`make deploy` de branch antiga + `SKIP_CI=1`).

## 3. Ambiente 2 — Staging (`ENV=staging`)

**O que é:** mesmo projeto GCP de produção, serviços com sufixo `-stg`,
`min_instances=0` (scale-to-zero), URLs run.app. Valida `develop` antes da
main: `feature → PR → develop → deploy stg → validação E2E → PR
develop→main → deploy prod`.

**Onde roda:** Mac do dono, clone no `develop`.

**Pré-requisitos:**

1. Terraform de `infra/terraform/environments/staging/` **aplicado** — o
   deploy lê `terraform output -json service_config` de lá (issue #530:
   faltava o output; fix #531 mergeado 28/08).
2. Secrets `_STG` populados: `FORMLY_DATABASE_URL_STG`,
   `FORMLY_SUPABASE_URL_STG`, `FORMLY_SUPABASE_ANON_KEY_STG`,
   `FORMLY_SUPABASE_SERVICE_KEY_STG`, `FORMLY_SUPABASE_JWT_JWK_STG`
   (valor via `gcloud secrets versions add`).
3. Schema `formly_stg` + bucket `formly-uploads-stg` no Supabase (F2/#519).
4. Migrations em dia: `ENV=staging scripts/local/check-formly-migrations.sh`
   (usa o secret `_STG`).

**Processo:**

```bash
ssh mac
cd ~/Documents/GitHub/monorepo
git checkout develop && git pull

DRY_RUN=1 ENV=staging make deploy SERVICOS="formly_api formly_web"   # conferir
ENV=staging make deploy SERVICOS="formly_api formly_web"

# brand-hub-stg a partir do develop:
ENV=staging make brand-hub-deploy
```

**Verificação:**

```bash
curl -s https://formly-api-stg-960100281317.southamerica-east1.run.app/health
curl -s -o /dev/null -w '%{http_code}\n' https://formly-web-stg-960100281317.southamerica-east1.run.app/
```

**Vícios medidos:**

- **"Layer already exists" + `✗ (terraform output service_config)`** = o
  state do staging está sem o output — rode `terraform apply` em
  `environments/staging` ANTES de re-rodar o deploy (caso #530, 28/08).
  Outputs só materializam no state depois do apply.
- **Chaves do `service_config` com sufixo `-stg`**: `formly-api-stg`, não
  `formly-api` — o deploy faz lookup por nome do serviço com sufixo; chave
  errada = config vazia silenciosa → candidata reprova /health sem erro claro.
- Gate de migrations usa secret `_STG` — **schema formly_stg**, banco é o
  MESMO Supabase de produção (isolamento por schema, não por banco).
- Secrets de IA/e-mail (GROQ/RESEND/DEEPSEEK/OLLAMA) **compartilhados com
  produção** por decisão do dono (#520) — sem sufixo `_STG`.
- Restante do monorepo (assistente, memory_api...) **não tem staging** —
  só Formly e brand-hub hoje.
- **Rollback:** revisões ficam; `update-traffic --to-revision`. Schema
  `formly_stg` compartilha banco com prod — migration destrutiva em staging
  toca o banco de produção. Cuidado dobrado.

## 4. Ambiente 3 — blu-web (AWS S3 + CloudFront)

**O que é:** frontend do Blu em `apps/blu-web` → bucket S3 + distribuição
CloudFront, com o E6 (Playwright) rodando contra a URL pública.

**Processo:**

```bash
ssh mac
cd ~/Documents/GitHub/monorepo
git checkout main && git pull
DRY_RUN=1 make deploy-web
make deploy-web                              # exige VITE_SUPABASE_* no ambiente
```

**Verificação:** E6 roda dentro do script (Playwright contra a borda);
veredito `✓ blu-web publicado em <url>`.

**Vícios medidos:**

- **Exige `VITE_SUPABASE_URL`/`ANON_KEY` exportadas** — sem elas o bundle abre
  **em branco** (o `auth/client.ts` lança no import) e o build passa mesmo
  assim. O script tem trava: confere se o bundle assou as VITE_* antes do sync.
- **Dois syncs, e a ordem é o desenho**: assets com hash primeiro (imutáveis,
  cache longo), index.html depois (no-cache, com `--delete`). Inverter = HTML
  novo apontando para assets que ainda não subiram.
- **Não há revisão sem tráfego**: o S3 já serve o bundle novo assim que o sync
  roda — E6 reprova contra a borda já publicada. Consertar = republiquar.
- CloudFront é global (us-east-1 para invalidação) — a região do resto é
  `sa-east-1`. Invalidação espera concluir antes do E6 (senão mede borda velha).
- `SKIP_E2E=1` pula o E6 — usado conscientemente.

## 5. Ambiente 4 — memory_api (AWS EC2 via SSM)

**O que é:** imagem no ECR + container na EC2 t3.small (sa-east-1), com Caddy
na frente. Deploy empacota `infra/memory_api`, envia por SSM Run Command e
roda `./deploy.sh --proxy` dentro da VM.

**Processo:**

```bash
ssh mac
cd ~/Documents/GitHub/monorepo
DRY_RUN=1 make deploy-memory
make deploy-memory          # grava GATEWAY_IMAGE no SSM e deploia na VM
```

**Verificação:** status do SSM `Success` + `/healthz` pela URL pública
(exige `MEMORY_API_URL` exportada; sem ela o script avisa e pula).

**Vícios medidos:**

- **A tag é `sha-<commit>`, nunca `latest`** — é o que responde "o que está no
  ar?" fora da VM e dá alvo de rollback. ECR é IMMUTABLE: mesma tag duas vezes
  = erro; o script trata tag existente como "pula o build" (redeploy de
  commit legítimo).
- **SSM Run Command com arquivos inline em base64** (não download do GitHub:
  repo privado → 404 sem auth; token no comando vazaria no CloudTrail).
- **Auth AWS com profile certo**: profile `default` do Mac (MantleApiKey)
  tem SSM/STS mas **não** tem `ecr:GetAuthorizationToken` — para deploy do
  memory_api usar AWS_PROFILE com ECR+SSM (ex.: o profile antigo do EC2) ou
  anexar `AmazonEC2ContainerRegistryPowerUser` ao Mantle. `InvalidTokenId` =
  env `AWS_*` poluída → `unset` antes.
- Rollback: `./deploy.sh <tag-anterior>` **na VM** (o GATEWAY_IMAGE do SSM
  continua apontando pra tag nova — regravar após voltar).

## 6. Ambiente 5 — Cloud Run sem terraform (brand-hub, brand-hub-api, brain-web)

**O que é:** os serviços que não passam pelo módulo terraform do monorepo —
deploy por script standalone, mesma rede de proteção (revisão sem tráfego →
smoke na URL da tag → promove). Segredos injetados via `--set-secrets`.

**Processo:**

```bash
ssh mac
cd ~/Documents/GitHub/monorepo
DRY_RUN=1 make brand-hub-deploy            # brand-hub (estático, nginx)
ENV=staging make brand-hub-deploy          # brand-hub-stg (develop)
make brand-hub-api-deploy                  # brand-hub-api (transcrição Groq)
make brain-web-deploy                      # brain-web (AS OAuth + landing)
make brain-web-deploy SHA=abc123           # commit específico (main)
```

**Verificação:** veredito do script (candidata responde → promove). URLs:
brand-hub por run.app (sem domain mapping — sa-east1 não suporta);
brain-web = app.mcp-brain.com (domínio próprio, região us-east1? ver nota).

**Vícios medidos:**

- **Domínio custom só em região suportada** — `southamerica-east1` **não
  suporta** domain mappings (501 UNIMPLEMENTED). Quem precisa de domínio
  próprio fica em us-east1 + Cloudflare na frente (região BR não muda) ou
  Worker proxy.
- brand-hub: fonte canônica do HTML é `design/design-systems/brand-hub/`
  (design-writer); `apps/brand-hub/` é cópia promovida por
  `sync-brand-hub.sh` — **nunca editar o HTML em apps/**, edite na fonte.
- brain-web: `--set-secrets` precisa das chaves no Secret Manager
  (GROQ_API_KEY, SMTP_USER, SMTP_PASS) — primeiro deploy de serviço NOVO não
  usa `--no-traffic` (não há revisão antiga a preservar).
- brand-hub-api: secrets GROQ/SMTP exigem `secretAccessor` para a SA do
  serviço — eventual consistency de IAM minutos após o apply.

## 7. Ambiente 6 — Local/dev

**O que é:** stack completa do Formly em docker compose no dev — Postgres
local (formly_dev), backend na 8000, frontend na 5173.

```bash
make formly-dev-up      # sobe a stack
make formly-dev-down
make formly-dev-reset   # zera e recria (drop + migrations + seed)
```

**Vícios medidos:**

- Banco local: `formly_dev` no pg do compose; migrations em
  `supabase/formly/migrations` (schema-base) — a 0007 é só Supabase
  (storage.buckets), não roda local.
- Frontend local aponta para o backend local (`.env` do produto). Nunca usar
  `.env` raiz do monorepo como fonte de VITE_* do formly — carrega VITE do BLU
  (bug 13/08 do login caindo no blu-v3).
- **não destrua o `.venv` com .pth editable** — a VPS usa o `.venv` da main
  com `.pth` editable para worktrees (pytest com PYTHONPATH das libs).

## 8. Fluxo staging → produção (o caminho canônico)

```
feature/xxx ──PR──▶ develop ──deploy stg──▶ -stg ──E2E manual──▶ PR develop→main ──deploy prod──▶ produção
```

1. Agente implementa e abre PR contra `develop`.
2. Dono mergeia (feature→develop).
3. Dono roda `ENV=staging make deploy SERVICOS=...` no Mac (dry-run antes).
4. Validação E2E manual no `-stg` (checklist em `docs/staging.md` §6).
5. PR `develop → main`, dono mergeia.
6. Dono roda `make deploy` (production) no Mac.
7. `./scripts/check-versions.sh` fecha o loop (deploy vs main alinhados).

**Onde os segredos vivem** (por ambiente):

| | Produção | Staging |
|---|---|---|
| Secrets do container | Secret Manager (nome = nome da env) | `_STG` (formly) / compartilhados (IA/e-mail) |
| VITE_* do build | Secret Manager `FORMLY_SUPABASE_*` | `FORMLY_SUPABASE_*_STG` |
| Banco Formly | schema `formly` | schema `formly_stg` (mesmo Supabase) |
| Config da revisão | `terraform output service_config` (production) | idem (staging) |
| Imagem | AR `blu/<pacote>:sha-<sha>` | mesmo AR, mesmo projeto |
| Domínio | formly.ink (Cloudflare→run.app) | run.app (sem domínio) |

## 9. Vícios transversais (levantados na formalização, 28/08)

1. **Apply do terraform é passo explícito que ninguém automatizou** — PR merge
   é "metade do deploy". #530 nasceu disso (output sem apply). Ideal futuro:
   PR terraform mergeado dispara lembrete/apply.
2. **Staging cobre só Formly + brand-hub** — assistente, memory_api, backend,
   agents, routines, tool_pool vão direto pra produção sem etapa de staging
   (ver #519).
3. **Staging compartilha banco com produção** (mesmo Supabase, schema
   diferente) — migration destrutiva em staging afeta o banco de prod.
4. **check-versions.sh não cobre staging** (issue #523) — drift invisível.
5. **E2E de staging é manual** — não há E2E automatizado contra -stg.
6. **"Está em produção?" é pergunta de duas fontes** — `/health` sha e
   `git rev-parse origin/main` — conferir sempre as duas.
7. **Gate kanban↔GitHub**: issues fecham com PR mergeado; deploy é passo
   à parte que o kanban não vê.
8. **Deploy roda em uma máquina só** (Mac) — se o Mac cair, produção trava.
   Mitigação registrada (não implementada): bootstrap da VPS PrimeClaws
   (procedimento de migração em `01-procedimentos/deploy/migracao-primeclaws/`).
9. **Bash 3.2 (macOS)** — scripts de deploy precisam ser compatíveis (sem
   `mapfile`, sem arrays associativos).
10. **Secrets no chat são redigidos** pelo filtro do Hermes — comandos de
    deploy com secrets são entregues por arquivo (write_file + scp), nunca
    inline no chat.

## 10. Referências

- Monorepo: `docs/pipeline-local.md` (o porquê de tudo ser local),
  `docs/staging.md` e `docs/deploy-staging.md` (staging),
  `scripts/local/deploy*.sh` (fonte da verdade dos fluxos).
- Skills Hermes: `monorepo-cloud-run-deploy` (pitfalls detalhados),
  `frontend-deployment`, `aws-ecr-ssm-deploy`.
- Issues: #519 (staging), #530/#531 (service_config), #78 (pipeline local),
  #96 (healthcheck), #522/#523 (dívidas de staging).
