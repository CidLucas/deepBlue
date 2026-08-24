# Checklist — Migração Hermes: AWS EC2 → PrimeClaws Pro VPS

> **Estado de referência:** 24/08/2026 · Instância atual = t3.medium-ish (2 vCPU / 3.8GB RAM / 25GB SSD a 84%)
> **Alvo recomendado:** Pro Claws VPS — $19.99/mo (4 vCPU / 8GB RAM / 100GB SSD) · SSH total · systemd/tailscale OK
> **Volume a migrar:** ~6.5GB (`~/.hermes` 3.9GB + `~/monorepo` 2.0GB + projetos + creds)

---

## 0. Decisões (fechadas 24/08)

- [x] **Silent Updates: SIM** — versão do Hermes NÃO pinada; updates automáticos do provedor são desejados (não bloquear)
- [x] **Datacenter/latência: descartado** — latência de modelo domina; não é fator
- [ ] **Sudo de verdade**: confirmar que o plano VPS permite `sudo` (Tailscale Funnel exige)
- [ ] **Tráfego de saída**: confirmar ilimitado/adequado (bots polling + webhooks; volume baixo)
- [ ] Migração via SSH (rsync) liberada
- [ ] Provedor: **PrimeClaws Pro $19.99** (mantido após comparar DO — ver README §comparativo; DO 4vCPU/8GB = $48-56, plano B se a confiança pesar)

---

## 1. Preparação na EC2 (antes de contratar)

- [ ] **Snapshot AMI** da EC2 (rollback) — console AWS ou via Mac
- [ ] Backup consistente do `~/.hermes/state.db` (407MB SQLite): parar gateways OU `sqlite3 state.db ".backup /tmp/state.db.bak"`
- [ ] Anotar inventário para comparação pós-migração:
  - `hermes cron list` (25+ jobs) → salvar saída em arquivo
  - `systemctl --user list-units --type=service` (units hermes-*)
  - `ss -tlnp` (portas: 8644 webhook, 8642, 9119 dashboard, 12345, 33925, 5433 ⚠️identificar)
  - `tailscale status` + `tailscale funnel status` (URLs atuais)
- [ ] **Congelar o pipeline**: pausar cron `assistente-pessoal-fila` (ebf8c83441e4) e deixar o worker atual (wk-339/341) terminar OU abortar com segurança
- [ ] Anotar WIP do monorepo: branch `design/kanban-6-colunas` (c5722fc, NÃO mergeada) + worktrees `wk-339`, `wk-341`
- [ ] Testar conectividade SSH EC2→VPS (precisa da VPS pronta) ou usar tar+transferência

---

## 2. Provisionar a VPS (PrimeClaws)

- [ ] Contratar **Pro Claws VPS** ($19.99/mo) — NÃO o tier Docker (terminal web não serve: precisamos de tailscale/systemd/root)
- [ ] Primeiro acesso: trocar senha, subir **chave SSH** (reusar `~/.ssh/id_ed25519_*` da EC2 ou gerar nova)
- [ ] Hardening básico: `fail2ban` opcional, `ufw` se quiser (portas: 22, 8644, 9119, funnel)
- [ ] Instalar ferramentas base: `git`, `curl`, `rsync`, `sqlite3`, `jq`
  - `uv`, `claude`, `opencode` migram via `~/.local` (binários) — verificar libs (`ldd`)
  - `node/npm` migram via `~/.hermes/node`
  - `gh` — reinstalar (`apt`/`snap`/binário) e re-autenticar (`gh auth login`)
  - `tailscale` — instalar + `tailscale up`
- [ ] Verificar: `free -m` (8GB), `df -h /` (100GB), `nproc` (4)

---

## 3. Migrar dados (durável APENAS — análise completa no README)

> **RUNTIME não migra:** `hermes-agent/` (2.2GB, provedor reinstala), `state.db` (407MB, regenerável — opcional `--full`), `node/`/`bin/`/`cache/`, `.venv` (reconstruir).
> **~1.5GB total.** Scripts prontos: `scripts/01-backup-duravel.sh` (EC2) → `02-vps-bootstrap.sh` → `03-restore-vps.sh` (VPS).

- [ ] Rodar `01-backup-duravel.sh` na EC2 → `~/migracao-primeclaws/backup-<ts>.tar.gz` + MANIFEST.txt
- [ ] Transferir tar p/ VPS: `scp ec2-user@<ec2>:~/migracao-primeclaws/backup-*.tar.gz ~/migracao/`
- [ ] Rodar `02-vps-bootstrap.sh` (base tools, gh, uv, tailscale up — seguir link de autorização)
- [ ] Rodar `03-restore-vps.sh` (creds, ~/.hermes durável, clone monorepo, uv sync, units)
- [ ] **Monorepo = clone fresco** (NÃO rsync): todas as branches já estão no origin ✅ (incl. design/kanban-6-colunas, verificado 24/08)
- [ ] **state.db**: pular (regenerável) ou migrar com gateways parados (sqlite .backup)
- [ ] **Units systemd**: copiadas do backup como referência — **REVISAR ExecStart** (venv do provedor ≠ /home/ec2-user/.hermes/hermes-agent/venv)
- [ ] Verificar creds após cópia: `chmod 600 ~/.ssh/id_*`, tokens dos bots em `profiles/*/config.yaml` intactos

---

## 4. Replicar infraestrutura (systemd + rede)

- [ ] Copiar units: `~/.config/systemd/user/hermes-gateway{,-pm,-design-writer,-sales}.service` + `hermes-dashboard.service` + `hermes-dashboard-tunnel.service`
  - Ajustar se o usuário/caminho mudar (`HERMES_HOME`, `VIRTUAL_ENV`)
  - `systemctl --user daemon-reload` + `enable --now` cada unit
- [ ] **Tailscale**: `sudo tailscale up` (autorizar no tailnet) → **NOVO IP/hostname** (`100.x.x.x` novo)
- [ ] **Funnel**: `sudo tailscale funnel 8644` (ou porta do webhook) — habilitação manual 1x
  - Reconfigurar portas: 8644 (webhook API), 8642, 9119 (dashboard), linkedin-callback (8645), 5433 (identificar o que é antes!)
- [ ] **Dashboard tunnel EC2→Mac** (`hermes-dashboard-tunnel.service`): depende do Mac (100.94.50.55) — testar; key `~/.ssh/id_ed25519_mac_access` migra junto

---

## 5. Dependências externas — o que MUDA de endereço ⚠️

| Dependência | Endereço atual | Ação |
|---|---|---|
| Tailscale Funnel URL (webhook landing-leads) | `https://ip-172-31-41-24.tail2af056.ts.net/...` | **NOVO hostname** → atualizar no **brand-hub-worker (Cloudflare)** (relay de leads) |
| LinkedIn OAuth redirect URI | `https://ip-172-31-41-24.tail2af056.ts.net/callback` | **Atualizar no app do LinkedIn** (developer console) |
| Webhook landing-leads (HMAC secret) | no `~/.hermes` (migra) | rota + secret migram; validar com POST de teste |
| Domínios (deepblue.company, formly.ink, mcp-brain.com, bluapp.ink) | Cloudflare → Cloud Run/Workers | **sem mudança** (não passam pela EC2) |
| Crons duckdns (`duckdns-ip-update`) | atualiza formly/lucascid | formly agora é Cloud Run → **avaliar desativar** na VPS |

---

## 6. Validação por serviço (gate por gate)

1. [ ] **Base**: SSH, `uv --version`, `node --version`, `gh auth status`, `claude` login, `opencode` OK
2. [ ] **Tailscale + Funnel**: `curl -k https://<novo-hostname>.ts.net/` responde; rota no CF atualizada
3. [ ] **Gateways (4)**: `systemctl --user status hermes-gateway*` → todos `active`; **cada bot responde no Telegram** (ping: @falanego_bot, @IssueMaker_bot, @ReviewerOfCode_bot, default)
4. [ ] **Crons**: `hermes cron list` == inventário salvo na Fase 1; tick manual de 2 crons (memory-guard, duckdns) entrega
5. [ ] **Webhooks**: POST de teste p/ landing-leads com HMAC → chega no Telegram
6. [ ] **Mnemosyne**: `mnemosyne_stats` + 1 recall funcionando
7. [ ] **Monorepo**: `git status` (design/kanban-6-colunas ok), worktrees listados, `uv sync --all-packages` + `pytest libs/blu_llm_service/tests/test_catalog_sync.py` verde
8. [ ] **Pipeline**: `hermes cron resume assistente-pessoal-fila` → 1 dispatch de teste; worker roda e verifica
9. [ ] **Dashboard**: acessar via Mac (tunnel reverso) — porta 9119 respondendo

---

## 7. Cutover & rollback

- [ ] **Janela de cutover**: parar gateways na EC2 (`systemctl --user stop hermes-gateway* hermes-dashboard*`)
- [ ] **Overlap 7 dias**: EC2 ligada mas inativa (rollback = religar gateways + voltar Funnel/CF/API LinkedIn p/ hostname antigo)
- [ ] Após validação completa: desligar EC2, **snapshot final**, remover recursos (opcional)
- [ ] **Rollback**: religar EC2 + `systemctl --user start hermes-gateway*` — DNS/CF apontam de volta (guardar hostname antigo até o fim do overlap)

---

## 8. Riscos & pendências abertas

- [ ] **"Silent updates"** do provedor podem quebrar pin de versão — exigir controle (Fase 0)
- [ ] **state.db 407MB**: copiar com gateway parado (consistência de sessões/mensagens)
- [ ] **Pipeline em andamento** (wk-339/341): congelar antes da janela; retomar na VPS
- [ ] **WIP de design** (design/kanban-6-colunas, não mergeado): conferência explícita pós-cópia
- [ ] **Provedor jovem** (Trustpilot 4.2, 11 reviews; sem SLA/DC publicados)
- [ ] **Porta 5433** na EC2: identificar o serviço antes de decidir migrar
- [ ] **gcloud NÃO existe na EC2** (deploys rodam no Mac) → nada a migrar; confirma-se que Cloud Run não depende desta máquina
- [ ] Crons de healthcheck apontando para a EC2 (ex.: hub-deepblue-live-check, formly-live-check pausados) — revisar alvo

---

## Estimativa de esforço

| Fase | Esforço |
|---|---|
| 0-1 Preparação | 1-2h |
| 2 Provisionar VPS | 1h (com espera de aprovisionamento) |
| 3 Migrar dados | 1-2h (rsync ~6.5GB) |
| 4-5 Infra + externos | 2-3h (tailscale/funnel/CF/LinkedIn) |
| 6 Validação | 2-3h (gate por gate) |
| 7 Cutover + overlap | 7 dias de observação |
