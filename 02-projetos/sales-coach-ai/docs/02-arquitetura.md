# 02 — Arquitetura — Sales Coach AI

> **Versão:** 0.3 — 2026-09-03 (MCP embutido — tools como servidor FastMCP no mesmo processo)
> **Stack:** Agno 2.6+ · FastAPI · FastMCP · Supabase · Twilio · Groq Whisper · DeepSeek Flash · Claude
> **Base:** `blu_agno_runtime` (factory) + `blu_prompt_management` (runtime prompts) + `FastMCP` (tools embutidas)
> **Padrão:** 1 runtime com FastMCP montado no mesmo FastAPI → SalesCoachRegistry de modos

---

## 1. Princípio da Arquitetura

**1 imagem, 1 deploy, N modos carregados em runtime.**

Cada modo (assessment, roleplay, consultor, analytics) é um registro que define:
- `prompt_name` — carregado da **Langfuse** em runtime via `blu_prompt_management`
- `required_tool_names` — tools específicas do modo
- `model_tier` — FAST (Flash), DEFAULT, POWERFUL (Claude)
- `max_turns` — limite de interações

O runtime (1 serviço FastAPI) monta o Agno Agent correto a partir do registro
**a cada requisição** — o agente é stateless e recriado por request (a sessão
persiste no banco).

---

## 2. Stack

| Camada | Tecnologia | Origem |
|--------|-----------|--------|
| Framework de agentes | **Agno 2.6+** | `agno` (pip) |
| Factory de agentes | **blu_agno_runtime.factory.build_agent()** | `~/monorepo/libs/blu_agno_runtime/` |
| Prompts em runtime | **blu_prompt_management.build_prompt()** | `~/monorepo/libs/blu_prompt_management/` |
| Catálogo de modos | **SalesCoachRegistry** (inspirado no AgentTypeRegistry) | Criação nova no serviço |
| **Servidor MCP interno** | **FastMCP** (montado no mesmo FastAPI) | `pip install mcp[cli]` |
| LLM routing | **blu_llm_service** | `~/monorepo/libs/blu_llm_service/` |
| ASR (áudio) | **Groq Whisper** via `blu_llm_service.asr` | lib do monorepo |
| OCR (imagem) | **pytesseract** ou **docling** | pip |
| Canal WhatsApp | **blu_twilio_client** | `~/monorepo/libs/blu_twilio_client/` |
| Backend API | **FastAPI** | padrão Deep Blue |
| Autenticação | **blu_auth** (JWT/OAuth2) | `~/monorepo/libs/blu_auth/` |
| Banco + Storage | **Supabase** (via `blu_supabase_client`) | lib do monorepo |
| Sessão persistente | **TenantPostgresDb** (blu_agno_runtime.storage) | lib do monorepo |
| Base semântica | **Supabase pgvector** + Cohere embeddings | lib do monorepo |
| Painel (front) | **Vite + React 18 + Blu DS** | padrão Deep Blue |
| Gráficos | **Recharts** | npm |
| Deploy | **Cloud Run (GCP)** — responsabilidade TEMPLO | infra TEMPLO |

---

## 3. Como o Runtime Funciona

### 3.1 SalesCoachRegistry

Inspirado no `AgentTypeRegistry` do `blu_agent_framework`, cada modo é:

```python
@dataclass
class SalesCoachMode:
    """Registro de um modo do Sales Coach."""
    slug: str                        # "assessment", "roleplay", "consultor", "analytics"
    description: str                 # One-liner para o router
    prompt_name: str                 # "sales-coach/assessment" → Langfuse
    skill_tools: list[str]           # Tools permitidas neste modo
    model_tier: ModelTier            # FAST | DEFAULT | POWERFUL
    max_turns: int                   # 20 (assessment), 8 (roleplay), 3 (consultor)
    memory_mode: str                 # "session" | "stateless" (analytics é stateless)
```

O registro é carregado na inicialização do serviço e pode ser estendido sem
alterar código (novos modos = novos registros + novos prompts na Langfuse).

### 3.2 Fluxo de uma requisição

```
Vendedor envia mensagem via WhatsApp
         │
         ▼
Twilio Webhook → POST /webhook/twilio
         │
         ▼
Sales Coach API (FastAPI)
  1. blu_twilio_client.webhook.process() → decodifica mensagem
  2. blu_auth → identifica vendedor pelo número (JWT)
  3. Consulta sessão ativa no Supabase/Postgres
         │
         ▼
  Router (Intent Classifier)
  ┌─────────────────────────────────────────────┐
  │ Se não há sessão ativa:                     │
  │   Classifica intenção (LLM leve, 1 chamada) │
  │   → "assessment" | "roleplay" | "consultor" │
  │   | "menu" | "fallback"                     │
  │                                             │
  │ Se há sessão ativa:                          │
  │   Mantém o modo atual                        │
  └────────────────────┬────────────────────────┘
         │
         ▼
  SalesCoachRegistry.get(mode)
  → prompt_name, skill_tools, model_tier, max_turns
         │
         ▼
  Factory (blu_agno_runtime.build_agent())
  1. build_prompt("sales-coach/assessment", variables={...})
     → Langfuse first, builtin fallback
  2. Resolve modelo: ModelTier.FAST → DeepSeek Flash
  3. Monta tools: [AssessmentTool(), VectorSearchTool(), ...]
  4. Cria Agno Agent stateless com sessão persistente
         │
         ▼
  Agent arun() → resposta
         │
         ▼
  ResponseFormatter → Twilio → WhatsApp do vendedor
```

### 3.3 Pipeline de prompts (blu_prompt_management)

Os prompts **não estão no código**. Cada modo tem um prompt na Langfuse:

| Modo | Prompt Langfuse | Fallback builtin | Carregado em |
|------|----------------|-----------------|-------------|
| assessment | `sales-coach/assessment` | `sales_coach_assessment.md` | Runtime (cada sessão) |
| roleplay | `sales-coach/roleplay` | `sales_coach_roleplay.md` | Runtime |
| consultor | `sales-coach/consultor` | `sales_coach_consultor.md` | Runtime |
| analytics | `sales-coach/analytics` | `sales_coach_analytics.md` | Runtime (cron) |
| router | `sales-coach/router` | `sales_coach_router.md` | Runtime |

```python
from blu_prompt_management import build_prompt

prompt = await build_prompt(
    "sales-coach/assessment",
    variables={
        "vendedor_nome": "João",
        "ultimo_score": 72,
        "eixos": "conhecimento, consultiva, orientação",
    },
    allow_fallback=True,
)
```

**Vantagens:**
- Ajusta prompts sem deploy (só na Langfuse)
- Versionamento nativo (pode reverter)
- A/B testing entre versões (labels na Langfuse)
- Fallback builtin se Langfuse estiver fora

---

## 4. Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     1 Docker Image (Cloud Run)                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │              Sales Coach API (FastAPI — porta 8000)              │   │
│  │                                                                  │   │
│  │  ┌──────────┐  ┌───────────────┐  ┌────────────────────────┐   │   │
│  │  │  Twilio  │  │   blu_auth    │  │      Router             │   │   │
│  │  │  Webhook │  │   (JWT)       │  │  (classificador leve)   │   │   │
│  │  └────┬─────┘  └───────────────┘  └───────────┬────────────┘   │   │
│  │       │                                         │              │   │
│  │       └─────────────┬───────────────────────────┘              │   │
│  │                     ▼                                          │   │
│  │       ┌─────────────────────────────────────┐                  │   │
│  │       │       SalesCoachRegistry            │                  │   │
│  │       │  assessment → prompt + Flash        │                  │   │
│  │       │  roleplay   → prompt + Claude       │                  │   │
│  │       │  consultor  → prompt + Flash        │                  │   │
│  │       │  analytics  → prompt + Flash        │                  │   │
│  │       └────────────────┬────────────────────┘                  │   │
│  │                        ▼                                       │   │
│  │       ┌─────────────────────────────────────┐                  │   │
│  │       │   Agent Factory (Agno)              │                  │   │
│  │       │  1. build_prompt(mode) → Langfuse   │                  │   │
│  │       │  2. Resolve model tier              │                  │   │
│  │       │  3. Cria Agno Agent                 │                  │   │
│  │       │  4. Conecta MCPTools(url=localhost) │                  │   │
│  │       └────────────────┬────────────────────┘                  │   │
│  │                        │                                       │   │
│  │                        ▼                                       │   │
│  │       ┌─────────────────────────────────────┐                  │   │
│  │       │  Agno Agent (recriado por request)  │                  │   │
│  │       │  ┌───────────────────────────────┐  │                  │   │
│  │       │  │   MCPTools(url="http://       │  │                  │   │
│  │       │  │    localhost:8000/mcp")       │  │                  │   │
│  │       │  └───────────┬───────────────────┘  │                  │   │
│  │       └──────────────┼──────────────────────┘                  │   │
│  └──────────────────────┼──────────────────────────────────────────┘   │
│                         │                                              │
│  ┌──────────────────────┼──────────────────────┐                       │
│  │                      ▼                       │                       │
│  │  FastMCP Server (montado em /mcp — mesmo     │                       │
│  │  processo, mesmo FastAPI via app.mount())    │                       │
│  │                                              │                       │
│  │  Tools registradas com @mcp.tool():          │                       │
│  │                                              │                       │
│  │  Assessment:                                 │                       │
│  │   ├─ entrevista_tool()   → pergunta adapta   │                       │
│  │   ├─ scoring_tool()      → avalia 3 eixos    │                       │
│  │   ├─ vector_search()     → consulta pgvector │                       │
│  │   └─ relatorio_tool()   → gera link          │                       │
│  │                                              │                       │
│  │  Roleplay:                                   │                       │
│  │   ├─ cenario_tool()      → persona+objeção   │                       │
│  │   ├─ simular_prospect()  → atua como cliente  │                       │
│  │   └─ feedback_tool()     → técnica+escuta+F  │                       │
│  │                                              │                       │
│  │  Consultor:                                  │                       │
│  │   ├─ transcrever_audio() → Groq Whisper      │                       │
│  │   ├─ extrair_texto()     → OCR               │                       │
│  │   ├─ analisar_contexto() → detecta objeção   │                       │
│  │   └─ sugerir()            → argumento+oferta │                       │
│  │                                              │                       │
│  │  Analytics:                                  │                       │
│  │   ├─ agregar()            → SQL/pandas        │                       │
│  │   └─ gerar_insight()      → narrativa         │                       │
│  └──────────────────────────────────────────────┘                       │
│                                                                         │
│  ┌─────────────┐  ┌───────────────┐  ┌─────────────┐                   │
│  │  Supabase   │  │  Langfuse     │  │  Twilio     │                   │
│  │ (auth+      │  │ (prompts      │  │  WhatsApp   │                   │
│  │  storage+   │  │  versionados) │  │  (canal)    │                   │
│  │  pgvector)  │  └───────────────┘  └─────────────┘                   │
│  └─────────────┘                                                       │
│                                                                         │
│        Todas as tools MCP chamam as libs do monorepo:                   │
│        blu_llm_service · blu_twilio_client · blu_supabase_client        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. MCP Server — Tools Embutidas

Todas as ferramentas (tools) que os modos do Sales Coach usam são expostas como
**um servidor MCP montado no mesmo processo FastAPI**.

### 5.1 Como funciona

```python
from fastapi import FastAPI
from mcp.server.fastmcp import FastMCP

# FastAPI principal (REST: webhooks + painel)
app = FastAPI(title="Sales Coach AI")

# FastMCP server (tools dos agentes)
mcp = FastMCP("sales-coach")

# ── Tools de Assessment ─────────────────────────────────────
@mcp.tool()
async def entrevista_tool(
    vendedor_id: str,
    fase: str,
    ultima_resposta: str | None = None,
) -> str:
    """Conducts the next assessment interview question for a salesperson.
    Adapts based on previous answers and current evaluation phase."""
    # usa a base semântica para gerar pergunta adaptativa
    return await gerar_proxima_pergunta(vendedor_id, fase, ultima_resposta)

@mcp.tool()
async def scoring_tool(
    vendedor_id: str,
    respostas: list[dict],
) -> dict:
    """Scores a salesperson on 3 axes: knowledge (0-100), consultive (0-100),
    prospect orientation (0-100). Returns weighted general score."""
    return await calcular_score(respostas)

@mcp.tool()
async def relatorio_tool(
    vendedor_id: str,
    assessment_id: str,
) -> str:
    """Generates an individual assessment report and returns a WhatsApp link."""
    return await gerar_relatorio(vendedor_id, assessment_id)

# ── Tools de Roleplay ──────────────────────────────────────
@mcp.tool()
async def cenario_tool(
    diagnostico: dict,
    perfil_funil: dict,
) -> dict:
    """Generates a unique roleplay scenario: persona, context, and objection
    based on the seller's diagnosis and funnel profile."""
    # busca no mapa de objeções e perfis de prospect
    return await gerar_cenario(diagnostico, perfil_funil)

@mcp.tool()
async def simular_prospect(
    cenario_id: str,
    mensagem_vendedor: str,
) -> str:
    """Acts as the simulated prospect, responding realistically with
    resistance, doubts, and hesitations."""
    return await responder_como_prospect(cenario_id, mensagem_vendedor)

@mcp.tool()
async def feedback_tool(
    conversa_id: str,
) -> dict:
    """Evaluates roleplay performance on technique, listening, and closing.
    Returns structured feedback with scores and improvement suggestions."""
    return await avaliar_roleplay(conversa_id)

# ── Tools de Consultor ─────────────────────────────────────
@mcp.tool()
async def transcrever_audio(audio_base64: str) -> str:
    """Transcribes audio using Groq Whisper (ASR)."""
    return await blu_llm_service.asr.transcribe_audio(audio_base64)

@mcp.tool()
async def extrair_texto(imagem_base64: str) -> str:
    """Extracts text from an image via OCR."""
    return await ocr_service.extrair(imagem_base64)

@mcp.tool()
async def analisar_contexto(
    mensagem: str,
    curso: str | None = None,
) -> dict:
    """Analyses the sales context: identifies the course, objection type,
    and funnel stage from the seller's message."""
    return await detectar_contexto(mensagem, curso)

@mcp.tool()
async def sugerir(
    contexto: dict,
) -> dict:
    """Suggests a sales argument, counter-objection, and offer combination
    based on the analysed context."""
    return await gerar_sugestao(contexto)

# ── Tools de Analytics ─────────────────────────────────────
@mcp.tool()
async def agregar(
    periodo: str,
    granularidade: str,
) -> dict:
    """Aggregates interaction metrics by seller, pole, unit, or course.
    Period: 'daily' | 'weekly' | 'monthly'. Granularity: 'seller' | 'pole' |
    'unit' | 'course'."""
    return await agregar_metricas(periodo, granularidade)

@mcp.tool()
async def vector_search(consulta: str, colecao: str = "") -> str:
    """Searches the Cruzeiro do Sul knowledge base semantically.
    Returns relevant document excerpts with source references.
    Colection filter: 'portfolio-academico', 'mapa-objecoes', etc."""
    return await buscar_base_semantica(consulta, colecao)

# ── Monta o MCP no FastAPI (1 imagem!) ─────────────────────
app.mount("/mcp", mcp.sse_app())
```

### 5.2 Como o Agno consome as tools

O Agno Agent se conecta ao servidor MCP **que está rodando no mesmo processo**:

```python
from agno.tools.mcp import MCPTools

tools = [
    MCPTools(url="http://localhost:8000/mcp"),  # MCP embutido
]
agent = Agent(
    model=model,
    tools=tools,
    # ...
)
```

### 5.3 Vantagens do padrão MCP embutido

| Dimensão | Sem MCP (tools soltas) | Com MCP (FastMCP embutido) |
|----------|----------------------|---------------------------|
| Schema das tools | Manual (docstring solta) | **Automático** (tipos Python → JSON schema) |
| Descoberta de tools | O Agno só sabe as que recebeu | **MCP lista todas automaticamente** |
| Separação REST vs tools | Tudo junto no Agno Agent | **REST no FastAPI, tools no FastMCP** |
| Versionamento de tools | Deploy do código | **Tools são endpoints — versão implícita** |
| Reuso externo | Só o Agno usa | **Qualquer cliente MCP pode chamar** (futuro: Claude Desktop, Copilot) |
| Complexidade | 0 servidores extras | **0 servidores extras** (mesmo processo) |
| Conexão | N/A | `localhost:8000/mcp` — sem auth, sem latência de rede |

### 5.4 Diferença do padrão `blu_agno_runtime.mcp.connection`

A lib `blu_agno_runtime/mcp/connection.py` abre conexão MCP com um servidor
**externo** (passa URL + token). No Sales Coach, o servidor MCP é interno:

```
blu_agno_runtime → MCPTools(url="https://mcp.externo.com")  ← servidor remoto
Sales Coach      → MCPTools(url="http://localhost:8000/mcp") ← mesmo processo

Sem token exchange, sem latência de rede, sem falha de DNS.
```

### 5.5 Dependência extra

```bash
pip install mcp[cli]
# juntamente com as dependências existentes:
# agno, blu-agno-runtime, blu-llm-service, blu-twilio-client, ...
```

---

## 6. SalesCoachRegistry — Catálogo de Modos

```python
SALES_COACH_MODES: dict[str, SalesCoachMode] = {
    "assessment": SalesCoachMode(
        slug="assessment",
        description="Entrevista conversacional ~20min avaliando conhecimento, consultiva e orientação",
        prompt_name="sales-coach/assessment",
        skill_tools=["entrevista_tool", "scoring_tool", "vector_search", "relatorio_tool"],
        model_tier=ModelTier.FAST,  # DeepSeek Flash (custo baixo, conversação longa)
        max_turns=25,
        memory_mode="session",
    ),
    "roleplay": SalesCoachMode(
        slug="roleplay",
        description="Geração de cenário único de prospect simulado + feedback estruturado",
        prompt_name="sales-coach/roleplay",
        skill_tools=["cenario_tool", "simular_prospect", "feedback_tool", "vector_search"],
        model_tier=ModelTier.POWERFUL,  # Claude (nuance para simulação rica)
        max_turns=12,
        memory_mode="session",
    ),
    "consultor": SalesCoachMode(
        slug="consultor",
        description="Recebe áudio/foto/texto durante atendimento real → sugestão em <5s",
        prompt_name="sales-coach/consultor",
        skill_tools=["transcrever_audio", "extrair_texto", "analisar_contexto", "sugerir"],
        model_tier=ModelTier.FAST,  # DeepSeek Flash (tempo real, baixa latência)
        max_turns=4,
        memory_mode="session",
    ),
    "analytics": SalesCoachMode(
        slug="analytics",
        description="Processamento em lote de interações → métricas agregadas + narrativa",
        prompt_name="sales-coach/analytics",
        skill_tools=["agregar", "gerar_insight"],
        model_tier=ModelTier.FAST,
        max_turns=3,
        memory_mode="none",  # stateless — executa em cron
    ),
}
```

## 7. Agent Factory (core do sistema)

```python
async def build_sales_coach_agent(
    mode: str,
    session_id: str,
    vendedor_id: str,
    modo_config: SalesCoachMode,
) -> Agent:
    # 1. Carrega prompt da Langfuse (com fallback builtin)
    prompt = await build_prompt(
        modo_config.prompt_name,
        variables={
            "vendedor_nome": "...",
            "ultimo_score": ...,
            "historico": [...],
        },
        allow_fallback=True,
    )

    # 2. Monta as tools do modo
    tools = [
        VectorSearchTool(),       # RAG na base semântica (compartilhada)
        *MODE_TOOLS[modo_config.slug],  # tools específicas
    ]

    # 3. Cria o Agno Agent
    agent = build_agent(
        session_id=session_id,
        tenant_id=vendedor_id,
        tier=modo_config.model_tier,
        tools=tools,
        user_id=vendedor_id,
    )

    # 4. Seta o prompt carregado em runtime
    agent.description = prompt  # prompt completo como description
    agent.instructions = _MODE_INSTRUCTIONS[modo_config.slug]

    return agent
```

O `build_agent()` do `blu_agno_runtime` cuida de:
- Resolver o modelo correto para o tier
- Configurar o banco de sessão (TenantPostgresDb)
- Envolver tools com auditoria
- Preparar o Agent para `arun()`

## 8. Router (Intent Classifier)

O router é a primeira parada de toda mensagem. Ele:

1. Verifica se o vendedor já está em **um modo ativo** (sessão assessment em andamento)
2. Se sim → mantém o modo (não gasta chamada LLM classificando)
3. Se não → classifica a intenção com 1 chamada LLM leve

**Modos de classificação:**
- `assessment` → "avaliação", "quero fazer o teste", "começar", primeira mensagem
- `roleplay` → "treinar", "simular", "vamos praticar", "cenário"
- `consultor` → contém áudio, foto, ou "preciso de ajuda agora", "como responder"
- `menu` → "o que você faz", "menu", "ajuda"
- `fallback` → nenhuma das acima

O router é implementado como um prompt leve (1-2 chamadas) que retorna um JSON
com o modo detectado. Não precisa de LangGraph — é uma `build_prompt()` + parse.

## 9. Base de Dados Semântica

### 9.1 Pipeline de ingestão (inspirada no `agente-bloquo`)

```
1. Receber arquivos da Cruzeiro (PDF, DOCX, MD, links)
2. Extrair texto via blu_parsers
3. Chunk semântico: por seção, ~1000 tokens
4. Embedding via CohereEmbeddingClient (blu_llm_service)
5. Inserir em Supabase pgvector (tabela knowledge_chunks)
```

Diferente do agente-bloquo (que usa OCI Vector Store), usamos **Supabase
pgvector** — mesma stack do restante da Deep Blue.

### 9.2 Reuso do VectorSearchTool

O `VectorSearchTool` do agente-bloquo (`src/agent.py`, ~50 linhas) é
reaproveitável integralmente — só trocar a chamada:

```python
# Antes (agente-bloquo):
client.vector_stores.search(vector_store_id=OCI_VECTOR_STORE_ID, query=...)

# Depois (Sales Coach):
supabase.rpc("search_knowledge", {"query_embedding": embed(query), "match_count": 5})
```

### 9.3 Coleções

| Coleção | Prioridade | Tamanho estimado | Usada por |
|---------|-----------|-----------------|-----------|
| `portfolio-academico` | P0 | ~50 chunks | assessment, roleplay, consultor |
| `mapa-objecoes` | P0 | ~30 chunks | roleplay, consultor |
| `calibracao-oferta` | P0 | ~15 chunks | consultor |
| `roteiros-vendas` | P1 | ~20 chunks | assessment, roleplay |
| `perfis-prospect` | P1 | ~10 chunks | roleplay |

## 10. Sessão e Estado

### 10.1 Schema da sessão

```sql
create table sessoes (
  id uuid primary key default gen_random_uuid(),
  vendedor_id text not null,
  modo_atual text not null,          -- 'assessment' | 'roleplay' | 'consultor' | 'menu'
  modo_dados jsonb,                  -- estado interno do modo (assessment: pergunta_atual, scores)
  session_id text not null,          -- session_id do Agno
  ultima_interacao timestamptz,
  created_at timestamptz default now()
);

create index idx_sessoes_vendedor on sessoes(vendedor_id);
```

### 10.2 Persistência do Agno

Usamos `TenantPostgresDb` do `blu_agno_runtime.storage` — o Agno persiste o
histórico multi-turno automaticamente. Cada modo tem seu próprio `session_id`,
mas compartilham o mesmo `vendedor_id` como tenant.

## 11. Fluxo de Mensagens (WhatsApp) — Detalhado

```
1. Vendedor envia mensagem pelo WhatsApp
2. Twilio → POST /webhook/twilio (Sales Coach API)
3. blu_twilio_client decodifica:
   - Texto → message.body
   - Áudio → media_url (Groq Whisper depois)
   - Imagem → media_url (OCR depois)
4. blu_auth → identifica vendedor por número (lookup ou JWT)
5. Busca sessão ativa em sessoes (vendedor_id)
6. Se tem sessão ativa:
   → Router mantém modo atual
   → Chama build_sales_coach_agent(modo_atual, ...)
   → Agent arun() com a mensagem
   → Resposta formatada → Twilio
7. Se NÃO tem sessão ativa:
   → Router classifica intenção (LLM leve)
   → Cria nova sessão com modo detectado
   → Chama build_sales_coach_agent(modo_novo, ...)
   → Agent arun() com a mensagem + prompt de boas-vindas
   → Resposta → Twilio
```

## 12. Painel da Liderança

Mesmo desenho anterior, pois independe da arquitetura de agentes:

**Frontend:** React + Vite + Blu DS (ou brandbook TEMPLO)
**Gráficos:** Recharts
**Autenticação:** blu_auth (JWT)
**Integração Teams:** webhook para notificações

### Views

| View | Descrição | Público |
|------|-----------|---------|
| Dashboard | Score médio geral, engajamento, alertas | Diretoria |
| Por vendedor | Score individual, evolução, roleplays, consultas | Coordenador |
| Por polo | Média do polo, ranking interno | Gerência |
| Por unidade | Média da unidade, comparativo | Coordenador |
| Por curso | Dificuldade de venda por curso, objeções comuns | Gerência |

## 13. Reuso do agente-bloquo — Mapa Atualizado

| Componente | Uso no Sales Coach | Adaptação |
|-----------|-------------------|-----------|
| `agent.py` — `VectorSearchTool` + `_search_vector_store()` | Sim — RAG na base semântica | Trocar OCI → Supabase pgvector |
| `agent.py` — `build_agent()` + `run_agent()` padrão | Sim — base do Agent Factory | Adaptar para múltiplos modos |
| `agent.py` — `_build_screen_context()` | Análogo — virou `_build_session_context()` | Modo-aware |
| `agent.py` — Session persistence (SqliteDb) | Sim — trocar por `TenantPostgresDb` | Já no blu_agno_runtime |
| `agent.py` — `asyncio.gather()` (pré-retrieval+token) | Sim — pré-retrieval da base vetorial | Manter |
| `agent.py` — `_AGENT_DESCRIPTION` + `_AGENT_INSTRUCTIONS` | Sim — agora carregados da Langfuse | Trocar por `build_prompt()` |
| `routes/chat.py` — `POST /chat` | Análogo — vira `POST /webhook/twilio` | Adaptar para Twilio |
| `schemas/chat.py` — `ChatRequest` / `ChatResponse` | Análogo — `TwilioMessage` / `TwilioResponse` | Adaptar |
| `config.py` — pydantic-settings | Sim — manter padrão | Copiar |
| `main.py` — FastAPI + CORS | Sim — manter | Copiar |
| `models/oci_grok.py` — Custom Agno model | Não (não usamos OCI) | Usar `blu_llm_service` direto |

## 14. Segurança

- **Autenticação:** JWT via `blu_auth` — vendedores identificados pelo número
  WhatsApp + token de sessão
- **Painel:** login separado (email + senha ou OAuth2), controle por role
- **Auditoria:** `record_audit()` do `blu_agent_framework` — todas as interações
- **Privacidade:** scores individuais visíveis apenas ao vendedor e seu coordenador
- **RLS no Supabase:** vendedor vê só seus dados; coordenador vê seu polo