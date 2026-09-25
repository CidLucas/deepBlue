# 00 — Escopo e Proposta — Sales Coach AI (Cruzeiro do Sul)

> **Status:** Proposta recebida (REV. 04) — aguardando validação do escopo
> **Data:** 2026-09-03
> **Slug:** `sales-coach-ai`
> **Cliente final:** Cruzeiro do Sul (150 vendedores)
> **Parceiro contratual:** TEMPLO
> **Executor técnico:** Lucas Cid (Deep Blue)

---

## 1. Situação atual

A Cruzeiro do Sul mantém uma força de vendas de **150 vendedores** distribuídos
por polos, unidades e cursos, com capacitação presencial limitada e sem um
mecanismo contínuo de avaliação e treinamento. A liderança não tem visibilidade
granular sobre a evolução individual de cada vendedor.

## 2. O que propomos

Um **sistema agêntico de capacitação de vendas** operando via WhatsApp, cobrindo
quatro frentes integradas:

| # | Frente | Descrição |
|---|--------|-----------|
| 1 | **Assessment estruturado** | Entrevista conversacional de ~20 min via WhatsApp avaliando conhecimento de oferta, técnica consultiva e orientação ao prospect. Relatório individual por vendedor, enviado com link via WhatsApp. |
| 2 | **Roleplay generativo** | Geração de cenários únicos de prospect simulado a partir do diagnóstico do vendedor e do perfil do funil. Feedback estruturado em técnica, escuta e fechamento. |
| 3 | **Consultor em tempo real** | Recebe áudio/foto/texto durante o atendimento real e devolve argumento sugerido, contra-objeção e combinação de oferta. |
| 4 | **Painel para a liderança** | Visão granular por vendedor, polo, unidade e curso, gerada a partir das interações com o Sales Coach. |

## 3. Escopo técnico (Lucas / Deep Blue)

- Workflow de agentes (arquitetura multiagente: assessment, roleplay, consultor, analytics)
- WhatsApp como interface principal (áudio, foto e texto) via **Twilio**
- Microsoft Teams como complemento para a liderança
- Interface do painel de performance (design system: brandbook do TEMPLO, se necessário)
- Base de dados semântica a partir dos arquivos de conhecimento da Cruzeiro do Sul
  (portfólio acadêmico, roteiros, mapa de objeções, calibração de oferta)
- Login/autenticação
- Atualizações de IA ao longo do desenvolvimento (evolução de modelos e fine-tuning)
- Suporte no setup, workshop de kickoff e entrevistas com o cliente

## 4. Fora do escopo (Lucas / Deep Blue)

- Manutenção de infraestrutura — responsabilidade do TEMPLO
- Atendimento ao cliente e suporte ao usuário final — TEMPLO
- Integração com CRM, ERP, RH ou qualquer sistema interno da Cruzeiro do Sul
- Desenvolvimento de conectores customizados
- Transcrição automática de reuniões do Teams e cruzamento com matrícula
- Integração da solução ao Orchestra ou qualquer sistema TEMPLO

## 5. Prazo

- Início: **01/09/2026**
- Implementação em 3 semanas, teto máximo de **30 dias** de desenvolvimento
- Entrega até: **30/09/2026**

## 6. Valor e condições

- Total: **R$ 40.200,00** em **12 parcelas mensais de R$ 3.350,00**
- Cada parcela liberada conforme recebimento da parcela do cliente pelo TEMPLO
  (contrato com a Cruzeiro do Sul também em 12 parcelas)
- Custos de IA por conta do TEMPLO durante o desenvolvimento:
  - 1 pacote Claude Code 20x — USD 200/mês (1 mês)
  - Até USD 800 em custos adicionais de IA (tokens e licenças), se necessário
- Equipamentos e computador: por conta de Lucas Cid

## 7. Rituais de projeto (TEMPLO + Lucas)

- Pré-kickoff interno online
- Kickoff com cliente
- Workshop de Kickoff (calibração de baseline, captura da base de conhecimento,
  definição do squad piloto)
- Reunião semanal online de status com o GP
- Entrevistas de discovery
- Showcase de apresentação de resultados

## 8. Riscos

| Risco | Nível | Mitigação |
|-------|-------|-----------|
| Base de conhecimento da Cruzeiro não entregue a tempo para a calibração | Alto | Workshop de kickoff dedicado à captura; baseline mínimo para começar |
| Twilio WhatsApp em produção com número não verificado | Médio | Setup de infra é TEMPLO; Lucas valida com template de sandbox antes |
| Escopo de 30 dias com 4 agentes + painel é apertado | Alto | Priorizar MVP: assessment + roleplay primeiro; consultor real-time e painel em seguida |
| Custos de IA (USD 800) podem estourar com 150 vendedores ativos | Médio | Monitorar tokens por agente; modelos DeepSeek Flash para assessment/roleplay |
| Integração Teams (complemento liderança) não especificada | Médio | Definir no discovery com o TEMPLO; tratar como fase tardia |

## 9. Próximos passos

1. Validar este escopo com Lucas
2. Expandir para PRD.md + ROADMAP.md (Gantt de 30 dias) + 01-visao + 02-arquitetura
3. Definir stack técnica detalhada (libs do monorepo a reutilizar)
4. Preparar pauta do pré-kickoff interno com o TEMPLO
