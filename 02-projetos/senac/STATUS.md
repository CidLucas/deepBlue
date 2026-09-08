# Status — SENAC

> Última atualização: 2026-09-08
> **Contrato:** Templo × SENAC, 24 semanas, R$ 18.200 (pagamento final)
> **Lucas:** responsável técnico
> **Templo:** GP + AI Officer + infra

> ✅ **PROJETO ATIVO (decisão do dono, 08/09/2026).** Rodando sobre o **blu_agno_runtime** do monorepo (mesma base dos projetos Cladtek e Cruzeiro do Sul).

## 🩺 Saúde geral

🟢 **Ativo** — contrato assinado (29/07). Em preparação técnica sobre o runtime compartilhado.

## 📊 Resumo executivo

| Item | Status |
|---|---|
| **Contrato Templo × SENAC** | 🟢 **assinado (29/07)** |
| **Contrato Lucas × Templo** | 🟢 escopo formalizado (29/07) |
| **Data de kickoff (D+0)** | 🟡 a agendar — D+1 da conversa de alinhamento |
| **PRD v0.1** | 🟢 criado ([docs/PRD.md](./docs/PRD.md)) |
| **ROADMAP v0.1 (24 sem + Gantt)** | 🟢 criado ([docs/ROADMAP.md](./docs/ROADMAP.md)) |
| **Stack escolhida** | 🟢 blu_agno_runtime (Agno) — compartilhado |
| **Acesso ao SAVE** | 🔴 não |
| **Repo de código** | 🟢 bootstrap criado ([CidLucas/senac](https://github.com/CidLucas/senac)) |

## 🎯 Escopo do contrato (atualizado 29/07)

### O que o sistema faz
Sistema agêntico que automatiza a geração de **relatórios pedagógicos** a partir dos **diários de classe** (exportados do SAVE):

1. **Upload e processamento** dos dados do SAVE
2. **Cruzamento** de dados quantitativos + qualitativos por aluno conforme a **matriz de competências**
3. **Geração** de relatório no formato oficial (introdução + 5 capítulos), **editável** para a equipe pedagógica validar
4. **Dashboard/painel** de visualização, revisão e exportação
5. **Agent conversacional** que fala com a base agregada
6. **Relatório individual por aluno + dashboard agregado interativo**

### Condições contratuais
- **Prazo máximo:** 24 semanas (entrega intermediária 12s, discovery 4s)
- **Valor:** R$ 18.200,00 (pagamento único ao final, após Templo receber do SENAC)
- **Custos IA:** Templo cobre até R$ 10.000 (total 2 projetos), teto R$ 3.000/mês
- **Rituais:** kickoff presencial, pré-kickoff interno, weekly (GP + cliente alternado), workshop discovery, até 10 entrevistas, showcase

### Fora do escopo do Lucas
- Integração ao Orchestra — **Templo fará após este contrato** ou negociará à parte
- Infraestrutura e ambiente de produção (Templo)
- Direção técnica / Chief AI Officer (Templo)
- Atendimento ao cliente e gestão de projeto (GP Templo)
- Design system da interface (Templo)
- Custos de IA (tokens, licenças)

> ⚠️ **Fase 1 de setup** — expectativa de virar contrato de recorrência integrado ao Orchestra (fora do escopo do Lucas).

## 🚧 Blockers / Riscos

| Blocker | Impacto | Status |
|---|---|---|
| Sem acesso ao SAVE | Discovery não pode começar | 🔴 |

## 🎯 Próximas ações (pré-ativação)

- [ ] **Lucas** — aguardar assinatura do contrato SENAC (~1 semana)
- [ ] **Lucas** — alinhar com Templo a data do kickoff assim que assinar
- [ ] **Lucas** — solicitar ao Templo credenciais OCI GenAI + Vector Store
- [ ] **Lucas** — solicitar ao SENAC acesso ao SAVE (formato + amostras reais)
- [ ] **Hermes** — quando D+0 definido, ajustar Gantt e abrir issues F0

## ❓ Perguntas em aberto

**Críticas (bloqueiam F1):**
1. Data do kickoff com SENAC? — Aguardando Templo agendar (D+1)
2. ~~Quem é o GP do Templo e o AI Officer?~~ → ainda não definidos (Templo vai informar)
3. ~~Quem será o ponto focal no SENAC?~~ → ainda não definido

**Importantes (definem arquitetura):**
4. SAVE: muito provavelmente **CSV + docs não estruturados** (notas → base vetorial). Confirmar com acesso real.
5. Matriz de competências: vem no export ou é planilha separada?
6. Formato final do relatório editável: **Google Docs API ou .docx** — em aberto, definir no discovery
7. Auth: **SSO do SENAC** ✅

**De produto:**
8. Turma-piloto: 1 turma acordada com o SENAC?
9. Métricas de sucesso: confirmadas (NPS, tempo, taxa de aproveitamento)?
10. SLA esperado (geração em < 60s é viável com o LLM escolhido)?

## 📅 Histórico de atualizações

| Data | Atualização |
|---|---|
| 2026-07-29 | **Contrato SENAC assinado.** Projeto avança para pré-kickoff. |
| 2026-07-29 | Respostas parciais do Lucas: SAVE = CSV + docs não estruturados, auth = SSO SENAC. |
| 2026-07-22 | Criação do projeto. Pasta + docs placeholder. |
| 2026-07-22 | Recebido escopo contratual (Templo × SENAC, 24 sem, R$ 18.200). |
| 2026-07-22 | Criado PRD v0.1 ([docs/PRD.md](./docs/PRD.md)). |
| 2026-07-22 | Criado ROADMAP v0.1 com Gantt Mermaid ([docs/ROADMAP.md](./docs/ROADMAP.md)). |
| 2026-07-22 | Renomeado: repo CidLucas/cnac → CidLucas/senac; pasta cnac/ → senac/. |
| 2026-07-22 | **Decisão: foco 100% no SENAC nos próximos dias.** Cladtek + MCP Brain em standby. |

---

## 🔜 Próxima conversa — quando você voltar

Sugestão de pauta (você ajusta):

1. **Data do kickoff (D+0)** — assim que SENAC assinar, agendamos
2. **Credenciais OCI** — Templo já provisionou?
3. **Acesso ao SAVE** — formato do export, periodicidade, campos?
4. **Revisão do PRD** — algo mudou com a formalização do contrato?
5. **N8N vs Agno** — o contrato do Cladtek menciona N8N. SENAC mantém Agno?
