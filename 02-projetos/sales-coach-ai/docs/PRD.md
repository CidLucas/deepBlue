# PRD — Sales Coach AI (Cruzeiro do Sul)

> **Product Requirements Document — v0.2**
> **Data:** 2026-09-03
> **Prazo:** 30 dias (01/09 — 30/09/2026)
> **Responsável técnico:** Lucas Cid (Deep Blue)
> **Parceiro:** TEMPLO (infra, GP, AI Officer, custos IA)
> **Arquitetura:** 1 runtime → SalesCoachRegistry de modos (Agno + prompts da Langfuse)

---

## 1. Contexto

A Cruzeiro do Sul, instituição educacional com 150 vendedores distribuídos entre
polos, unidades e cursos, precisa de um sistema contínuo de capacitação de
vendas que opere 100% no WhatsApp — sem app novo no celular do vendedor.

## 2. Usuários

| Ator | Interage via | Frequência | Dispositivo |
|------|-------------|-----------|-------------|
| Vendedor | WhatsApp (texto, áudio, foto) | Diária | Smartphone |
| Coordenador de polo | Painel web (notificações Teams) | Semanal | Desktop/Tablet |
| Gerência | Painel web + Teams | Quinzenal | Desktop |
| Diretoria | Painel web | Mensal | Desktop |

## 3. Stack

| Camada | Tecnologia | Origem |
|--------|-----------|--------|
| Framework de agentes | **Agno 2.6+** | `agno` (pip) |
| Factory de agentes | **blu_agno_runtime.factory.build_agent()** | `~/monorepo/libs/blu_agno_runtime/` |
| Prompts em runtime | **blu_prompt_management.build_prompt()** | `~/monorepo/libs/blu_prompt_management/` |
| LLM routing | **blu_llm_service** | `~/monorepo/libs/blu_llm_service/` |
| ASR (áudio) | **Groq Whisper** via `blu_llm_service.asr` | lib do monorepo |
| WhatsApp | **blu_twilio_client** | `~/monorepo/libs/blu_twilio_client/` |
| Backend | **FastAPI** | padrão Deep Blue |
| Autenticação | **blu_auth** (JWT) | `~/monorepo/libs/blu_auth/` |
| Banco + Storage | **Supabase** (via `blu_supabase_client`) | lib do monorepo |
| Sessão persistente | **TenantPostgresDb** (blu_agno_runtime.storage) | lib do monorepo |
| Base vetorial | **Supabase pgvector** + Cohere embeddings | lib do monorepo |
| Painel | **Vite + React 18 + Blu DS + Recharts** | padrão Deep Blue |
| Deploy | **Cloud Run (GCP)** — 1 imagem | responsabilidade TEMPLO |

---

## 4. Princípio Arquitetural

**1 imagem Docker, 1 serviço, N modos carregados em runtime.**

```
                      ┌──────────────────────────────┐
                      │    1 imagem Docker (Cloud Run)│
                      │                              │
                      │  ┌────────────────────────┐  │
                      │  │ Sales Coach API        │  │
                      │  │ (FastAPI)              │  │
                      │  │                        │  │
                      │  │  ┌──────────────────┐  │  │
                      │  │  │ SalesCoachRegistry│  │  │
                      │  │  │                  │  │  │
                      │  │  │ assessment  → prompts │  │
                      │  │  │ roleplay    → (Langfuse│  │
                      │  │  │ consultor   →  + tools)│  │
                      │  │  │ analytics   →         │  │
                      │  │  └────────┬─────────┘  │  │
                      │  │           │             │  │
                      │  │  ┌────────▼─────────┐  │  │
                      │  │  │ Agent Factory     │  │  │
                      │  │  │ (Agno, recriado   │  │  │
                      │  │  │  por request)     │  │  │
                      │  │  └──────────────────┘  │  │
                      │  └────────────────────────┘  │
                      │                              │
                      │  Supabase · Langfuse · Twilio│
                      └──────────────────────────────┘
```

Cada "modo" (assessment, roleplay, consultor, analytics) é um registro que
define:
- `prompt_name` → carregado da **Langfuse** em runtime via `blu_prompt_management`
- `skill_tools` → tools específicas do modo
- `model_tier` → FAST (DeepSeek Flash), DEFAULT, POWERFUL (Claude)
- `max_turns` → limite de interações

O runtime monta o Agno Agent correto **a cada requisição** — stateless, sessão
persistente no banco via `TenantPostgresDb`.

---

## 5. SalesCoachRegistry — Catálogo de Modos

```python
SALES_COACH_MODES = {
    "assessment": SalesCoachMode(
        slug="assessment",
        prompt_name="sales-coach/assessment",
        skill_tools=["entrevista_tool", "scoring_tool", "vector_search", "relatorio_tool"],
        model_tier=ModelTier.FAST,       # DeepSeek Flash
        max_turns=25,
        memory_mode="session",
    ),
    "roleplay": SalesCoachMode(
        slug="roleplay",
        prompt_name="sales-coach/roleplay",
        skill_tools=["cenario_tool", "simular_prospect", "feedback_tool", "vector_search"],
        model_tier=ModelTier.POWERFUL,   # Claude
        max_turns=12,
        memory_mode="session",
    ),
    "consultor": SalesCoachMode(
        slug="consultor",
        prompt_name="sales-coach/consultor",
        skill_tools=["transcrever_audio", "extrair_texto", "analisar_contexto", "sugerir"],
        model_tier=ModelTier.FAST,       # DeepSeek Flash
        max_turns=4,
        memory_mode="session",
    ),
    "analytics": SalesCoachMode(
        slug="analytics",
        prompt_name="sales-coach/analytics",
        skill_tools=["agregar", "gerar_insight"],
        model_tier=ModelTier.FAST,
        max_turns=3,
        memory_mode="none",              # stateless — executa em cron
    ),
}
```

---

## 6. Modo Assessment

### Goal
Entrevista conversacional de ~20 minutos avaliando o vendedor em conhecimento
de oferta, técnica consultiva e orientação ao prospect. Gerar relatório
individual com score e recomendações.

### ACs
1. **AC01 — Início da entrevista:** Ao entrar em modo assessment, o agente
   saúda o vendedor e inicia com uma pergunta aberta sobre sua experiência
2. **AC02 — Adaptação dinâmica:** As perguntas seguintes se adaptam com base
   nas respostas anteriores (não é questionário fixo)
3. **AC03 — Perguntas objetivas:** A cada 3-4 respostas, insere uma pergunta
   de multiple-choice para calibrar conhecimento específico
4. **AC04 — Eixos de avaliação:** Cobre obrigatoriamente: conhecimento de
   oferta (40%), técnica consultiva (35%), orientação ao prospect (25%)
5. **AC05 — Duração:** Entre 15 e 25 perguntas, adaptável conforme qualidade
   das respostas
6. **AC06 — Interrupção:** O vendedor pode pausar e retomar (sessão persistida)
7. **AC07 — Geração de score:** Score de 0-100 em cada eixo + score geral
8. **AC08 — Relatório:** Relatório individual com scores, áreas fortes, áreas
   de melhoria, recomendações de roleplay
9. **AC09 — Envio:** Relatório enviado via WhatsApp com link
10. **AC10 — Periodicidade:** Pode ser repetido semanalmente (para medir evolução)

### Tools

| Tool | Função | Base vetorial |
|------|--------|---------------|
| `entrevista_tool` | Conduz a entrevista, gera próxima pergunta adaptativa | `portfolio-academico` |
| `scoring_tool` | Pontua a resposta do vendedor em 3 eixos (0-100) | — |
| `vector_search` | Consulta a base semântica para validar respostas | `portfolio-academico`, `roteiros-vendas` |
| `relatorio_tool` | Monta e envia o relatório individual via WhatsApp | — |

### Modelo
**DeepSeek Flash** (ModelTier.FAST) — conversação longa, custo baixo.

---

## 7. Modo Roleplay

### Goal
Gerar cenários únicos de prospect simulado com base no diagnóstico do vendedor
e no perfil do funil. Conduzir a simulação e gerar feedback estruturado.

### ACs
1. **AC01 — Geração de cenário:** Gera cenário com persona (nome, empresa,
   cargo, dor), contexto de abordagem e objeção específica
2. **AC02 — Personalização:** Cenário baseado no diagnóstico do vendedor
   (assessment mais recente) e perfil do funil
3. **AC03 — Variabilidade:** Cada sessão gera um cenário diferente
4. **AC04 — Simulação:** O agente atua como o prospect, respondendo de forma
   realista (resistência, dúvidas, hesitações)
5. **AC05 — Intervenção:** Se o vendedor se desviar, oferece dica
6. **AC06 — Feedback estruturado:** Após 5-10 interações, encerra e gera
   feedback em 3 eixos: técnica (0-100), escuta (0-100), fechamento (0-100)
7. **AC07 — Sugestão textual:** Cada eixo com feedback textual + sugestão
   concreta de melhoria
8. **AC08 — Histórico:** Acumula histórico de roleplays para mostrar evolução

### Tools

| Tool | Função | Base vetorial |
|------|--------|---------------|
| `cenario_tool` | Gera persona, contexto e objeção a partir do diagnóstico | `perfis-prospect`, `mapa-objecoes` |
| `simular_prospect` | Atua como o prospect na conversa | `mapa-objecoes` |
| `feedback_tool` | Avalia técnica, escuta e fechamento + gera relatório | — |
| `vector_search` | Busca referências de técnica de venda na base | `roteiros-vendas` |

### Modelo
**Claude** (ModelTier.POWERFUL) — roleplay precisa de nuance, realismo na
atuação e feedback qualitativo rico.

---

## 8. Modo Consultor (Real-time)

### Goal
Receber áudio/foto/texto do vendedor durante um atendimento real e devolver
argumento sugerido, contra-objeção e combinação de oferta em <5 segundos.

### ACs
1. **AC01 — Entrada multimodal:** Aceita texto, áudio (transcrição via Groq
   Whisper) e foto (texto em imagem via OCR)
2. **AC02 — Análise de contexto:** Interpreta a situação: curso, objeção,
   momento do funil
3. **AC03 — Argumento sugerido:** Devolve argumento de venda específico
4. **AC04 — Contra-objeção:** Sugere pergunta ou contra-argumento
5. **AC05 — Combinação de oferta:** Se aplicável, sugere combo, desconto
6. **AC06 — Tempo de resposta:** <5 segundos (vendedor está com o prospect)
7. **AC07 — Tom de sugestão:** "Tente dizer: ...", não respostas prontas
8. **AC08 — Histórico:** Mantém contexto das últimas consultas do vendedor
9. **AC09 — Fallback:** Se não entender, pede mais contexto em vez de chutar

### Tools

| Tool | Função | Base vetorial |
|------|--------|---------------|
| `transcrever_audio` | Transcreve áudio via Groq Whisper | — |
| `extrair_texto` | Extrai texto de imagem (OCR) | — |
| `analisar_contexto` | Identifica curso, objeção, momento do funil | `portfolio-academico`, `mapa-objecoes` |
| `sugerir` | Gera argumento + contra-objeção + oferta combinada | `calibracao-oferta`, `mapa-objecoes` |

### Modelo
**DeepSeek Flash** (ModelTier.FAST) — resposta rápida, baixo custo.

---

## 9. Modo Analytics

### Goal
Processar todas as interações dos modos anteriores e gerar métricas agregadas
para o painel da liderança.

### ACs
1. **AC01 — Processamento diário:** Roda uma vez ao dia (cron) processando
   as interações do dia anterior
2. **AC02 — Agregação multidimensional:** Métricas por vendedor, polo,
   unidade e curso
3. **AC03 — Séries temporais:** Cada métrica mantém histórico (dia/semana/mês)
4. **AC04 — Narrativa:** Gera insight narrativo por agregado
5. **AC05 — Alertas:** Detecta vendedores com queda abrupta de score
6. **AC06 — Rankings:** Top 10 e bottom 10 (sem expor nomes)

### Tools

| Tool | Função |
|------|--------|
| `agregar` | SQL/pandas para agregar interações |
| `gerar_insight` | Gera texto narrativo a partir dos dados |

### Modelo
**DeepSeek Flash** (ModelTier.FAST) — só para gerar narrativa. Processamento
numérico é script Python puro.

---

## 10. Runtime Prompt Loading

### Como funciona

Os prompts de cada modo **não estão no código**. São carregados da **Langfuse**
em runtime via `blu_prompt_management.build_prompt()`:

```python
from blu_prompt_management import build_prompt

prompt = await build_prompt(
    "sales-coach/assessment",   # Langfuse prompt key
    variables={
        "vendedor_nome": "João",
        "ultimo_score": 72,
        "ultimo_relatorio": "Área de melhoria: técnica consultiva...",
    },
    allow_fallback=True,        # Se Langfuse fora, usa builtin
)
```

### Vantagens

- **Prompts ajustáveis sem deploy** — edita na Langfuse, entra em vigor
  na próxima sessão
- **Versionamento** — cada versão do prompt é preservada, pode reverter
- **A/B testing** — labels na Langfuse permitem testar variações
- **Fallback builtin** — se Langfuse estiver fora, usa template embutido
  no código

### Prompts no Langfuse

| Modo | Prompt key | Variáveis | Tamanho esperado |
|------|-----------|-----------|-----------------|
| router | `sales-coach/router` | mensagem, histórico | ~200 tokens |
| assessment | `sales-coach/assessment` | vendedor_nome, ultimo_score, eixos | ~800 tokens |
| roleplay | `sales-coach/roleplay` | diagnostico, perfil_funil, objeção | ~600 tokens |
| consultor | `sales-coach/consultor` | situacao, curso, objeção | ~400 tokens |
| analytics | `sales-coach/analytics` | dados_agregados | ~500 tokens |

---

## 11. Base de Dados Semântica

### 11.1 Pipeline de ingestão

```
1. Receber arquivos da Cruzeiro (PDF, DOCX, MD, links)
2. Extrair texto via blu_parsers
3. Chunk semântico: por seção, ~1000 tokens
4. Embedding via CohereEmbeddingClient (blu_llm_service)
5. Inserir em Supabase pgvector (tabela knowledge_chunks)
```

### 11.2 Schema

```sql
create table knowledge_chunks (
  id uuid primary key default gen_random_uuid(),
  colecao text not null,          -- 'portfolio-academico', 'mapa-objecoes', etc.
  conteudo text not null,
  embedding vector(1024),          -- Cohere embed-multilingual-v3.0
  fonte text,                      -- nome do arquivo / url
  metadata jsonb,                  -- { curso, eixo, secao, ... }
  created_at timestamptz default now()
);
```

### 11.3 Coleções

| Coleção | Prioridade | Tamanho | Usada por | Depende de |
|---------|-----------|---------|-----------|-----------|
| `portfolio-academico` | P0 | ~50 | assessment, roleplay, consultor | Cruzeiro (workshop) |
| `mapa-objecoes` | P0 | ~30 | roleplay, consultor | Cruzeiro |
| `calibracao-oferta` | P0 | ~15 | consultor | Cruzeiro |
| `roteiros-vendas` | P1 | ~20 | assessment, roleplay | Cruzeiro |
| `perfis-prospect` | P1 | ~10 | roleplay | Gerado pelo Lucas |

---

## 12. Router (Intent Classifier)

O router é a primeira parada de toda mensagem. Não é um agente separado — é
uma função leve que:

1. Verifica se o vendedor já está em um modo ativo (sessão assessment em
   andamento)
2. Se sim → mantém o modo (0 chamadas LLM extras)
3. Se não → classifica a intenção com 1 chamada LLM leve

### Classificação de intenção

```python
intencoes = {
    "assessment": "avaliação, teste, começar, primeira vez",
    "roleplay": "treinar, simular, praticar, cenário, vamos",
    "consultor": "preciso de ajuda, como responder, agora",
    "menu": "o que você faz, menu, ajuda, opções",
    "fallback": "nenhuma das acima",
}
```

Implementado como `build_prompt("sales-coach/router", variables={...})` +
parse de JSON.

---

## 13. Sessão e Estado

### Schema

```sql
create table sessoes (
  id uuid primary key default gen_random_uuid(),
  vendedor_id text not null,
  modo_atual text not null,       -- 'assessment' | 'roleplay' | 'consultor' | 'menu'
  modo_dados jsonb,               -- estado interno do modo
  session_id text not null,       -- session_id do Agno
  ultima_interacao timestamptz,
  created_at timestamptz default now()
);
```

A persistência multi-turno do Agno é feita pelo `TenantPostgresDb` do
`blu_agno_runtime.storage` — automático, sem código extra.

---

## 14. Painel da Liderança

**Frontend:** React + Vite + Blu DS + Recharts
**Autenticação:** blu_auth (JWT)
**Rotas:**
- `/` — Dashboard geral
- `/vendedor/:id` — Perfil individual
- `/polo/:id` — Visão do polo
- `/unidade/:id` — Visão da unidade
- `/curso/:id` — Visão por curso

**Integração Teams:** webhook de notificações (resumo semanal, alertas)

---

## 15. Segurança

- **WhatsApp:** vendedores identificados pelo número cadastrado + JWT
- **Painel:** login separado, controle de acesso por role
- **Auditoria:** todas as interações registradas (quem, quando, o que)
- **Privacidade:** scores individuais visíveis apenas ao vendedor e seu coordenador
- **RLS:** isolamento por vendedor/polo no Supabase

---

## 16. Custos de Operação (Pós-implantação)

| Item | Estimativa/mês | Responsável |
|-----|---------------|-------------|
| Twilio WhatsApp | ~$50-200 (150 vendedores) | TEMPLO |
| Groq Whisper (ASR) | ~$30-80 | TEMPLO |
| LLM (DeepSeek Flash + Claude roleplay) | ~$100-300 | TEMPLO |
| Langfuse (prompts + tracing) | ~$50-100 | TEMPLO |
| Supabase (pgvector + storage) | ~$25-50 | TEMPLO |
| Cloud Run (1 imagem) | ~$50-100 | TEMPLO |
| **Total estimado** | **~$305-830/mês** | TEMPLO |

---

## 17. Dependências de Entrega

| Item | Depende de | Prazo crítico |
|------|-----------|--------------|
| Modo Assessment funcional | Base `portfolio-academico` populada | Workshop kickoff (semana 1) |
| Modo Roleplay funcional | Base `mapa-objecoes` + `perfis-prospect` | Workshop kickoff |
| Modo Consultor funcional | Base `calibracao-oferta` + ASR configurado | Semana 2 |
| Modo Analytics funcional | Interações dos outros modos | Semana 3 (começa a acumular dados) |
| Painel funcional | Analytics populado | Semana 3 |
| Deploy produção | Infra TEMPLO pronta (Cloud Run, Supabase, Twilio) | Antes do kickoff |
| Prompts na Langfuse | Setup da Langfuse (TEMPLO) | Semana 1 |

---

## 18. Fora do Escopo (deste PRD)

- Gamificação (ranking, badges, competições entre vendedores)
- Transcrição e análise de reuniões do Teams
- Integração com CRM/ERP/RH da Cruzeiro
- Versão multi-cliente self-service (produto de prateleira)
- App mobile nativo
- Suporte ao usuário final (TEMPLO)
- Manutenção de infraestrutura (TEMPLO)