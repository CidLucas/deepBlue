# Migração Hermes → VPS — Análise runtime vs durável + decisões

> **Decisões do dono (24/08/2026):**
> 1. **Silent Updates: SIM** — versão do Hermes NÃO pinada; updates automáticos do provedor ok.
> 2. **Datacenter/latência: descartado** — latência de modelo já domina; não é fator de decisão.
> 3. Provedor em análise: **PrimeClaws Pro VPS ($19.99/mo)** vs DigitalOcean (ver tabela abaixo).

## O que é RUNTIME (regenerável — NÃO migra)

| Item | Tamanho | Por quê não migra |
|---|---|---|
| `~/.hermes/hermes-agent/` | 2.2GB | A instalação do Hermes. Com Silent Updates, o provedor instala/atualiza. Reinstalar = versão nova. |
| `~/.hermes/state.db` | 407MB | Histórico de sessões/mensagens (o DB que o `session_search` lê). Regenera sozinho; perder = perde busca de sessões antigas, nada crítico. *(opcional: migrar via backup sqlite)* |
| `~/.hermes/node/`, `~/.hermes/bin/`, `~/.hermes/cache/` | ~244MB | Node embutido, binários e cache — reinstalar/regenerar. |
| `~/.hermes/runtime/` | — | Sessões ativas em memória. |
| `.venv` do monorepo | ~2-3GB | Reconstruir na VPS com `uv sync --all-packages` (regra #377). |
| `~/worktrees/` | pequeno | Re-criar via `git worktree add`; branches estão no origin. |

## O que é DURÁVEL (dado — MIGRA ✅) — ~1.5GB total

| Item | Tamanho | Conteúdo |
|---|---|---|
| `~/.hermes/config.yaml` | K | Config raiz do profile default |
| `~/.hermes/profiles/` | 769MB | **10 profiles** (default, pm, design-writer, sales, experiment-*, triage-*...) — cada um com `config.yaml` (**tokens dos bots!**), skills, memories, state |
| `~/.hermes/skills/` | 99MB | Skills globais |
| `~/.hermes/scripts/` | — | Scripts custom: dispatchers, watchdog da fila, guards, preflight |
| `~/.hermes/state/` | ~100KB | **Queues do pipeline** (`assistente_queue.json` e afins) + `landing-webhook-secret` + snapshots |
| `~/.hermes/cron/` | — | Definições dos 25+ cron jobs + outputs |
| `~/.hermes/mnemosyne/` | 46MB | **Memórias duráveis** (Mnemosyne) |
| `~/.aws`, `~/.cloudflare`, `~/.ssh`, `~/.claude`, `~/.config/opencode`, `~/.brevo`, `~/.oci` | — | Credenciais (Claude Code login! opencode tokens!) |
| `~/.local/` | — | Binários `uv`, `claude`, `opencode` (ou reinstalar) |
| `~/linkedin-callback/` | — | Mini-endpoint OAuth do LinkedIn |
| `~/projetos-docs`, `~/projetos-repo` | 12MB | Clones git (podem ser re-clonados) |
| `~/monorepo` | — | **NÃO rsync: clone fresco** (todas as branches pushadas ✅ incl. design/kanban-6-colunas) |

## Comparativo de provedores (tier 4vCPU/8GB)

| | AWS t3.medium (atual) | PrimeClaws Pro | DO Basic s-4vcpu-8gb | DO Premium amd |
|---|---|---|---|---|
| Preço/mês | ~$40-45 (2vCPU/3.8GB/25GB) | **$19.99** | $48 | $56 |
| Gerenciado | não | sim (+silent updates) | não | não |
| Modelos inclusos | não | sim (limitado) | não | não |
| Região BR | sim | ? | não | não |
| Transfer | egress pago | ? | 5000GB | 5000GB |
| SLA/maturidade | alto | baixo (jovem) | alto | alto |

**Veredito:** PrimeClaws Pro = melhor custo (2.4x mais barato que DO no mesmo tier). DO = plano B maduro (SLA, regiões, ecossistema) se a confiança no provedor novo pesar mais.

## Uso dos scripts (ordem)

```bash
# 1. NA EC2 — backup do durável + manifest
bash ~/migracao-primeclaws/scripts/01-backup-duravel.sh

# 2. NA VPS nova — bootstrap base (git, gh, tailscale, uv...) + tailscale up/funnel
bash migracao/scripts/02-vps-bootstrap.sh

# 3. NA VPS nova — restaura durável + clone monorepo + units systemd + valida
bash migracao/scripts/03-restore-vps.sh
```

> Scripts agnósticos de provedor: funcionam em PrimeClaws, DO ou qualquer VPS com SSH+sudo.
