# Plano de Execução — Sales Coach AI (30 dias)

> **Versão:** 0.1 — 2026-09-03
> **Prazo:** 01/09 a 30/09/2026 (30 dias corridos)
> **Carga:** ~22 dias úteis de desenvolvimento

---

## 1. Stack Técnica

### Backend (FastAPI + Agno Agents)

```
Stack base:
  Python 3.12 · FastAPI · Supabase (auth + storage) · Agno (agentes)
  Twilio SDK · Groq Whisper (ASR) · DeepSeek Flash / Claude (LLMs)
  Neon Postgres (se Supabase transactions não bastarem) · Redis (filas)

Agentes:
  4 agentes especializados (assessment, roleplay, consultor, analytics)
  1 orchestrator que roteia entre eles
  Estado persistente via Supabase + Redis
```

### Frontend (Vite + React 18 + Blu DS)

```
Vite + React 18 + TypeScript
Blu DS (CSS tokens — padrão Deep Blue) ou brandbook TEMPLO
Zustand + React Query + Phosphor Icons
Chart.js / Recharts (painel de métricas)
Integração Teams via Deep Link / Adaptive Cards (fase tardia)
```

### Infra (TEMPLO)

```
Cloud Run (GCP) ou VPS
Twilio WhatsApp Business API
Supabase (auth + banco + storage)
Redis (cache + filas + sessão)
```

---

## 2. Libs do Monorepo a Reutilizar

| Lib | Uso no Sales Coach | Status |
|-----|--------------------|--------|
| `blu_twilio_client` | Comunicação WhatsApp (enviar/receber msg, webhook) | ✅ Pronta — 20KB de client.py + webhook.py, já mede custo |
| `blu_llm_service` | LLM routing (DeepSeek Flash para assessment, Claude para roleplay), **ASR Groq Whisper** para transcrição de áudio | ✅ Pronta — suporta múltiplos providers, fallback, Langfuse |
| `blu_agent_framework` | Orquestração multiagente com Layer 4 orchestrator, nodes, routing, MCP tools | ✅ Pronta — tem orchestrator.py, builder.py, registry |
| `blu_auth` | JWT/OAuth2, autenticação por token, FastAPI middlewares | ✅ Pronta |
| `blu_supabase_client` | Conexão Supabase, RLS, storage para arquivos | ✅ Pronta |
| `blu_rag_factory` | Base de dados semântica a partir dos docs da Cruzeiro (se usar RAG híbrido) | ⚠️ Verificar se atende ao caso |
| `blu_parsers` | Parsing de documentos (portfólio acadêmico, roteiros) | ✅ Pronta |
| `blu_payments` / `blu_finops` | Futuro (produto de prateleira) | 🔴 Não necessária agora |
| `blu_google_suite_client` | Se precisar de Sheets/Docs na operação | ⚠️ Provisório |
| `blu_context_service` | Gerenciamento de contexto entre agentes | ⚠️ Verificar aderência |

**Total de reuso estimado:** 60-70% do backend já existe como libs — o que reduz
drasticamente o tempo de construção vs. escrever do zero.

---

## 3. Timeline Detalhada (30 dias)

### Semana 1 — Setup + Assessment (01–07 set)

| Dia | O que | Entregável |
|-----|-------|------------|
| D01 | Setup do monorepo: service scaffold, configs, CI/CD | `services/sales-coach-api/` no monorepo |
| D02 | Integração Twilio WhatsApp + webhook + ASR (áudio) | Conversa funcional via WhatsApp |
| D03 | Base semântica: ingestão dos docs da Cruzeiro + chunking | Base vetorial populada |
| D04 | Agente Assessment V1: entrevista conversacional ~20min | Fluxo de perguntas → respostas |
| D05 | Avaliação: scoring por eixo (conhecimento, consultiva, orientação) | Score por vendedor |
| D06 | Relatório individual + envio via WhatsApp (PDF/link) | Relatório funcional |
| D07 | **Buffer / revisão** | Assessment funcional ponta-a-ponta |

### Semana 2 — Roleplay + Consultor (08–14 set)

| Dia | O que | Entregável |
|-----|-------|------------|
| D08 | Agente Roleplay: diagnóstico → geração de cenário único | Cenário gerado a partir do assessment |
| D09 | Simulação: fluxo de diálogo com prospect simulado | Conversa funcional |
| D10 | Feedback estruturado: técnica, escuta, fechamento | Relatório de feedback |
| D11 | Agente Consultor: receber áudio/foto/texto via WhatsApp | Canais de entrada funcionais |
| D12 | Consultor: análise do atendimento real → sugestões | Argumento, contra-objeção, oferta |
| D13 | Integration: consultor como overlay do assessment/roleplay | 3 agentes conversando entre si |
| D14 | **Buffer / revisão** | Roleplay + Consultor funcionando |

### Semana 3 — Painel + Integração + Entrega (15–30 set)

| Dia | O que | Entregável |
|-----|-------|------------|
| D15–17 | Painel de liderança: API de analytics + dashboard | Métricas por vendedor, polo, unidade, curso |
| D18 | Agente Analytics: processamento das interações | Relatórios consolidados |
| D19 | Autenticação + login (painel e agentes) | Login funcional |
| D20 | Integração Teams (complementar) | Notificações / cards no Teams |
| D21–23 | Testes integrados + QA em ambiente TEMPLO | Tudo verde |
| D24 | Ajustes finos de modelo (prompts) + calibração | Prompts otimizados |
| D25 | **Buffer — folga para imprevistos** | — |
| D26–29 | Homologação com squad piloto + ajustes | Feedback do cliente |
| D30 | **Showcase + entrega** | Entrega oficial |

---

## 4. Arquitetura Multiagente

```
                     ┌──────────────────┐
                     │   WhatsApp/Twilio │  ← Áudio, foto, texto
                     └────────┬─────────┘
                              │ Webhook
                     ┌────────▼─────────┐
                     │  Sales Coach API  │  ← FastAPI + Supabase
                     │   (orchestrator)  │
                     └───┬────┬────┬────┘
                         │    │    │
              ┌──────────┘    │    └──────────┐
              ▼               ▼               ▼
     ┌────────────────┐ ┌──────────┐ ┌────────────────┐
     │ Agent Assessment│ │  Agent   │ │ Agent Consultor│
     │ (entrevista +  │ │ Roleplay │ │ (real-time +   │
     │  scoring)      │ │ (cenário │ │  sugestão)     │
     └────────────────┘ │  + feedb)│ └────────────────┘
                        └──────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                     ┌──────────────────┐
                     │ Agent Analytics  │  ← Processa interações → métricas
                     └────────┬─────────┘
                              │
                     ┌────────▼─────────┐
                     │   Painel Liderança│  ← Web + Teams
                     │  (React + Recharts)│
                     └──────────────────┘
```

## 5. Custos de IA (estimativa)

| Item | Estimativa | Fonte |
|------|-----------|-------|
| Claude Code 20x | USD 200 | TEMPLO (1 mês) |
| Tokens LLM (DeepSeek Flash + Claude) | USD 300–500 | Assessment largo, roleplay médio |
| Groq Whisper (ASR) | USD 50–100 | Áudio dos vendedores |
| Embeddings (base semântica) | USD 50 | Ingestão única |
| **Total estimado** | **USD 600–850** | Dentro do budget (até USD 1.000) |

---

## 6. Perguntas para Decidir Agora

1. **Repo:** O Sales Coach vai no monorepo (`services/sales-coach-api` + `apps/sales-coach-web`) ou repo separado?
2. **Agno vs. LangGraph:** O framework de agente usa `blu_agent_framework` (LangGraph) ou Agno puro? O `blu_agno_runtime` existe, mas o `blu_agent_framework` é LangGraph.
3. **Painel:** Web app standalone ou embutido no Teams como tab?
4. **Design system:** Blu DS (nosso padrão) ou brandbook do TEMPLO?