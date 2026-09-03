# PRD — Sales Coach AI (Cruzeiro do Sul)

> **Product Requirements Document — v0.1**
> **Data:** 2026-09-03
> **Prazo:** 30 dias (01/09 — 30/09/2026)
> **Responsável técnico:** Lucas Cid (Deep Blue)
> **Parceiro:** TEMPLO (infra, GP, AI Officer, custos IA)

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

**Framework de agentes:** Agno 2.6+
**Factory de agentes:** `blu_agno_runtime` (lib Deep Blue)
**Backend:** FastAPI + Supabase + Twilio
**LLMs:** DeepSeek Flash (assessment, consultor, analytics), Claude (roleplay)
**ASR:** Groq Whisper (via `blu_llm_service.asr`)
**Base vetorial:** Supabase pgvector (chunk + Cohere embeddings)
**Frontend:** React + Vite + Blu DS + Recharts
**Autenticação:** `blu_auth` (JWT)

## 4. Agentes

### 4.1 Orchestrator Agent

#### Goal
Rotear mensagens do WhatsApp para o agente especializado correto, mantendo o
estado da conversa e garantindo fallback adequado.

#### Intenções reconhecidas

| Intenção | Gatilho | Roteia para |
|----------|---------|-------------|
| `assessment` | "Quero fazer avaliação" ou primeira mensagem do vendedor | Agent Assessment |
| `roleplay` | "Vamos treinar", "simular atendimento" | Agent Roleplay |
| `consultor` | Contém áudio, foto, ou "preciso de ajuda agora", "como responder" | Agent Consultor |
| `relatorio` | "Meu relatório", "quero ver meu score" | Agent Assessment (get_report) |
| `menu` | "O que você faz?", "menu", "ajuda" | Orchestrator (responde menu) |
| `fallback` | Nenhuma das acima, ou mensagem genérica | Orchestrator (pergunta objetivo) |

#### Skills necessárias

- `intent_classifier` — classifica a intenção da mensagem em <500ms
- `state_manager` — gerencia em qual modo/fase o vendedor está (sessão)
- `fallback_handler` — responde educadamente quando não entende

#### Base vetorial necessária

Não. A classificação de intenção é feita por LLM (prompt leve) + histórico
de sessão.

#### Esquema de sessão

```json
{
  "vendedor_id": "v-123",
  "numero_whatsapp": "+5511999999999",
  "modo_atual": "assessment" | "roleplay" | "consultor" | "menu",
  "agent_atual": "assessment" | "roleplay" | "consultor" | null,
  "session_id": "sess-abc-123",
  "assessment_id": "ass-001" | null,
  "roleplay_id": "rp-001" | null,
  "historico": [{"papel": "vendedor"|"coach", "mensagem": "...", "timestamp": "..."}]
}
```

#### Fluxo de mensagem

```
1. Twilio envia POST para /webhook/twilio
2. API decodifica mensagem (texto, mídia, áudio)
3. blu_auth identifica vendedor pelo número
4. Orchestrator consulta estado da sessão
5. Classifica intenção (LLM, prompt leve)
6. Se modo ativo (assessment em andamento): roteia para o agente atual
7. Se nova conversa: classifica intenção e roteia
8. Resposta do agente → Twilio → WhatsApp do vendedor
```

---

### 4.2 Agent Assessment

#### Goal
Conduzir uma entrevista conversacional de ~20 minutos avaliando o vendedor em
conhecimento de oferta, técnica consultiva e orientação ao prospect. Gerar
relatório individual com score e recomendações.

#### ACs (Acceptance Criteria)

1. **AC01 — Início da entrevista:** Ao entrar em modo assessment, o agente
   saúda o vendedor e inicia com uma pergunta aberta sobre sua experiência
2. **AC02 — Adaptação dinâmica:** As perguntas seguintes devem se adaptar
   com base nas respostas anteriores (não é questionário fixo)
3. **AC03 — Perguntas objetivas:** A cada 3-4 respostas, o agente insere
   uma pergunta de multiple-choice para calibrar conhecimento específico
4. **AC04 — Eixos de avaliação:** O agente cobre obrigatoriamente:
   conhecimento de oferta (40%), técnica consultiva (35%), orientação ao
   prospect (25%)
5. **AC05 — Duração:** A entrevista tem entre 15 e 25 perguntas, adaptável
   conforme a qualidade das respostas
6. **AC06 — Interrupção:** O vendedor pode pausar e retomar (sessão persistida)
7. **AC07 — Geração de score:** Ao final, o agente calcula score de 0-100
   em cada eixo + score geral ponderado
8. **AC08 — Relatório:** Gera relatório individual com: scores, áreas fortes,
   áreas de melhoria, recomendações de roleplay específicas
9. **AC09 — Envio:** Envia o relatório via WhatsApp com link (PDF ou HTML
   hospedado)
10. **AC10 — Periodicidade:** O assessment pode ser repetido semanalmente
    (para medir evolução)

#### Skills necessárias

| Skill | Função | Base vetorial |
|-------|--------|---------------|
| `gerador_perguntas` | Gera a próxima pergunta baseada no histórico e perfil do vendedor | `portfolio-academico` (para perguntas sobre cursos) |
| `scoring_multi_eixo` | Pontua a resposta do vendedor em 3 eixos (0-100) | — |
| `avaliador_conhecimento` | Verifica se a resposta do vendedor está alinhada com o conteúdo real da Cruzeiro | `portfolio-academico` |
| `adaptador_dificuldade` | Aumenta/diminui dificuldade baseado no desempenho | — |
| `gerador_relatorio` | Monta o relatório individual com scores, análise textual e recomendações | — |
| `detector_interrupcao` | Gerencia pausa e retomada da entrevista | — |

#### Base vetorial necessária

| Coleção | Uso | Tamanho |
|---------|-----|---------|
| `portfolio-academico` | Validar respostas sobre cursos, preços, eixos, concorrência | ~50 chunks |
| `roteiros-vendas` | Referência para técnica consultiva (o que é uma boa pergunta) | ~20 chunks |

#### Modelo recomendado

**DeepSeek Flash** — o assessment é longo (20 perguntas = ~20 chamadas LLM).
DeepSeek Flash custa ~1/10 do Claude e tem boa performance em PT-BR.

---

### 4.3 Agent Roleplay

#### Goal
Gerar cenários únicos de prospect simulado com base no diagnóstico do vendedor
e no perfil do funil. Conduzir a simulação e gerar feedback estruturado.

#### ACs

1. **AC01 — Geração de cenário:** Ao entrar em modo roleplay, o agente gera
   um cenário com persona (nome, empresa, cargo, dor), contexto de abordagem
   e objeção específica
2. **AC02 — Personalização:** O cenário deve ser baseado no diagnóstico do
   vendedor (assessment mais recente) e no perfil do funil (curso, etapa,
   objeção comum)
3. **AC03 — Variabilidade:** Cada sessão de roleplay deve gerar um cenário
   diferente (nunca repetir o mesmo)
4. **AC04 — Simulação:** O agente atua como o prospect, respondendo de forma
   realista (resistência, dúvidas, hesitações)
5. **AC05 — Intervenção:** Se o vendedor se desviar muito, o agente oferece
   uma dica ("Lembre-se de fazer uma pergunta aberta...")
6. **AC06 — Feedback estruturado:** Após 5-10 interações, o agente encerra
   e gera feedback em 3 eixos:
   - Técnica: usou SPIN selling / consultiva? (score 0-100)
   - Escuta: capturou as dores do prospect? (score 0-100)
   - Fechamento: conduziu para próximo passo? (score 0-100)
7. **AC07 — Sugestão:** Cada eixo com feedback textual + sugestão concreta
   de melhoria
8. **AC08 — Relatório:** Acumula histórico de roleplays do vendedor para
   mostrar evolução ao longo do tempo

#### Skills necessárias

| Skill | Função | Base vetorial |
|-------|--------|---------------|
| `gerador_cenario` | Gera persona, contexto e objeção a partir do diagnóstico | `perfis-prospect`, `mapa-objecoes` |
| `simulador_prospect` | Atua como o prospect na conversa | `mapa-objecoes` |
| `avaliador_roleplay` | Avalia técnica, escuta e fechamento após a simulação | — |
| `detector_desvio` | Detecta quando o vendedor está fora do roteiro e oferece dica | — |
| `gerador_feedback` | Monta feedback textual + score por eixo | — |
| `variador_cenario` | Garante que o cenário nunca repete o mesmo perfil | — |

#### Base vetorial necessária

| Coleção | Uso | Tamanho |
|---------|-----|---------|
| `mapa-objecoes` | Gerar objeções realistas baseadas em situações reais | ~30 chunks |
| `perfis-prospect` | Personas variadas por curso e perfil de funil | ~10 chunks |
| `roteiros-vendas` | Referência do que é uma boa técnica de venda (para avaliar) | ~20 chunks |

#### Modelo recomendado

**Claude** — roleplay precisa de nuance, realismo na atuação como prospect e
feedback qualitativo rico. O custo é justificado pela qualidade da simulação.

---

### 4.4 Agent Consultor (Real-time)

#### Goal
Receber áudio/foto/texto do vendedor durante um atendimento real e devolver
argumento sugerido, contra-objeção e combinação de oferta em <5 segundos.

#### ACs

1. **AC01 — Entrada multimodal:** Aceita texto, áudio (transcrição via Groq
   Whisper) e foto (texto em imagem via OCR)
2. **AC02 — Análise de contexto:** Interpreta a situação: que curso, qual
   objeção, qual momento do funil
3. **AC03 — Argumento sugerido:** Devolve um argumento de venda específico
   para a situação
4. **AC04 — Contra-objeção:** Sugere uma pergunta ou contra-argumento para
   rebater a objeção
5. **AC05 — Combinação de oferta:** Se aplicável, sugere combo, desconto ou
   oferta especial que ajude a fechar
6. **AC06 — Tempo de resposta:** <5 segundos (o vendedor está com o prospect)
7. **AC07 — Tom de sugestão:** "Tente dizer: ...", não respostas prontas
8. **AC08 — Histórico:** Mantém contexto das últimas consultas do vendedor
   para consistência
9. **AC09 — Fallback:** Se não entender a situação, pede mais contexto em
   vez de chutar

#### Skills necessárias

| Skill | Função | Base vetorial |
|-------|--------|---------------|
| `transcritor_audio` | Transcreve áudio via Groq Whisper | — |
| `extrator_imagem` | Extrai texto de foto (OCR) | — |
| `analisador_contexto` | Identifica curso, objeção, momento do funil | `portfolio-academico`, `mapa-objecoes` |
| `sugestor_argumento` | Gera argumento de venda específico | `portfolio-academico`, `calibracao-oferta` |
| `sugestor_contra_objeção` | Gera pergunta/contra-argumento | `mapa-objecoes` |
| `combinador_oferta` | Sugere combo, desconto ou oferta | `calibracao-oferta` |
| `detector_urgencia` | Se vendedor manda várias msg em curto intervalo, prioriza | — |

#### Base vetorial necessária

| Coleção | Uso | Tamanho |
|---------|-----|---------|
| `mapa-objecoes` | Base principal para contra-objeções | ~30 chunks |
| `calibracao-oferta` | Combos, descontos, diferenciais por concorrente | ~15 chunks |
| `portfolio-academico` | Detalhes do curso para argumentação | ~50 chunks |

#### Modelo recomendado

**DeepSeek Flash** — resposta rápida (<5s), baixo custo, consultas pontuais.
Cada chamada é curta (1-3 parágrafos).

---

### 4.5 Agent Analytics

#### Goal
Processar todas as interações dos agentes anteriores e gerar métricas
agregadas para o painel da liderança.

#### ACs

1. **AC01 — Processamento diário:** Roda uma vez ao dia (cron) processando
   as interações do dia anterior
2. **AC02 — Agregação multidimensional:** Gera métricas por:
   - Vendedor: score geral + por eixo, evolução temporal, roleplays feitos,
     consultas feitas, engajamento
   - Polo: média dos scores, ranking interno, top/bottom 3
   - Unidade: média da unidade, comparativo entre polos
   - Curso: dificuldade de venda por curso, objeções mais comuns
3. **AC03 — Séries temporais:** Cada métrica mantém histórico (dia/semana/mês)
   para mostrar evolução
4. **AC04 — Narrativa:** Gera um parágrafo de insight narrativo por agregado
   ("O polo Campinas teve um aumento de 12% no score de consultiva este mês...")
5. **AC05 — Alertas:** Detecta vendedores com queda abrupta de score e gera
   alerta para o coordenador
6. **AC06 — Rankings:** Top 10 vendedores e bottom 10 (sem expor nomes fora
   da liderança)

#### Skills necessárias

| Skill | Função | Base vetorial |
|-------|--------|---------------|
| `agregador_dados` | SQL/pandas para agregar interações | — |
| `calculador_serie_temporal` | Mantém e calcula séries por dia/semana/mês | — |
| `gerador_insight` | Gera texto narrativo a partir dos dados | — |
| `detector_anomalia` | Detecta quedas/subidas abruptas | — |
| `formatador_painel` | Prepara dados no formato esperado pelo frontend | — |

#### Base vetorial necessária

Não. Analytics é puramente tabular/agregacional.

#### Modelo recomendado

**DeepSeek Flash** — só para gerar narrativa. O processamento numérico é
feito por script Python (zero LLM).

---

## 5. Base de Dados Semântica — Requisitos Detalhados

### 5.1 Pipeline de ingestão

```
1. Receber arquivos da Cruzeiro (PDF, DOCX, MD, links do Google Docs)
2. Extrair texto via blu_parsers
3. Chunk semântico: dividir por seção (##), limite de 1000 tokens por chunk
4. Embedding via CohereEmbeddingClient (blu_llm_service)
5. Inserir em Supabase pgvector (tabela: knowledge_chunks)
```

### 5.2 Schema da tabela `knowledge_chunks`

```sql
create table knowledge_chunks (
  id uuid primary key default gen_random_uuid(),
  colecao text not null,  -- 'portfolio-academico', 'mapa-objecoes', etc.
  conteudo text not null,
  embedding vector(1024),   -- Cohere embed-multilingual-v3.0
  fonte text,               -- nome do arquivo / url
  metadata jsonb,           -- { curso, eixo, secao, pagina, ... }
  created_at timestamptz default now()
);
```

### 5.3 Coleções e prioridade

| Coleção | Prioridade | Depende de |
|---------|-----------|-----------|
| `portfolio-academico` | **P0** — sem isso, assessment não funciona | Entrega da Cruzeiro no workshop |
| `mapa-objecoes` | **P0** — roleplay + consultor dependem | Entrega da Cruzeiro |
| `calibracao-oferta` | **P0** — consultor dependente | Entrega da Cruzeiro |
| `roteiros-vendas` | **P1** — assessment usa mas pode começar sem | Entrega da Cruzeiro |
| `perfis-prospect` | **P1** — roleplay pode usar perfis genéricos inicialmente | Gerado pelo Lucas |

## 6. Interfaces

### 6.1 WhatsApp (via Twilio) — Principal

| Tipo de mídia | Ação |
|-------------|------|
| Texto | Mensagem normal → Orchestrator classifica e roteia |
| Áudio | `.ogg` via WhatsApp → Groq Whisper → texto → Agent Consultor |
| Imagem | `.jpeg/.png` → OCR → texto → Agent Consultor |

### 6.2 Painel Web — Liderança

**Stack:** React + Vite + Blu DS + Recharts
**Rotas:**
- `/` — Dashboard geral
- `/vendedor/:id` — Perfil individual
- `/polo/:id` — Visão do polo
- `/unidade/:id` — Visão da unidade
- `/curso/:id` — Visão por curso

### 6.3 Microsoft Teams — Complementar

- Envio de notificações via webhook (resumo semanal, alertas)
- Opção de abrir o painel via deep link do Teams
- **Fora do escopo atual:** transcrição de reuniões e correlação com matrícula

## 7. Segurança e Autenticação

### 7.1 Vendedores (WhatsApp)
- Identificação pelo número de WhatsApp cadastrado
- Sessão JWT gerada na primeira interação (via `blu_auth`)
- Token de sessão renovado periodicamente

### 7.2 Liderança (Painel Web)
- Login via email + senha / OAuth2
- Controle de acesso por role (coordenador vê seu polo, gerente vê múltiplos)
- Sessão JWT via `blu_auth`

### 7.3 Auditoria
- Todas as interações registradas (quem, quando, o que)
- Scores e relatórios imutáveis após geração
- Log de acesso ao painel

## 8. Custos de Operação (Pós-implantação)

| Item | Estimativa/mês | Responsável |
|-----|---------------|-------------|
| Twilio WhatsApp | ~$50-200 (150 vendedores) | TEMPLO |
| Groq Whisper (ASR) | ~$30-80 | TEMPLO |
| LLM (DeepSeek Flash + Claude) | ~$100-300 | TEMPLO |
| Supabase (pgvector + storage) | ~$25-50 | TEMPLO |
| Cloud Run | ~$50-100 | TEMPLO |
| **Total estimado** | **~$250-730/mês** | TEMPLO |

## 9. Dependências Entrega

| Item | Depende de | Prazo crítico |
|------|-----------|--------------|
| Assessment funcional | Base `portfolio-academico` populada | Workshop kickoff (semana 1) |
| Roleplay funcional | Base `mapa-objecoes` + `perfis-prospect` populadas | Workshop kickoff |
| Consultor funcional | Base `calibracao-oferta` + ASR configurado | Semana 2 |
| Painel funcional | Agentes Analytics + métricas populadas | Semana 3 |
| Deploy produção | Infra TEMPLO pronta (Cloud Run, Supabase, Twilio) | Antes do kickoff |

## 10. Fora do Escopo (deste PRD)

- Gamificação (ranking, badges, competições entre vendedores)
- Transcrição e análise de reuniões do Teams
- Integração com CRM/ERP/RH da Cruzeiro
- Versão multi-cliente self-service (produto de prateleira)
- App mobile nativo
- Suporte ao usuário final (TEMPLO)
- Manutenção de infraestrutura (TEMPLO)