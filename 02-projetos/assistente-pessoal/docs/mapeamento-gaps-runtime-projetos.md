# Mapeamento de Gaps — Runtime Compartilhado × Projetos Ativos

> **Data:** 2026-09-08
> **Autor:** Hermes (Lucas Cid)
> **Contexto:** Sales Coach AI (Cruzeiro do Sul), SENAC e Cladtek rodam sobre o
> mesmo esqueleto — `blu_agno_runtime` + libs `blu_*` + `tool_pool_api`. Este
> documento mapeia o que **já existe** no ecossistema e o que **efetivamente
> falta** construir para cada projeto. Revisa a primeira análise de gaps (que
> não considerava blu_parsers, tool_pool e blu_google_suite_client).

---

## 1. Inventário do ecossistema (o que já existe)

### 1.1 `blu_agno_runtime` (lib — merged na main 08/09 via #756-758)
- `AgentRegistry` + `ModeConfig` — modos de agente por slug (fallback default)
- `factory.build_agent()` — Agno Agent stateless, multi-tenant, tier de modelo
- `mcp/server.py` — FastMCP **embutido** no mesmo FastAPI (`mount_mcp`)
- `mcp/connection.py` — MCP **cliente** p/ servidores externos
- `auth/` — AuthGate, Principal, identity por token (F-20/ADR-05)
- `control/plane.py` — quota, auditoria `api_events`, provisionamento
- `storage/tenant.py` — sessão persistente com PK tenant+session
- `tools/` — `vector_search` (Cohere+pgvector), `audio_transcription` (Groq),
  `ocr` (pytesseract), `document_parse` (pymupdf/python-docx)

### 1.2 `blu_parsers` (lib)
- Parsers: PDF (smart + docling fallback), DOCX, XLSX, PPTX, CSV (labeled p/ LLM),
  TSV, JSON, XML/HTML, TXT (+ fontes de código)
- `ParserRouter` — roteio por extensão
- `pipeline.parse_and_chunk()` — parse + chunk semântico em 1 passo
- **Consumido por:** tool_pool_api, agents_api, backend_api

### 1.3 `tool_pool_api` (serviço — 76 tools MCP em 21 módulos)
| Módulo | Tools-chave |
|---|---|
| google (15) | `google_docs_create/read/write/list`, `export_to_sheet`, `create_spreadsheet_with_data`, `write_to_sheet`, `read_emails`, calendar |
| whatsapp (3) | `send_whatsapp_message`, `send_whatsapp_batch`, `check_whatsapp_status` |
| document_intelligence (3) | `extract_structured_data`, `compile_time_series`, `write_summary_to_kb` |
| rag (1) | `executar_rag_cliente` |
| sql (2) | `execute_sql`, `executar_sql_agent` |
| report (2) | `generate_report`, `list_report_templates` |
| context (7) | `register_transaction`, `query_data_catalog`, `update_context_document`, `get_knowledge_status` |
| config_helper (5) | `peek_csv_columns`, `get_agent_requirements`, `check_config_completeness` |
| common/communication | `route_to_specialist`, `send_message`, `parse_business_reply` |
| + asana/linear/monday/notion/slack/web_crawl/web_monitor/fiscal/chart/platform/routines | ferramentas de integração |

### 1.4 Libs de apoio
- `blu_prompt_management` — `build_prompt()` (Langfuse + fallback builtin)
- `blu_google_suite_client` — Google Docs API (create/append/replace/list)
- `blu_twilio_client` — client + webhook validator (signature + TwiML + parse)
- `blu_rag_factory` — retriever + reranker (Cohere) + pipeline Supabase pgvector
- `blu_llm_service` — ROUTING_CHAIN (DeepSeek Flash/Pro, Claude), Cohere embed, Groq ASR
- `blu_sql_factory`, `blu_auth`, `blu_lgpd`, `blu_tool_registry`, `blu_context_service`

---

## 2. Como tudo se integra

```
┌─ CLIENTE (Sales Coach / SENAC / Cladtek) ─────────────────────────────┐
│ 1 imagem FastAPI                                                      │
│   ├─ blu_agno_runtime.build_agent() → Agno Agent                     │
│   ├─ FastMCP EMBUTIDO (tools próprias do domínio)                     │
│   └─ MCP CLIENTE → tool_pool_api (mcp_connection)                    │
│                                                                       │
│   blu_parsers (ingestão local) → blu_rag_factory → pgvector          │
│   blu_twilio_client (webhook + envio WhatsApp)                        │
│   blu_prompt_management (prompts Langfuse em runtime)                 │
└───────────────────────────────────────────────────────────────────────┘
```

**Padrão já provado:** `assistente_api` expõe tools financeiras via FastMCP
embutido (per-request, presas ao tenant) e delega ao tool_pool via MCP —
exatamente o desenho previsto para o Sales Coach.

---

## 3. Gaps revisados por projeto

### 3.1 Sales Coach AI (Cruzeiro do Sul) — prazo 30/09
| # | Item | Veredito | Evidência |
|---|---|---|---|
| S1 | Tools de domínio de vendas | 🔴 **GAP REAL** | `entrevista_tool`, `scoring_tool`, `cenario_tool`, `simular_prospect`, `feedback_tool`, `sugerir`, `relatorio_tool` — específicas do serviço sales-coach-api |
| S2 | Router de intenção (modos) | 🟡 Parcial | `route_to_specialist` existe no tool_pool; o router assessment/roleplay/consultor/menu é do domínio do serviço |
| S3 | Fluxo relatório → link → WhatsApp | 🟡 Integração | `google_docs_create` + `send_whatsapp_message` existem; falta o fluxo orquestrado |
| S4 | Painel web liderança (React) | 🔴 **GAP REAL** | `/`, `/vendedor/:id`, `/polo/:id`, `/unidade/:id`, `/curso/:id` — frontend do zero |
| — | Parsing, prompts, Twilio, RAG, OCR, áudio, auth | ✅ Coberto | libs acima |

### 3.2 SENAC — 24 semanas
| # | Item | Veredito | Evidência |
|---|---|---|---|
| N1 | Fluxo geração relatório formato oficial | 🟡 Parcial | Docs API existe; falta template oficial (introdução+5 capítulos) + orquestração por aluno |
| N2 | Dashboard agregado | 🔴 **GAP REAL** | frontend do zero |
| N3 | LGPD (retenção/consentimento) | 🟡 Integrar | `blu_lgpd` existe como lib; precisa ser aplicada ao fluxo |
| — | Parsing SAVE (CSV/XLSX), RAG, Q&A, auth | ✅ Coberto | `blu_parsers` CSV/XLSX/TSV + `vector_search` |

### 3.3 Cladtek — 24 semanas
| # | Item | Veredito | Evidência |
|---|---|---|---|
| C1 | Leitura CAD SolidWorks/PDL nativo | 🔴 **GAP REAL** | nada no monorepo lê CAD — único gap técnico sem lib |
| C2 | Extração de cotas/tolerâncias de desenho | 🔴 **GAP REAL** | depende do parser CAD (C1) |
| C3 | Sandbox de validação humana | 🔴 **GAP REAL** | frontend/workflow do zero |
| — | PDF, OCR, RAG parâmetros, auth | ✅ Coberto | `document_parse`, `ocr`, `vector_search`, AuthGate |

---

## 4. Gaps consolidados (o que sobra de verdade)

1. **Tools de domínio por cliente** — código novo no serviço de cada cliente
   (vendas para Sales Coach, pedagógicas para SENAC, CAD para Cladtek)
2. **Leitura CAD/SolidWorks** — o único gap técnico sem lib existente (Cladtek)
3. **Frontends** — painel Sales Coach, dashboard SENAC, sandbox Cladtek
4. **Fluxos de geração de relatório** — orquestração nova sobre tools existentes
5. **Duplicação `document_parse` vs `blu_parsers`** — decisão documentada no
   pyproject do runtime; vale revisitar para unificar (issue tech-debt)

---

## 5. Issues abertas a partir deste mapeamento

| Issue | Título | Projeto | Tipo |
|---|---|---|---|
| [#759](https://github.com/CidLucas/monorepo/issues/759) | sales-coach: tools de domínio dos 4 modos | Sales Coach | enhancement |
| [#760](https://github.com/CidLucas/monorepo/issues/760) | sales-coach: fluxo relatório → link → WhatsApp e router de intenção | Sales Coach | enhancement |
| [#761](https://github.com/CidLucas/monorepo/issues/761) | blu_parsers: leitura de CAD (SolidWorks/PDL) | Cladtek | enhancement |
| [#762](https://github.com/CidLucas/monorepo/issues/762) | blu_agno_runtime: unificar document_parse com blu_parsers | Runtime | tech-debt |
| [#763](https://github.com/CidLucas/monorepo/issues/763) | sales-coach-web: painel da liderança | Sales Coach | enhancement |
| [#764](https://github.com/CidLucas/monorepo/issues/764) | senac: fluxo de geração de relatório pedagógico editável | SENAC | enhancement |
| [#765](https://github.com/CidLucas/monorepo/issues/765) | cladtek-web: sandbox de validação humana + dashboard | Cladtek | enhancement |

---

## 📅 Histórico

| Data | Atualização |
|---|---|
| 2026-09-08 | Criação — mapeamento revisado pós-merge do runtime (#756-758) |
