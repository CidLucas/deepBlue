# 🧭 Procedimentos — Deep Blue

> Padrões operacionais por área. **Consultáveis, editáveis, versionados.**
> Se um agente/skill precisar de um procedimento, referencia daqui (fonte de
> verdade) em vez de duplicar.

| Área | Procedimento | Status |
|---|---|---|
| **Produção de código** | [pipeline-issues-fases.md](./producao-de-codigo/pipeline-issues-fases.md) — issues → specs → agentes → verificação → PR | ✅ Vigente (validado F0) |
| **Conteúdo LinkedIn** | [procedimento.md](./conteudo-linkedin/procedimento.md) | 📝 Esqueleto (a refinar) |
| **Rotinas** | [rotinas/](./rotinas/) — rotinas diárias, cadência de conteúdo, **inventário de crons** | 📝 Proposta |
| **Gerência de projetos** | *(a criar)* — ADRs, decisions, status de projeto | ⏳ |
| **Deploy** | [ambientes-deploy.md](./deploy/ambientes-deploy.md) — mapa dos ambientes, processos, verificação e vícios medidos (GCP Cloud Run prod/staging, AWS blu-web + memory_api, brand-hub/brain-web, local) · [plano-versao-estavel.md](./deploy/plano-versao-estavel.md) · [prompt-execucao-nova-sessao.md](./deploy/prompt-execucao-nova-sessao.md) · [migracao-primeclaws/](./deploy/migracao-primeclaws/) | ✅ Vigente (baseline 28/08, 1º deploy de staging verde) |
| **Memória e agentes** | *(a criar)* — Mnemosyne, skills, profiles | ⏳ |
| **Operações** | *(a criar)* — crons, watchdog, manutenção | ⏳ |

## Como criar/editar um procedimento

1. Crie a pasta em `01-procedimentos/<área>/`.
2. Escreva o `.md` com: **objetivo, passos numerados, comandos exatos, pitfalls,
   verificação** (padrão dos procedimentos Hermes).
3. Versionado no git — todo agente consulta daqui.
4. Atualize este índice.
