# Capabilities — O que a gente consegue fazer

**Ponto de vista:** capabilities são as **ferramentas técnicas** que temos no
monorepo para trabalhar para o cliente. Não são o produto final — são o que
nos permite criar o produto. Quando combinadas com o diagnóstico (consultoria),
viram serviço: plataformas, agentes, fluxos, assistentes, rotinas.

## O kit técnico (monorepo)

| Capability | O que faz | No monorepo |
|---|---|---|
| **Plataformas e produtos** | Cria plataforma completa: frontend, backend, autenticação, pagamentos | `apps/` (blu-web, formly-web), `blu_auth`, `blu_payments` |
| **Agentes e fluxos** | Cria agentes e fluxos de agentes integrados aos sistemas do cliente | `blu_agent_framework` (LangGraph 4 camadas), `agents_api`, `blu_tool_registry` |
| **Assistente com ferramentas** | Agente que navega, agenda no Google, cria documentos, responde por WhatsApp | `blu_google_suite_client` (Sheets/Gmail/Calendar), `blu_twilio_client`, `tool_pool_api` (MCP) |
| **Rotinas e automação** | Agenda tarefas repetitivas que rodam sozinhas e acessam agentes e tools | `routines_api` |
| **Monitoramento** | Central de observabilidade da operação do cliente | `ops_centro` |
| **Memória e dados** | Memória corporativa, busca semântica (RAG), conectores de dados | `memory_api`, `blu_rag_factory`, `blu_data_connectors`, `blu_db_connector`, `blu_supabase_client` |
| **Coleta e mapeamento** | Questionários, entrevistas, mapeamento de processo (em escala) | `formly-api`, `blu_elicitation_service` |

## Regras

1. Capability vira oferta quando **combina com o diagnóstico** — a proposta
   mostra a ferramenta do cliente, não o detalhe técnico nosso.
2. Um cliente pode ter 1 capability (ex: assistente) ou um combo (plataforma +
   agentes + rotinas). O diagnóstico decide.
3. Cada doc de capability segue o template (dor → camadas → entrega) e cita o
   kit técnico no header — para o time saber o que existe antes de prometer.
