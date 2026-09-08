# Status — Cladtek

> Última atualização: 2026-09-08
> **Contrato:** Templo × Cladtek, 24 semanas, R$ 61.300 (3 parcelas)
> **Lucas:** responsável técnico
> **Templo:** GP + AI Officer + infra

> ✅ **PROJETO ATIVO (decisão do dono, 08/09/2026).** Rodando sobre o **blu_agno_runtime** do monorepo (mesma base dos projetos SENAC e Cruzeiro do Sul).

## 🩺 Saúde geral

🟢 **Ativo** — escopo contratual definido. Em preparação técnica sobre o runtime compartilhado.

## 📊 Resumo executivo

| Item | Status |
|---|---|
| **Contrato Templo × Cladtek** | 🟢 ativo |
| **Contrato Lucas × Templo** | 🟢 escopo formalizado (29/07) |
| **Data de kickoff (D+0)** | 🟡 a definir |
| **PRD v0.1** | 🟢 criado ([docs/PRD.md](./docs/PRD.md)) |
| **ROADMAP v0.1 (Gantt)** | 🟢 criado ([docs/ROADMAP.md](./docs/ROADMAP.md)) |
| **Stack escolhida** | 🟢 blu_agno_runtime (Agno) — compartilhado |
| **Repo de código** | 🟢 bootstrap criado ([CidLucas/cladtek](https://github.com/CidLucas/cladtek)) |

## 🎯 Escopo do contrato

Sistema agêntico **único e integrado** (interface própria com login, dashboard, histórico e rastreabilidade, para ~20 usuários) com **2 casos de uso**:

### Caso 1 — Revisão e aprovação de desenhos técnicos
- Leitura de desenhos (SolidWorks/PDL/PDF)
- Verificação de cotas, tolerâncias e notas técnicas contra parâmetros Cladtek
- Laudo de conformidade + revisão humana
- Outputs: relatórios por área, bot consultor, dashboard agregado

### Caso 2 — Análise crítica de BID
- Leitura e interpretação de RFQs
- Cruzamento com capacidades/procedimentos internos da Cladtek
- Geração de Technical Comment com validação humana em sandbox
- Outputs: relatórios por área, bot consultor, dashboard agregado

### Escopo técnico (Lucas)
- Workflow de agentes em N8N
- Interface da aplicação
- Base de dados semântica
- Integração de dados via APIs (sem integrações customizadas para sistemas internos)
- Login/autenticação
- Suporte no discovery e workshops/entrevistas

### Condições contratuais
- **Prazo máximo:** 24 semanas (entrega intermediária 12s, discovery 4s)
- **Valor:** R$ 61.300,00 (3 parcelas, liberadas após Templo receber do cliente)
- **Custos IA:** Templo cobre até R$ 10.000 (total 2 projetos), teto R$ 3.000/mês
- **Rituais:** kickoff presencial, pré-kickoff interno, weekly (GP + cliente alternado), workshop discovery, até 10 entrevistas, showcase

### Fora do escopo do Lucas
- Integração ao Orchestra — **Templo fará após este contrato** ou negociará à parte
- Infraestrutura e ambiente de produção (Templo)
- Direção técnica / Chief AI Officer (Templo)
- Atendimento ao cliente e gestão de projeto (GP Templo)
- Design system da interface (Templo)

## 🚧 Blockers / Riscos

| Blocker | Impacto | Status |
|---|---|---|
| Contrato Cladtek não assinado | Projeto não pode começar | ⏳ 15-30 dias |
| Sem acesso a dados reais (desenhos, RFQs) | Discovery não pode começar | 🔴 |

## 🎯 Próximas ações (pré-ativação)

- [ ] **Lucas** — aguardar assinatura do contrato Cladtek (15-30 dias)
- [x] ~~Hermes — criar PRD.md com os 2 casos de uso~~ ✅
- [x] ~~Hermes — criar ROADMAP.md com Gantt~~ ✅
- [x] ~~Lucas — mapear stack: N8N vs Agno~~ → **Agno confirmado**
- [ ] **Lucas** — solicitar ao Templo design system da interface

## ❓ Perguntas em aberto

**Críticas (bloqueiam F1):**
1. ~~N8N vs Agno~~ → **Agno confirmado (29/07)**
2. Formato real dos desenhos: **SolidWorks** (API nativa extrai dados deterministicamente)
3. O "bot consultor que fala com a base" é similar ao Q&A do SENAC? Mesma stack?
4. ~~Quem é o ponto focal na Cladtek?~~ → ainda não definido

**Importantes (definem arquitetura):**
5. "Integração simples" de dados — quais fontes? S3? SFTP? API REST própria?
6. O "bot consultor" é o mesmo para os 2 casos de uso ou agents separados?
7. Auth: **proprietário da Cladtek** ✅
8. Os dois casos de uso compartilham a mesma interface ou abas/seções diferentes?
9. LLM: pode não precisar de visão (API SolidWorks extrai dados deterministicamente). Avaliar no discovery.

**De produto:**
9. ~20 usuários — são todos engenheiros revisores? Ou inclui gestão?
10. "Relatórios em diferentes documentos para diferentes áreas" — quais áreas e formatos?
11. Métricas de sucesso: SLA atual de revisão de desenho? Meta?

## 📅 Histórico de atualizações

| Data | Atualização |
|---|---|
| 2026-07-29 | Contrato formalizado pelo Templo: escopo completo (2 casos de uso, R$ 61.300, 3 parcelas). |
| 2026-07-29 | STATUS.md reescrito — antes dizia "escopo não definido"; agora reflete contrato real. |
| 2026-07-22 | Criação do projeto. Pasta + docs placeholder. |

---

## 🔜 Próxima conversa — quando você voltar

Sugestão de pauta (você ajusta):

1. ~~N8N vs Agno~~ → **Agno confirmado.**
2. **Dados reais** — como conseguir amostras antes do contrato assinar?
3. **Revisão do PRD** — validar os 2 casos de uso descritos
4. **Priorização** — enquanto aguarda Cladtek, foco 100% no SENAC?
