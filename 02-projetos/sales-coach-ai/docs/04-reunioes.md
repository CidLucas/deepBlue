# 04 — Reuniões e Decisões — Sales Coach AI

> Log cronológico reverso. Cada entrada: data → participantes → resumo → decisões.

---

## 2026-09-03 — Sessão 2: Definição de arquitetura unificada (Lucas + Hermes PM)

**Participantes:** Lucas Cid, Hermes PM

**Resumo:**
- Discutida a arquitetura ideal: ao invés de 4 agentes separados + orchestrator,
  decidimos por **1 runtime com N modos carregados em runtime**
- Inspirado no `AgentTypeRegistry` do `blu_agent_framework` — um catálogo de
  modos (assessment, roleplay, consultor, analytics) que define prompt_name,
  skill_tools, model_tier e max_turns para cada modo
- **Prompts carregados da Langfuse** em runtime via `blu_prompt_management.build_prompt()`
  — sem prompts hardcoded, ajustáveis sem deploy
- O runtime é 1 única imagem Docker (FastAPI + Agno), recriando o Agent por request
  com sessão persistente no `TenantPostgresDb`
- Inspecionado `blu_agent_framework.registry` (AgentTypeRegistry, ~12 agent types)
  e `blu_prompt_management` (Langfuse-first, builtin fallback) — ambos maduros
- Router leve baseado em LLM (1 chamada) para classificar intenção e selecionar modo

**Decisões:**
| # | Decisão | Status |
|---|---------|--------|
| 5 | **Arquitetura: 1 Docker image + SalesCoachRegistry** (não 4 agentes separados) | ✅ Confirmada |
| 6 | **Prompts carregados da Langfuse** via `blu_prompt_management.build_prompt()` | ✅ Confirmada |
| 7 | **Router** como intent classifier leve (LLM 1 chamada), não agente separado | ✅ Confirmada |
| 8 | **blu_agno_runtime.factory.build_agent()** como base do Agent Factory | ✅ Confirmada |
| 9 | Reuso do padrão `agente-bloquo` (VectorSearchTool, run_agent, structure) | ✅ Confirmada |

**Documentos atualizados:**
- PRD.md — reescrito com conceito de modos (v0.2)
- 02-arquitetura.md — reescrita com diagrama, SalesCoachRegistry, pipeline de prompts (v0.2)
- ROADMAP.md — fases renomeadas para refletir modos + setup Langfuse
- STATUS.md — stack atualizada para 🟢

**Próximos passos:**
- [ ] Validar PRD v0.2 + arquitetura v0.2
- [ ] Definir repo de código (monorepo vs separado)
- [ ] Data do pré-kickoff interno com TEMPLO
- [ ] Design system: Blu DS vs brandbook TEMPLO

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