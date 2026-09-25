# Status — Sales Coach AI (Cruzeiro do Sul)

> **Última atualização:** 2026-09-08
> **Contrato:** TEMPLO × Cruzeiro do Sul, 12 meses, R$ 40.200,00 (12x R$ 3.350,00)
> **Lucas (Deep Blue):** executor técnico
> **TEMPLO:** GP + AI Officer + infra + custos IA
> **✅ PROJETO ATIVO (decisão do dono, 08/09/2026).** Rodando sobre o **blu_agno_runtime** do monorepo — o Sales Coach é o **cliente que deu origem** ao padrão AgentRegistry + MCP embutido (#752-755).

---

## 🩺 Saúde geral

🟢 **Setup** — escopo definido (REV. 04), documentação completa (PRD, arquitetura v0.3, roadmap), aguardando ativação/infra TEMPLO.

## 📊 Resumo executivo

| Item | Status |
|------|--------|
| Escopo técnico validado | 🟢 sim (REV. 04 da proposta) |
| Documentação de projeto | 🟡 00-escopo criado, expandindo |
| Stack técnica definida | 🟢 **1 imagem + registry (Agno, Langfuse prompts, 4 modos)** |
| Repositório de código | 🔴 não criado |
| Base de conhecimento da Cruzeiro | 🔴 não recebida |
| Workshop de kickoff agendado | 🔴 a definir com TEMPLO |
| Acesso à infra TEMPLO | 🔴 não |
| Número Twilio / WhatsApp verificado | 🔴 a cargo do TEMPLO |

## 🚧 Blockers / Riscos

- **Base de conhecimento:** o cronograma de 30 dias depende da Cruzeiro entregar portfólio acadêmico, roteiros, mapa de objeções e calibração de oferta **no workshop de kickoff**. Sem isso, o assessment não pode ser calibrado.
- **Infra TEMPLO:** setup de produção, domínio, SSL, banco e fila são responsabilidade do TEMPLO — bloqueia deploy se não estiver pronto no kickoff.

## 🎯 Próximas ações (próximos 7 dias)

- [ ] **Lucas** — validar este documento de escopo
- [ ] **Lucas** — confirmar slug `sales-coach-ai` e aprovar estrutura de docs
- [ ] **Hermes** — expandir para PRD.md, ROADMAP.md, 01-visao, 02-arquitetura
- [ ] **Hermes** — criar Google Doc com o escopo para compartilhamento
- [ ] **Lucas** — definir com TEMPLO data do pré-kickoff interno

## ❓ Perguntas em aberto

**Críticas (bloqueiam kickoff):**
1. TEMPLO já tem o contrato assinado com a Cruzeiro do Sul? Qual o status da ativação?
2. Qual a data do workshop de kickoff com a Cruzeiro?
3. A base de conhecimento (portfólio, roteiros, objeções) será entregue até o workshop?

**Importantes (definem arquitetura):**
4. O painel de liderança deve ser um web app responsivo ou um botão no Teams?
5. O design system do TEMPLO tem componentes React prontos ou só brandbook visual?
6. Vamos usar o monorepo (services/sales-coach-api) ou repo separado?

**De produto:**
7. Os 150 vendedores começam o assessment simultaneamente ou em ondas?
8. O consultor em tempo real precisa estar disponível 24h ou só em horário comercial?

## 📅 Histórico de atualizações

| Data | Atualização |
|------|-------------|
| 2026-09-08 | **Projeto ATIVO** (decisão dono). Identificado como cliente original do padrão AgentRegistry do runtime. |
| 2026-09-03 | Bootstrap do projeto — escopo recebido, libs mapeadas, docs iniciados |