# Status — Cruzeiro do Sul (Sales Coach AI)

> Última atualização: 2026-09-08
> **Cliente:** Cruzeiro do Sul
> **Produto:** Sales Coach AI — agente de coaching/assessment de vendas
> **Lucas:** responsável técnico

> ✅ **PROJETO ATIVO (decisão do dono, 08/09/2026).** Rodando sobre o **blu_agno_runtime** do monorepo (mesma base dos projetos SENAC e Cladtek).

## 🩺 Saúde geral

🟡 **Em definição** — produto identificado (Sales Coach AI), mas escopo/requisitos detalhados ainda não estruturados neste repo.

## 🔗 Origem do padrão técnico

O Sales Coach foi o **cliente original** do padrão de modos de agente que hoje vive no `blu_agno_runtime`:
- `AgentRegistry` + `ModeConfig` (issue #752) generalizaram o registro de modos que o SalesCoach usava
- Modo "coach" de vendas é o exemplo canônico nos testes (`test_registry.py`: slug `sales_coach`, prompt `sales_coach_prompt`, skill_tools `crm_lookup`/`playbook_search`)
- O scaffold `bootstrap-agent-client.py` (#755) nasceu para criar clientes como este em minutos

## 📊 Resumo executivo

| Item | Status |
|---|---|
| Contrato | 🟡 a documentar |
| Escopo / PRD | 🔴 não criado neste repo |
| Modos de agente (coach/assessment) | 🟢 padrão pronto no runtime |
| Data de kickoff (D+0) | 🟡 a definir |
| Stack escolhida | 🟢 blu_agno_runtime (Agno) — compartilhado |

## 📝 Pendências

- [ ] **Lucas** — detalhar escopo/requisitos do Sales Coach AI (fluxo de coaching, personas, integrações CRM)
- [ ] **Hermes** — criar PRD + ROADMAP assim que os requisitos chegarem

## 📅 Histórico de atualizações

| Data | Atualização |
|---|---|
| 2026-09-08 | Criação do projeto. Identificado como **Sales Coach AI**. Ativo — runtime compartilhado com SENAC e Cladtek. |
