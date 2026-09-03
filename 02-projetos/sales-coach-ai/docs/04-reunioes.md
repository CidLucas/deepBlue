# 04 — Reuniões e Decisões — Sales Coach AI

> Log cronológico reverso. Cada entrada: data → participantes → resumo → decisões.

---

## 2026-09-03 — Bootstrap + definição de stack (Lucas + Hermes PM)

**Participantes:** Lucas Cid, Hermes PM

**Resumo:**
- Recebido o e-mail de formalização do contrato TEMPLO × Cruzeiro do Sul (REV. 04)
- Criado o arcabouço documental do projeto (README, STATUS, 00-escopo, PLANO-EXECUCAO)
- Validada a stack: **Agno** (não LangGraph) como framework de agentes
- Inspecionado `blu_agno_runtime` (lib do monorepo) e `agente-bloquo` (projeto base)
- Mapeadas as libs de reuso: `blu_twilio_client`, `blu_llm_service`, `blu_auth`, `blu_supabase_client`
- Escrito PRD completo com requisitos dos 4 agentes + orchestrator

**Decisões:**
| # | Decisão | Status |
|---|---------|--------|
| 1 | Framework de agentes = **Agno 2.6+** (via `blu_agno_runtime`), não LangGraph | ✅ Confirmada |
| 2 | Reuso do padrão `agente-bloquo` (agent.py, run_agent, routes, schemas) | ✅ Confirmada |
| 3 | Stack: FastAPI + Supabase + Twilio + Groq Whisper + DeepSeek Flash/Claude | ✅ Confirmada |
| 4 | Painel: React + Vite + Blu DS + Recharts | ✅ Confirmada |

**Próximos passos:**
- [ ] Validar PRD com Lucas (4 agentes, skills, base vetorial)
- [ ] Definir repo de código (monorepo vs separado)
- [ ] Data do pré-kickoff interno com TEMPLO
- [ ] Design system: Blu DS vs brandbook TEMPLO
