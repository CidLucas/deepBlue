# ROADMAP — Sales Coach AI (30 dias)

> **D+0 (kickoff):** 01/09/2026 (assumido)
> **Entrega final:** 30/09/2026
> **Dias úteis:** ~22

---

## 1. Restrições contratuais

- Prazo máximo: **30 dias corridos** (01/09 a 30/09)
- Carga de IA: USD 200 (Claude Code 20x) + até USD 800 extras
- Infra (Cloud Run, Supabase, Twilio, banco): responsabilidade TEMPLO
- Base de conhecimento da Cruzeiro: entregue **no workshop de kickoff**
- Rituais: pré-kickoff interno, kickoff, weekly com GP, showcase final

## 2. Fases

### F0 — Setup + Kickoff (D1–D2)

- Pré-kickoff interno (TEMPLO + Lucas)
- Kickoff com Cruzeiro do Sul
- Workshop de calibração: captura da base de conhecimento
- Setup do ambiente de desenvolvimento
- Setup Langfuse para prompts versionados
- **Setup do MCP**: `pip install mcp[cli]`, criação do servidor FastMCP

### F1 — SalesCoachRegistry + Modo Assessment (D3–D8)

- Scaffold do serviço FastAPI + Agno (1 imagem)
- **SalesCoachRegistry**: estrutura de modos + Agent Factory
- Integração Twilio WhatsApp + webhook + Router
- **blu_prompt_management**: carga de prompts da Langfuse em runtime
- Base vetorial: pipeline de ingestão (Supabase pgvector)
- **Modo Assessment**: entrevista conversacional + scoring + relatório via WhatsApp
- Setup dos prompts "sales-coach/router" e "sales-coach/assessment" na Langfuse

### F2 — Modos Roleplay + Consultor (D9–D15)

- **Modo Roleplay**: geração de cenário + simulação + feedback
- **Modo Consultor**: ASR (Groq Whisper) + OCR + sugestão em tempo real
- Router inteligente: classificação de intenção entre modos
- Sessão persistente (TenantPostgresDb)
- Setup dos prompts "sales-coach/roleplay" e "sales-coach/consultor" na Langfuse

### F3 — Modo Analytics + Painel (D16–D22)

- **Modo Analytics**: pipeline de agregação (cron diário)
- Setup do prompt "sales-coach/analytics" na Langfuse
- Painel da liderança: API + frontend React
- Autenticação (blu_auth)

### F4 — Integração + Homologação (D23–D30)

- Integração Teams (notificações)
- Testes integrados + QA em ambiente TEMPLO
- Homologação com squad piloto (ajustes finos)
- Showcase de apresentação de resultados

## 3. Gantt

```mermaid
gantt
    title Sales Coach AI — 30 dias (D+0 = kickoff)
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m

    section F0 — Setup
    Pré-kickoff interno (TEMPLO×Lucas)     :done,  f0a, 2026-09-01, 1d
    Kickoff + Workshop Cruzeiro             :active,f0b, 2026-09-02, 2d

    section F1 — Assessment
    Scaffold FastAPI + Agno + Twilio        :      f1a, 2026-09-03, 2d
    Pipeline ingestão base vetorial         :      f1b, 2026-09-04, 2d
    Agent Assessment (entrevista + scoring) :      f1c, 2026-09-06, 3d
    Relatório individual + envio WhatsApp   :      f1d, 2026-09-09, 1d

    section F2 — Roleplay + Consultor
    Agent Roleplay (cenário + simulação)    :      f2a, 2026-09-10, 3d
    Feedback estruturado (técnica/escuta/fechamento) :f2b, 2026-09-13, 1d
    ASR Groq Whisper + OCR                  :      f2c, 2026-09-14, 1d
    Agent Consultor (sugestão em tempo real) :      f2d, 2026-09-15, 2d

    section F3 — Analytics + Painel
    Agent Analytics (agregação + cron)      :      f3a, 2026-09-17, 2d
    Painel liderança (API + React + Charts) :      f3b, 2026-09-19, 4d
    Autenticação + login (blu_auth)          :      f3c, 2026-09-22, 1d

    section F4 — Homologação
    Integração Teams (notificações)         :      f4a, 2026-09-23, 2d
    Testes integrados + QA                  :      f4b, 2026-09-25, 2d
    Homologação squad piloto + ajustes      :      f4c, 2026-09-27, 3d

    section Marcos
    M1 Assessment funcional                 :milestone, m1, 2026-09-09, 0d
    M2 Roleplay + Consultor OK              :crit, milestone, m2, 2026-09-16, 0d
    M3 Painel no ar                         :milestone, m3, 2026-09-22, 0d
    M4 Entrega + Showcase                   :crit, milestone, m4, 2026-09-30, 0d
```

## 4. Marcos

| Marco | Data | Critério de sucesso |
|-------|------|---------------------|
| M1 — Assessment funcional | 09/09 | Entrevista completa rodando via WhatsApp, score gerado, relatório enviado |
| M2 — Roleplay + Consultor OK | 16/09 | Cenário gerado, simulação funcional, feedback emitido, áudio transcrito, sugestão devolvida |
| M3 — Painel no ar | 22/09 | Painel web com dados reais (métricas dos agentes), autenticado |
| M4 — Entrega + Showcase | 30/09 | Sistema completo em produção, squad piloto treinado, apresentação de resultados |

## 5. Riscos do Roadmap

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Base de conhecimento não entregue no workshop | Atraso no assessment (F1) | Baseline mínimo de 10 cursos para começar; preencher o resto depois |
| Infra TEMPLO não pronta (Twilio, Cloud Run, Supabase) | Bloqueia deploy | Setup de dev local (Supabase local, Twilio sandbox) para não parar |
| OCR de imagens de baixa qualidade | Consultor com foto não funciona | MVP do consultor só texto + áudio; foto como P2 |
| Squads piloto com baixa adesão | Homologação inconclusiva | Coordenadores engajarem os vendedores top 10 primeiro |
| Complexidade dos 4 agentes em 30 dias | Escopo estoura prazo | Priorizar F1 + F2 (assessment + roleplay); F3 (painel) versão simplificada; F4 (Teams) fase tardia |