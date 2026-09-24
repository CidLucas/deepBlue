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
| **Deploy** | [ambientes-deploy.md](./deploy/ambientes-deploy.md) — princípio, acordos de desenvolvimento, mapa dos ambientes (VPS única: produção + staging), isolamento de dados, verificação e vícios medidos · [plano-versao-estavel.md](./deploy/plano-versao-estavel.md) · [prompt-execucao-nova-sessao.md](./deploy/prompt-execucao-nova-sessao.md) · [migracao-primeclaws/](./deploy/migracao-primeclaws/) | ✅ Vigente (reescrito 24/09 — mundo VPS) |
| **Memória e agentes** | *(a criar)* — Mnemosyne, skills, profiles | ⏳ |
| **Operações** | *(a criar)* — crons, watchdog, manutenção | ⏳ |

## Como criar/editar um procedimento

1. Crie a pasta em `01-procedimentos/<área>/`.
2. Escreva o `.md` com: **objetivo, passos numerados, comandos exatos, pitfalls,
   verificação** (padrão dos procedimentos Hermes).
3. Versionado no git — todo agente consulta daqui.
4. Atualize este índice.
