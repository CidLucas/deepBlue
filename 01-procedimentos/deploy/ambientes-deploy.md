# 🚢 Ambientes de Deploy — Deep Blue

> **Procedimento:** o caminho de uma mudança até produção, o que cada etapa
> garante, como se publica em cada ambiente, e como verificar.
> **Status:** vigente — reescrito 2026-09-24 para o mundo VPS.
> Substitui a versão de 2026-08-28, que descrevia Cloud Run + AWS + Terraform
> (todos removidos na consolidação #873) e cujas issues #519/#530/#531/#533 já
> não têm alvo.
> **Dono:** Lucas Cid · **Executor dos deploys:** dono, na máquina de build.
> **Fontes técnicas no monorepo:** `docs/deploy-local.md`,
> `infra/vps/README.md`, `infra/services.yml` (o manifesto),
> `scripts/ci/compose_vps.py`, `scripts/ci/deploy-local.sh`,
> `infra/vps/deploy.sh`, `infra/vps/Caddyfile`.

---

## 1. Objetivo e princípio

Uma mudança só chega ao usuário depois de ter rodado **em algum lugar que não é
a máquina de quem a escreveu**. O staging existe para ser esse lugar: é onde o
código encontra o ambiente real — banco, segredos, domínio, rede, permissões —
e falha antes de o usuário falhar.

```
feature/xxx ──PR──▶ develop ──deploy staging──▶ stack -stg ──validação──▶
             PR develop→main ──merge──▶ main ──deploy produção──▶ produção
```

**As duas regras que sustentam o desenho:**

1. **`main` é produção. `develop` é staging.** Nada roda em produção que não
   esteja na `main`. Nada chega na `main` sem ter passado pelo staging.
2. **O ramo determina o destino, e o código impõe isso.** Não é acordo verbal:
   o script de deploy recusa destino incompatível com o ramo. Se a regra só
   vive na cabeça de quem roda, ela não existe — foi assim que produção passou
   a rodar um commit da `develop` sem ninguém decidir (#1024).

## 2. Acordos de desenvolvimento

| # | Acordo |
|---|---|
| A1 | **Toda mudança nasce em branch** (`feat/`, `fix/`, `chore/`). Nunca commit direto em `develop` nem em `main`. |
| A2 | **O PR vai contra `develop`**, não contra `main`. `develop` é a fila de integração. |
| A3 | **Todo defeito ou decisão pendente encontrado vira issue na hora** (`gh issue create`), título começando pelo serviço afetado. Nunca anotado em documento — regra do `CLAUDE.md` do monorepo, vale para todo agente. |
| A4 | **Merge em `develop` não é publicação.** Publica quem roda `make deploy`. "Está em produção?" se responde pela tag da imagem em execução, não pelo git. |
| A5 | **O PR `develop → main` é o ato de promoção.** Abre só depois da validação em staging. Depois do merge, o deploy de produção é passo seguinte e obrigatório — `main` mergeada e não deployada é produção mentindo. |
| A6 | **`develop → main` é merge, nunca cherry-pick nem `--force`.** O que foi validado em staging é exatamente o que vai para produção; qualquer outra coisa invalida a validação. |
| A7 | **Deploy é manual, rodado pelo dono** (decisão #78 — a cota free do GitHub estourou; o CI é juiz, não entregador). Agente não roda deploy sem autorização explícita. |
| A8 | **Todo deploy começa em `DRY_RUN=1`.** Confere destino e serviços antes de tocar em qualquer coisa. |
| A9 | **O gate de qualidade é `make ci` rodado localmente antes de abrir o PR** (lint + testes + gates). O CI do GitHub está desligado por decisão (#78), então não há portão automático — quem abre o PR é quem roda o portão. |
| A10 | **NUNCA rodar `gh workflow enable`** nos workflows do monorepo. Eles estão desligados de propósito; religar reintroduz a cota estourada e um entregador concorrente com o `make deploy`. Se o CI for religado, é decisão explícita e este documento muda junto. |

## 3. Mapa dos ambientes

Tudo roda numa VPS única — `srv1986172`, `100.69.98.90` no tailnet. São **duas
stacks de docker compose** no mesmo host, com nomes de projeto diferentes:

```
Internet
  └─ Cloudflare (edge, TLS)
       └─ cloudflared (systemd, /etc/cloudflared/config.yml)
            └─ localhost:80
                 └─ Caddy (container, auto_https OFF)
                      ├─ rede vps_internal     → stack de PRODUÇÃO (projeto `vps`)
                      └─ rede vps-stg_internal → stack de STAGING  (projeto `vps-stg`)
```

O Caddy é um só, na porta 80, e roteia por `Host` — os domínios de staging
apontam para os containers `-stg` no mesmo Caddyfile. Não existe segundo proxy.

| | Produção | Staging |
|---|---|---|
| Ramo | `main` | `develop` |
| Compose | `infra/vps/compose.prod.yml` | `infra/vps/compose.stg.yml` *(a criar)* |
| Projeto docker | `vps` | `vps-stg` |
| Manifesto | `ambientes.producao: true` | `ambientes.staging: true` |
| Imagem | `ghcr.io/cidlucas/monorepo/<svc>:<sha>` | idem, container com sufixo `-stg` |
| Domínio | `api.deepblue.company`, `formly.ink`, … | §6 |

**Nenhum deploy roda em CI** — princípio do `docs/deploy-local.md`. Mas o outro
lado desse princípio **não está de pé**, e é o achado mais importante deste
documento:

### 3.1 O juiz está desligado

Todos os workflows de CI/CD do monorepo estão `disabled_manually` no GitHub:

```
$ gh workflow list --all
disabled_manually   CI
disabled_manually   Docker
disabled_manually   CD
disabled_manually   E2E prod
disabled_manually   Formly Web CD
disabled_manually   Memory CD
disabled_manually   Healthcheck
disabled_manually   Prompts drift
disabled_manually   Backup dos banks
disabled_manually   Retenção de logs (Turso)
active              Métricas emitidas
active              Secrets
```

É decisão consciente (issue #78: a cota free do GitHub Actions estourou em
2026-08). A consequência, porém, não foi absorvida pelo processo:

| O que o processo supõe | O que existe |
|---|---|
| "os gates de PR protegem a `main`" | **não rodam** — nenhum run para o commit da `develop` nem da `main` |
| O CD é "juiz, nunca entregador" | não há juiz |
| `deploy-local.sh` consulta o veredito do CI para o sha | consulta `gh run list --commit <sha>`, encontra **0 runs**, cai no default `no-run` e imprime "(nenhum run encontrado — seguindo)". **O gate é vácuo: ele lê verde porque não tem o que ler.** |
| Proteção de ramo na `main` | indisponível — o repositório é privado e a conta não é GitHub Pro (HTTP 403) |

**Hoje nada protege a `main`.** Nem CI, nem proteção de ramo, nem gate de
merge — só a revisão manual do dono. O procedimento de produção continua
válido, mas o portão de qualidade que ele pressupõe não existe.

**Enquanto o CI estiver desligado, o gate é local e explícito:** rodar
`make ci` (lint + testes + gates) antes de abrir o PR. Não é equivalente — não
roda em máquina limpa, não roda no PR, e depende de quem lembra — mas é
honesto. A alternativa (religar o CI) depende de a cota caber, e é decisão do
dono.

## 4. Produção

**Ramo:** `main`. **Comando:** `make deploy`, na máquina de build.

O `scripts/ci/deploy-local.sh` faz o ciclo inteiro:

1. Pré-requisitos locais (docker, sops, age, `SOPS_AGE_KEY_FILE`, ssh para a VPS)
2. **Árvore git limpa** — aborta se houver modificação não commitada
3. Tag = `git rev-parse --short HEAD`
4. Veredito do CI para esse sha — **hoje vácuo** (§3.1): ele consulta
   `gh run list --commit <sha>`, encontra 0 runs e segue. `FORCE=1` seria o
   escape, e não faz diferença enquanto o CI estiver desligado.
5. Decifra o master SOPS e renderiza os `infra/vps/*.env`, com validação
6. Para cada serviço com `env_file`: `docker build --platform linux/amd64` →
   `docker save | ssh vps docker load`
7. Entrega os `.env` + compose + `deploy.sh` na VPS (`install -m 600` / `755`)
8. `ssh vps 'cd /root/monorepo/infra/vps && SKIP_PULL=1 ./deploy.sh prod'`

O `deploy.sh` então: guarda a imagem atual de cada serviço (para rollback),
sobe, espera cada healthcheck do compose (30 × 2s por serviço) e **reverte**
automaticamente o que ficar `unhealthy`.

**Verificação:** a saída do `deploy.sh` ("Pronto." + `compose ps`) lista cada
serviço como `healthy`. Serviço `unhealthy` dispara rollback.

### Vícios medidos

- **A imagem não vem de registry.** O GHCR tem 2 pacotes publicados
  (`monorepo/memory-api`, `mcp_brain_lite-gateway`); os outros 11 serviços
  existem só no daemon da VPS, entregues pelo pipe SSH. É por isso que
  `SKIP_PULL=1` é **obrigatório** — `docker compose pull` daria 404.
- O build roda na **máquina de quem deploya** (x86_64 nativo, ou Mac com
  `--platform linux/amd64`). A VPS não builda em produção.
- **Frontends com `VITE_*` não são re-buildados** enquanto a #994 estiver
  aberta: `compose_vps.py` não emite `build.args`, então `blu-web-v2` e
  `formly-web` preservam a imagem antiga **de propósito** — "não matamos
  produção por falta de args". Não confundir com container esquecido.
- **`brand-hub-api` fica fora do deploy** até a #1015 (o gerador emite caminho
  de Dockerfile errado para ele).
- **Rollback pode retaguear a imagem errada** (#1014): `IMAGENS` e `SERVICOS`
  são alinhados por posição. Depois de um rollback, conferir `docker images`.
- **O healthcheck que o gerador emite é `/health` por padrão.** Serviço que
  expõe outro caminho precisa declarar `vps_health` no manifesto — o
  `llm_gateway` expõe `/healthz` e já tem a linha; sem ela o container fica
  `unhealthy` para sempre e o deploy reverte um deploy bom.

## 5. Staging

**Ramo:** `develop`. **Comando:** `make deploy ENV=staging` *(a implementar)*.

**Serviços:** os que o manifesto marca — hoje **11 de 17**:

```bash
python3 -c "
import yaml; m=yaml.safe_load(open('infra/services.yml'))
for k,v in m.items():
    if isinstance(v,dict) and (v.get('ambientes') or {}).get('staging'): print(' ',k)"
```

→ `agents_api`, `backend_api`, `routines_api`, `tool_pool_api`, `formly_api`,
`ops_centro`, `assistente_api`, `formly_web`, `assistente_admin`, `brain_web`,
`sales_coach_api`.

**Ficam fora, e o porquê importa:**

| Serviço | Por que não tem staging |
|---|---|
| `memory_api` | Control plane no Neon com dado pessoal de titular; um branch Neon nasce com os dados de produção dentro (§7, R6/R7) |
| `llm_gateway` | Componente compartilhado: staging consome o mesmo gateway, não uma cópia com as mesmas chaves de LLM |
| `blu_web_v2`, `brand_hub`, `brand_hub_api` | Fronts/estáticos sem `VITE_*` resolvidas na VPS (#994) e #1015 |

**Verificação:** o healthcheck de cada container (mesmo mecanismo da produção)
**mais** uma bateria de fumaça contra os domínios de staging (§6). No staging um
container `unhealthy` **não** deve disparar rollback — staging é para quebrar.

## 6. Domínios

Esquema proposto — **a confirmar**: exige registro DNS no Cloudflare e entrada
no ingress do túnel (`/etc/cloudflared/config.yml`).

| Propósito | Produção | Staging |
|---|---|---|
| APIs | `api.deepblue.company` | `stg-api.deepblue.company` |
| Brand Hub (landing) | `deepblue.company` | `stg.deepblue.company` |
| Brand Hub API | `hub.deepblue.company` | `stg-hub.deepblue.company` |
| Assistente Admin | `admin.deepblue.company` | `stg-admin.deepblue.company` |
| Formly | `formly.ink` | `stg.formly.ink` |
| Blu App | `bluapp.ink` | `stg.bluapp.ink` |
| Brain | `mcp-brain.com` | `stg.mcp-brain.com` |

## 7. Isolamento de dados — a regra dura

> **Regra #1: staging nunca escreve em dado de produção.**

**Decisão do dono (2026-09-24):** staging **compartilha o projeto** e isola por
schema/bucket; onde houver Neon, usa-se *branch* por ambiente.

**Estado real do parque** (verificado 2026-09-24, lendo os env publicados):

| Backend | Onde | Usado por |
|---|---|---|
| Supabase `haruewffnubdgyofftut` | projeto do monorepo (pooler `us-west-2` + conexão direta) | `agents_api`, `backend_api`, `routines_api`, `tool_pool_api` — e `memory_api`/`assistente_api` para auth e metadados |
| Supabase `pvrtkynjjwbxgnfyalqh` | projeto do Formly (pooler `ca-central-1`) | `formly_api` (`FORMLY_DATABASE_URL`) |
| **Neon** | `ep-late-boat-acelht57-pooler.sa-east-1.aws.neon.tech`, db `neondb`, user `neondb_owner` | **`memory_api`** (`CONTROL_PLANE_DATABASE_URL`) e **`backend_api`** (`BILLING_DATABASE_URL`) |
| Turso | banco do painel | `ops_centro` |
| SQLite local | dentro do container, **sem volume** | `brain_web` (`AUTH_SQLITE_PATH=/data/auth.db`) — foi projetado para Neon e não foi wireado: **#1029** |

São portanto **três backends Postgres distintos** (dois Supabase + um Neon),
não um. A decisão operativa é:

- **Supabase** → isolamento por **schema/bucket** (`<svc>_stg`, `*-stg`).
- **Neon** → isolamento por **branch** por ambiente (o Neon suporta branch
  nativo), para `memory_api` e `backend_api`.
- **Turso** → banco separado para o `ops_centro`.
- **SQLite sem volume** não é ambiente — é defeito (#1029).

⚠️ **O risco é maior do que parece, e é o mesmo que a versão anterior deste
documento registrava como vício.** Schema diferente não é banco diferente: uma
migration que toque objeto global (`storage.buckets`, `auth.*`, roles) atinge
produção. O caso já aconteceu — a migration `0007_uploads_do_respondente.sql`
faz `insert`/`update` em `storage.buckets`, que é global, e por isso o
bootstrap de staging **precisa pular a 0007**.

**Regras derivadas, obrigatórias:**

- **R1.** Todo schema de staging leva sufixo (`formly_stg`, `<svc>_stg`).
- **R2.** Migration que toque objeto global **não roda em staging**. Se ela
  precisar rodar, o alvo é produção e o teste é outro.
- **R3.** O bootstrap de staging é idempotente e versionado no monorepo
  (`supabase/<produto>/staging/bootstrap.sh`), nunca executado à mão.
- **R4.** Bucket de staging separado (`formly-uploads-stg`, não
  `formly-uploads`).
- **R5.** A credencial de staging é uma **chave diferente**, com o mesmo escopo
  mínimo — nunca a chave de produção reaproveitada.
- **R6.** Serviço que guarde dado pessoal de titular **sai do staging**. É por
  isso que `memory_api` está fora (§5).
- **R7.** **Branch Neon não é ambiente limpo.** Um branch do Neon é clone
  *copy-on-write* do pai: ele nasce com **os dados de produção dentro**. Para o
  `memory_api` — cujo control plane no Neon guarda `tenants`, `users`,
  `memberships`, `documents` — um branch de staging **é uma cópia de dado
  pessoal de produção**, e por isso não satisfaz o R6. Branch serve para o
  `backend_api` (billing: dado financeiro agregado, não de titular) e para
  testar migration antes de aplicá-la no pai.

## 8. O que o código precisa ter para este documento valer

Este procedimento descreve um desenho que **hoje não está implementado**. Cada
lacuna abaixo é (ou será) uma issue na fila do monorepo; o documento só vale
quando todas fecharem.

| Lacuna | Issue |
|---|---|
| Não existe stack de staging: o compose não tem `profile:` nem serviço `-stg`, e o `deploy.sh` aceita `staging` sem que nada mude | #1025 |
| `deploy-local.sh` não tem parâmetro `ENV`; a linha 163 tem `./deploy.sh prod` hardcoded | #1025 |
| `compose_vps.py` lê `ambientes.producao` e ignora `ambientes.staging` — o campo existe no manifesto e não tem consumidor | #1025 |
| `deploy-local.sh` não checa o ramo — usa `git rev-parse --short HEAD` de qualquer árvore (foi assim que produção recebeu um commit da `develop`) | #1026 (decisão de processo: #1024) |
| `docker.yml` (gate de build) roda só em PR para `main` — `develop` não passa por ele. Latente enquanto o CI estiver desligado; ativo no dia em que religar | #1027 |
| O gate de veredito do CI no `deploy-local.sh` é **vácuo** (§3.1): o CI está desligado, então ele sempre lê "nenhum run" e segue | #1027 |
| **Nada protege a `main`**: CI desligado, sem proteção de ramo (limitação do plano), sem gate de merge | #1027 |
| Workflows que descrevem um mundo que não existe: `cd.yml` (Cloud Run), `formly-web-cd`, `memory-cd`, `backup`, `healthcheck`, `e2e-prod` | #1028 |
| O banco de auth do `brain_web` vive em `/data/auth.db` sem volume — é destruído a cada deploy (§9.15) | #1029 |
| O checkout da VPS nunca é sincronizado pelo deploy — `git log`/`git status` dela não descrevem produção | #1023 |

**Enquanto essas lacunas existirem, a regra do §1.2 não é verdadeira:** nada no
código impede um deploy da `develop` em produção. É exatamente o que está
acontecendo hoje — a tag no ar é `cc6f2f5`, da `develop`; a `main` está 37
commits atrás.

## 9. Vícios transversais

1. **Produção roda um commit que a `main` não tem** (#1024).
2. **"O que está em produção?" não tem resposta pelo git da VPS** — o checkout
   dela é alvo de entrega, não registro (#1023).
3. **O gate de árvore limpa protege a máquina de quem deploya, não a VPS** —
   o `deploy-local.sh` escreve por cima da VPS por desenho (#1023).
4. **Dois arquivos de config do cloudflared**, um morto e desatualizado
   (`/root/.cloudflared/config.yml`). O ativo é `/etc/cloudflared/config.yml`
   (#1021).
5. **`brand-hub` roda como container órfão** fora do compose, e serve
   `deepblue.company` — um `--remove-orphans` derruba o domínio (#1019).
6. **`assistente-admin` está no compose e não existe como container**, mas o
   Caddyfile roteia `admin.deepblue.company` para ele (#1020).
7. **Processos sem supervisão**: `design-server` (nginx, 8899) e
   `python3 -m http.server 8888` servindo `/root/design-export` em `0.0.0.0`
   (#1019).
8. **`docs/vps/deploy-readiness.md` e `infra/vps/README.md` descrevem o mundo
   anterior à #873** (#1022). O `README.md` ainda manda clonar em
   `/opt/monorepo`, que não existe.
9. **Deploy roda numa máquina só** (a de build). Se ela cair, produção trava —
   o roteiro de emergência é o `docs/vps/deploy-readiness.md`, hoje obsoleto.
10. **Tags de imagem se acumulam** na VPS — cada deploy deixa a sua, sem
    política de limpeza.
11. **Secrets no chat são redigidos** pelo filtro do Hermes — comandos de
    deploy com secrets trafegam por arquivo, nunca inline no chat.
12. **`ops_centro` responde 503** em produção por 4 variáveis ausentes do env
    da VPS (#987).
13. **O CI está desligado e o processo não absorveu isso** — os workflows estão
    `disabled_manually` por decisão (#78). "Os gates de PR protegem a `main`"
    deixou de ser verdade no dia em que foram desligados, e nada no processo
    mudou. O `deploy-local.sh` segue consultando um veredito que não existe e
    lê verde **por vácuo** (§3.1).
14. **Nada protege a `main`** — sem CI, sem proteção de ramo (o repositório é
    privado e a conta não é GitHub Pro, HTTP 403) e sem gate de merge. A única
    barreira é a revisão manual do dono.
15. **`brain_web` destrói o próprio banco de auth a cada deploy** (#1029). O
    serviço foi projetado para Neon, mas `AUTH_DATABASE_URL` está vazia no env
    publicado, então ele cai em `AUTH_SQLITE_PATH=/data/auth.db` — e o serviço
    **não tem volume nenhum** (`Mounts: []`). O arquivo nasce no start do
    container e morre na recriação seguinte; já foram 10 tags de imagem no
    disco, ou seja 10 bancos descartados. Hoje as 9 tabelas do Better Auth
    estão com zero linhas, então o defeito ainda não destruiu dado de terceiro
    — mas destrói o primeiro usuário que se registrar. **É o único item desta
    lista que pode causar perda de dado de usuário: tratar antes dos outros.**

## 10. Referências

- Monorepo: `docs/deploy-local.md` (o pipeline de entrega — o documento vivo),
  `infra/vps/README.md`, `infra/services.yml` (o manifesto),
  `infra/vps/Caddyfile`, `scripts/ci/deploy-local.sh`, `infra/vps/deploy.sh`.
- Procedimentos irmãos: `producao-de-codigo/pipeline-issues-fases.md`
  (issues → specs → agentes → verificação → PR) e
  `producao-de-codigo/fila-watchdog-cron.md` (orquestração da fila).
- Issues citadas: #1023, #1024, #1021, #1020, #1019, #1015, #1014, #994, #987,
  #873, #78.
- **Obsoletos — não consultar**: `docs/staging.md`, `docs/deploy-staging.md`,
  `docs/vps/deploy-readiness.md` (no monorepo). Os dois primeiros descrevem
  staging em Cloud Run e apontam para o terceiro, que descreve Cloud Run
  também.