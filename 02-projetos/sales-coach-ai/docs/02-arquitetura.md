# 02 — Arquitetura — Sales Coach AI

> **Versão:** 0.1 — 2026-09-03
> **Stack:** Agno 2.6+ · FastAPI · Supabase · Twilio · Groq Whisper · DeepSeek Flash · Claude
> **Base:** `blu_agno_runtime` (lib do monorepo) + padrão `agente-bloquo`

---

## 1. Stack

| Camada | Tecnologia | Origem |
|--------|-----------|--------|
| Framework de agentes | **Agno 2.6+** | `agno` (pip) |
| Factory de agentes | **blu_agno_runtime** | `~/monorepo/libs/blu_agno_runtime/` |
| LLM routing | **blu_llm_service** | `~/monorepo/libs/blu_llm_service/` |
| ASR (áudio) | **Groq Whisper** via `blu_llm_service.asr` | lib do monorepo |
| Canal WhatsApp | **blu_twilio_client** | `~/monorepo/libs/blu_twilio_client/` |
| Backend API | **FastAPI** | padrão Deep Blue |
| Autenticação | **blu_auth** (JWT/OAuth2) | `~/monorepo/libs/blu_auth/` |
| Banco + Storage | **Supabase** (via `blu_supabase_client`) | lib do monorepo |
| Sessão dos agentes | **Supabase/Postgres** (ou Redis) | `blu_agno_runtime.storage` |
| Base semântica | **Supabase pgvector** + embeddings | conhecimento da Cruzeiro |
| Painel (front) | **Vite + React 18 + Blu DS** | padrão Deep Blue |
| Gráficos | **Recharts** | npm |
| Deploy | **Cloud Run (GCP)** — responsabilidade TEMPLO | infra TEMPLO |

## 2. Arquitetura Multiagente

```
                           ┌─────────────────────────┐
                           │       WhatsApp/Twilio     │
                           │  (áudio, foto, texto)     │
                           └────────────┬────────────┘
                                        │ Webhook HTTP
                           ┌────────────▼────────────┐
                           │  Sales Coach API         │
                           │  FastAPI · blu_auth      │
                           │  blu_twilio_client       │
                           └────────────┬────────────┘
                                        │
                          ┌─────────────┴──────────────┐
                          │      Orchestrator Agent     │
                          │  (Agno — roteia mensagens   │
                          │   para o agente correto)    │
                          └──┬──────────┬──────────┬───┘
                             │          │          │
                   ┌─────────┘   ┌──────┘  ┌──────┘
                   ▼              ▼         ▼
     ┌─────────────────┐ ┌────────────┐ ┌──────────────────┐
     │ Agent Assessment │ │Agent Roleplay│ │ Agent Consultor  │
     │ (entrevista ~20min│ │(cenário +   │ │ (real-time +     │
     │  + scoring +     │ │ feedback)   │ │  sugestão)       │
     │  relatório)      │ │             │ │                  │
     └────────┬─────────┘ └──────┬──────┘ └────────┬─────────┘
              │                  │                  │
              └──────────────────┼──────────────────┘
                                 ▼
                    ┌──────────────────────┐
                    │   Agent Analytics     │
                    │ (processa interações  │
                    │  → métricas + tabelas)│
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │   Painel Liderança    │
                    │  React + Recharts     │
                    │  Teams (complementar) │
                    └──────────────────────┘
```

### 2.1 Orchestrator Agent

O **Orchestrator** é o primeiro ponto de contato. Ele:

1. Recebe a mensagem do webhook do Twilio
2. Classifica a intenção (assessment, roleplay, consultor, dúvida, comando)
3. Roteia para o agente especializado correto
4. Gerencia o estado da conversa (em qual "modo" o vendedor está)
5. Faz fallback para humano quando necessário

**Reuso do `agente-bloquo`:** o `agent.py` do agente-bloquo já implementa este
padrão de roteamento com `run_agent()` + `build_agent()` + pré-retrieval RAG.
Adaptamos para 4 agentes em vez de 1.

### 2.2 Agent Assessment

**Função:** Entrevista conversacional de ~20 min via WhatsApp avaliando o
vendedor em 3 eixos:

| Eixo | O que avalia | Peso |
|------|-------------|------|
| **Conhecimento de oferta** | Domínio do portfólio acadêmico (cursos, preços, diferenciais) | 40% |
| **Técnica consultiva** | Capacidade de fazer perguntas, entender necessidade, diagnosticar | 35% |
| **Orientação ao prospect** | Postura de serviço, empatia, fechamento centrado no cliente | 25% |

**Fluxo:**
1. Inicia com uma pergunta aberta ("Fale sobre sua experiência com vendas...")
2. Adapta as perguntas seguintes com base nas respostas anteriores
3. A cada 3-4 respostas, faz uma pergunta objetiva de multiple-choice
4. Após ~20 perguntas, gera o score nos 3 eixos
5. Envia relatório individual via WhatsApp com link

**Requisitos técnicos:**
- **Base vetorial:** portfólio acadêmico da Cruzeiro (cursos, eixos, preços,
  carga horária, diferenciais por concorrente) — para calibrar as perguntas
  e validar as respostas
- **Skills:** entrevista conversacional, scoring multi-eixo, geração de relatório
- **Modelo:** DeepSeek Flash (custo baixo, bom para conversação longa)
- **Estado:** sessão Persistida (o vendedor pode parar e retomar)

### 2.3 Agent Roleplay

**Função:** Gera cenários únicos de prospect simulado a partir do diagnóstico
do vendedor e do perfil do funil.

**Fluxo:**
1. Recebe o diagnóstico do Agent Assessment (pontos fortes/fracos)
2. Recebe o perfil do funil (curso, perfil de prospect, objeção comum)
3. Gera um cenário com:
   - Persona do prospect (nome, empresa, cargo, dor)
   - Contexto da abordagem (frio, lead qualificado, reativação)
   - Objeção específica a ser trabalhada
4. Conduz a simulação: o vendedor interage, o agente responde COMO o prospect
5. Ao final, gera feedback estruturado:
   - Técnica: o vendedor usou spin selling / consultiva?
   - Escuta: capturou as dores do prospect?
   - Fechamento: conduziu para o próximo passo?

**Requisitos técnicos:**
- **Base vetorial:** mapa de objeções da Cruzeiro, perfis de prospect, roteiros
  de venda — para gerar cenários realistas e variados
- **Skills:** geração de persona, simulação de prospect, avaliação de performance
- **Modelo:** Claude (melhor para roleplay com nuances, feedback mais rico)
- **Estado:** sessão de simulação (3-5 minutos de interação)

### 2.4 Agent Consultor (Real-time)

**Função:** Recebe áudio/foto/texto durante o atendimento real e devolve
argumento sugerido, contra-objeção e combinação de oferta.

**Fluxo:**
1. Vendedor envia durante o atendimento:
   - **Áudio:** "O cliente disse que o preço está acima do concorrente X"
   - **Foto:** print da conversa com o prospect
   - **Texto:** "Como rebater objeção de preço no curso de Medicina?"
2. Agente transcreve (se áudio, via Groq Whisper) ou extrai texto (se foto, via OCR)
3. Analisa o contexto: qual curso, qual objeção, qual momento do funil
4. Devolve:
   - **Argumento sugerido:** "Destaque que nosso curso tem residência garantida..."
   - **Contra-objeção:** "Pergunte se o concorrente oferece mentoria individual..."
   - **Combinação de oferta:** "Sugira o combo Curso + Preparatório Enem com 15% off"

**Requisitos técnicos:**
- **Base vetorial:** calibração de oferta, mapa de objeções com contra-argumentos,
  combos e descontos vigentes — tudo indexado semânticamente
- **ASR:** Groq Whisper (via `blu_llm_service.asr.transcribe_audio`) — padrão
  Deep Blue, já testado
- **OCR:** extração de texto de imagens (foto de conversa)
- **Modelo:** DeepSeek Flash (rápido, barato, bom para consultas pontuais)
- **Tempo de resposta:** <5 segundos (o vendedor está com o prospect ao lado)

### 2.5 Agent Analytics

**Função:** Processa todas as interações dos 3 agentes acima e gera métricas
para o painel da liderança.

**Fluxo:**
1. Escuta eventos dos outros agentes (via banco compartilhado ou fila)
2. Processa em lote (offline, não em tempo real):
   - Scores de assessment por vendedor → evolução temporal
   - Performance em roleplay → técnica, escuta, fechamento
   - Uso do consultor → tipos de objeção mais frequentes
   - Engajamento geral → % de conclusão, frequência
3. Gera tabelas agregadas por:
   - Vendedor (individual)
   - Polo (regional)
   - Unidade (franquia/escola)
   - Curso (qual curso tem mais dificuldade de venda)

**Requisitos técnicos:**
- **Base vetorial:** não — é puramente tabular/agregacional
- **Skills:** SQL/pandas para agregação, geração de relatório
- **Modelo:** DeepSeek Flash (para gerar insights narrativos a partir dos dados)
- **Periodicidade:** processamento diário (cron) + atualização sob demanda

## 3. Base de Dados Semântica

A base de conhecimento da Cruzeiro do Sul será ingerida em uma **base vetorial
Supabase pgvector**, com chunking semântico e embeddings via `blu_llm_service`.

### Coleções de conhecimento

| Coleção | Conteúdo | Fonte | Tamanho estimado |
|---------|----------|-------|-----------------|
| `portfolio-academico` | Cursos, eixos, preços, carga horária, concorrência | Portfólio Cruzeiro | ~50 docs |
| `roteiros-vendas` | Scripts, SPIN selling, perguntas abertas/fechadas | Manuais de vendas | ~20 docs |
| `mapa-objecoes` | Objeções por curso + contra-argumentos calibrados | Mapa de objeções | ~30 docs |
| `calibracao-oferta` | Combos, descontos, diferenciais por concorrente | Calibração de oferta | ~15 docs |
| `perfis-prospect` | Personas por curso, perfil do funil, dores | Perfil do prospect | ~10 docs |

### Pipeline de ingestão

Inspirado no `scripts/upload_docs.py` do **agente-bloquo** — adaptado para
Supabase + pgvector:

```
1. Receber arquivos da Cruzeiro (PDF, DOCX, Markdown, links)
2. Extrair texto (blu_parsers)
3. Chunk semântico (por seção/tópico)
4. Embedding via blu_llm_service (CohereEmbeddingClient)
5. Inserir em Supabase pgvector (tabela knowledge_chunks)
6. Metadados: coleção, fonte, curso relacionado, eixo
```

## 4. Fluxo de Mensagens (WhatsApp)

```
Vendedor envia mensagem → Twilio Webhook → Sales Coach API
  → blu_twilio_client.webhook.process()
  → Authenticate via blu_auth (vendedor já identificado pelo número)
  → Orchestrator Agent:
    ├── Se em modo assessment → Agent Assessment
    ├── Se em modo roleplay → Agent Roleplay
    ├── Se contém áudio/foto → Agent Consultor
    ├── Se comando "relatório" → Agent Assessment (gera relatório)
    └── Fallback → mensagem de boas-vindas + menu de opções
```

## 5. Painel da Liderança

**Frontend:** React + Vite + Blu DS (ou brandbook TEMPLO)
**Gráficos:** Recharts
**Autenticação:** blu_auth (JWT)
**Integração Teams:** webhook/adaptive cards para notificações

### Views do painel

| View | Descrição | Público |
|------|-----------|---------|
| **Dashboard** | Score médio geral, engajamento, alertas | Diretoria |
| **Por vendedor** | Score individual, evolução, roleplays feitos, consultas | Coordenador |
| **Por polo** | Média do polo, ranking interno, destaques | Gerência |
| **Por unidade** | Média da unidade, comparativo entre polos | Coordenador |
| **Por curso** | Dificuldade de venda por curso, objeções mais comuns | Gerência |

## 6. Reuso do `agente-bloquo`

| Componente do agente-bloquo | Adaptação para Sales Coach |
|-----------------------------|---------------------------|
| `src/agent.py` — `Agent` + `run_agent()` + `build_agent()` | Manter padrão. Adaptar para 4 agentes + orchestrator |
| `src/agent.py` — `VectorSearchTool` + `_search_vector_store()` | Manter, trocar OCI Vector Store → Supabase pgvector |
| `src/agent.py` — `_build_screen_context()` → prompt sections | Adaptar → `_build_assessment_context()` etc. |
| `src/agent.py` — Session persistence via `SqliteDb` | Trocar por `TenantPostgresDb` (blu_agno_runtime) |
| `src/agent.py` — `run_agent()` async + `asyncio.gather()` | Manter padrão. Adicionar Twilio como entrada |
| `src/agent.py` — `_AGENT_DESCRIPTION` + `_AGENT_INSTRUCTIONS` | Manter padrão de prompts estruturados |
| `src/agent.py` — Tool pattern (Toolkit subclasses) | Manter. Criar: AssessmentTool, RoleplayTool, ConsultorTool |
| `src/routes/chat.py` — `POST /chat` | Adaptar para webhook Twilio (`POST /webhook/twilio`) |
| `src/schemas/chat.py` — `ChatRequest` / `ChatResponse` | Adaptar para `TwilioMessage` / `TwilioResponse` |
| `src/config.py` — `Settings` com pydantic-settings | Manter padrão de validação no boot |
| `src/models/oci_grok.py` — Custom model pattern | Manter padrão. Criar `SalesCoachModel` se necessário |
| `src/main.py` — FastAPI app + middlewares + CORS | Manter. Adicionar rotas Twilio + painel |
| `src/auth/mcp_token_manager.py` — Token exchange | Não usar (não temos MCP). Usar `blu_auth` direto |

## 7. Reuso do `blu_agno_runtime`

| Componente | Uso |
|-----------|-----|
| `factory.py` — `build_agent()` | Construir cada agente com model tier + tools |
| `config.py` — `Settings` | Config de runtime multi-tenant |
| `control/plane.py` — `ControlPlane` | Gerenciar tenants (vendedores, polos) |
| `storage/tenant.py` — `TenantPostgresDb` | Sessão persistente dos agentes |
| `auth/` — `middleware.py`, `principal.py` | Autenticação JWT via `blu_auth` |
| `mcp/connection.py` | Não usar (não temos MCP) |

## 8. Segurança

- **Autenticação:** JWT via `blu_auth` (vendedores identificados pelo número
  WhatsApp + token de sessão)
- **Dados:** criptografia em trânsito (TLS) e em repouso (Supabase RLS)
- **Auditoria:** `blu_agent_framework.audit.record_audit()` — registro de todas
  as interações
- **Privacidade:** scores e relatórios são individuais; liderança vê agregados
  por polo/unidade/curso (dados individuais only por vendedor específico)
- **Teams:** autenticação separada para o painel (não reusa sessão WhatsApp)