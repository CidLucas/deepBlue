# Guanabara — Escopo da Proposta de Serviço

> **Versão:** v0.4 — 2026-07-29
> **Cliente:** Supermercados Guanabara
> **Patrocinador:** Fábio
> **Contrato:** Deep Blue → Guanabara (direto)
> **Investimento:** R$ 60.000 (Fase 0 isolada) ou R$ 200.000 (projeto completo, 12 meses)
> **Status:** Proposta em preparação — houve conversa inicial, ainda não foi apresentada formalmente

---

## 1. Situação atual

O Guanabara opera uma rede com 30+ lojas. Os dados da operação existem, mas estão espalhados por múltiplos sistemas (TOTVS, RP, planilhas de fechamento) e pela memória dos gerentes. Não há um jeito sistemático de capturar e compartilhar o que funciona: o know-how da rede está fragmentado em 30 silos.

Três dores centrais:

| Dor | Sintoma |
|---|---|
| **Conhecimento fragmentado** | O que o gerente da loja 12 faz bem no controle de perecíveis não chega na loja 7. Não há captura nem compartilhamento sistemático de boas práticas. |
| **Visibilidade defasada** | Os números chegam no fechamento do mês e exigem dias de consolidação manual. Quando a diretoria enxerga um desvio, já se passaram semanas. A rede reage no ritmo da planilha, não do negócio. |
| **Diagnóstico sem prescrição** | O BI atual mostra o que aconteceu (queda de margem no setor X, aumento de perda na loja Y), mas não cruza causas com efeitos, não compara lojas equivalentes, e não sugere ações. |

---

## 2. O que propomos

Uma plataforma de inteligência sobre os dados da rede — da loja à decisão — que unifica, compara e prescreve, com a velocidade e granularidade que 30+ lojas exigem.

O projeto é estruturado em três fases:

### Fase 0 — Diagnóstico (Meses 1–3) · R$ 60.000

Mapear o terreno antes de construir. Entender profundamente os processos, identificar onde o resultado vaza e quais práticas diferenciam as lojas de melhor desempenho.

**Atividades:**
- Entrevistas exploratórias com Fábio (patrocinador) e responsáveis de cada área para montar o mapa macro da operação
- Co-design de questionários por função (gerente, perecíveis, frente de caixa, manutenção, RH), cada um focado no que o colaborador vê no dia a dia. Aceitam múltipla escolha, texto livre e áudio
- Aplicação dos questionários em amostra de lojas, com refinamento iterativo conforme padrões emergem. As respostas em áudio serão transcritas via Groq e processadas por agente IA
- Cruzamento das respostas com indicadores operacionais existentes

**Ferramenta de questionários:** site simples com endpoint Groq para transcrição de áudio + agente de processamento (API Deep Blue ou Hermes) para análise das respostas transcritas. Dados já ficam armazenados em base estruturada.

**Entregáveis da Fase 0:**
- Mapa de processos da rede
- Matriz de maturidade comparando todas as lojas
- Relatório de diagnóstico com vazamentos priorizados
- Especificação técnica da plataforma (escopo detalhado para Fases 1 e 2)
- Proposta de investimento revisada para as fases seguintes

> ⚠️ A Fase 0 pode ser contratada como projeto isolado. O escopo e investimento das Fases 1 e 2 são definidos ao final do diagnóstico, com base nos achados reais.

### Fase 1 — Unificar e enxergar (Meses 4–7)

Juntar todos os dados da rede num lugar só e entregar visão comparável entre as 30+ lojas.

**Atividades:**
- Integração de TOTVS, RP e demais fontes (planilhas, CSVs) num data warehouse unificado (PostgreSQL)
- Pipeline de ingestão automatizado: sobe o arquivo, o sistema descobre colunas, mapeia schemas e mantém sincronizado
- Padronização de cadastros entre lojas (nomes de produtos, categorias, centros de custo)
- Painel de comparação entre lojas com métricas normalizadas por faturamento, porte e demais variáveis

**Entregáveis da Fase 1:**
- Banco de dados unificado e documentado
- Pipeline de ingestão automático em produção
- Painel com indicadores atuais + benchmarking entre lojas
- Documentação de padronização de cadastros

### Fase 2 — Entender e agir (Meses 8–12)

Ir além do "o que aconteceu" e chegar no "por que aconteceu e o que fazer a respeito".

**Atividades:**
- Análise de direcionadores de custo: cruzamento do custo operacional com atributos estruturais de cada loja (idade dos equipamentos, localização, perfil de consumo)
- Chat com dados em linguagem natural conectado ao banco unificado
- Relatórios automáticos com desvios destacados e ações sugeridas
- Motor de recomendações que aprende quais práticas estão associadas a melhores resultados
- Agentes de IA que automatizam processos por domínio: análise financeira, CRM de fornecedores, compras e procurement, análise estratégica
- Plataforma web unificada reunindo todos os módulos num ambiente único com autenticação centralizada

**Entregáveis da Fase 2:**
- Modelo de direcionadores de custo (separa custo passivo do gerenciável)
- Interface de chat com dados em linguagem natural
- Sistema de relatórios automáticos (agendados e sob demanda)
- Motor de recomendações conectando práticas a resultados
- Agentes de IA por domínio em produção
- Plataforma unificada com todos os módulos integrados

---

## 3. Entregáveis por fase

Cada fase tem entregáveis concretos e verificáveis. Nenhuma fase avança sem que os entregáveis da fase anterior estejam concluídos e aprovados.

### Fase 0 — Diagnóstico (Mês 3)

| # | Entregável | Descrição | Validação |
|---|---|---|---|
| 0.1 | **Mapa de processos da rede** | Diagrama AS-IS dos fluxos operacionais: abastecimento, perecíveis, frente de caixa, fechamento, gestão de pessoas. Cobre as 30+ lojas consolidado por região/porte. | Validado em reunião com Fábio e área responsável |
| 0.2 | **Matriz de maturidade** | Tabela comparativa loja a loja com scores por dimensão (processos, sistemas, pessoas), gerada a partir dos questionários inteligentes. Inclui visão agregada por região e porte. | Entregue como relatório + apresentação executiva |
| 0.3 | **Relatório de diagnóstico** | Documento com os vazamentos priorizados por impacto financeiro e facilidade de correção. Inclui recomendações de curto prazo (quick wins) e estruturais. | Aprovado pelo patrocinador |
| 0.4 | **Especificação técnica da plataforma** | Documento de arquitetura e escopo detalhado para Fases 1 e 2: schemas de dados, APIs, interfaces, infraestrutura, cronograma revisado, requisitos de acesso a sistemas | Validado com TI do Guanabara |
| 0.5 | **Proposta de investimento revisada** | Valores, prazos e parcelas das Fases 1 e 2 ajustados com base nos achados reais do diagnóstico | Aprovada pelo patrocinador |

### Fase 1 — Unificar e enxergar (Mês 7)

| # | Entregável | Descrição | Validação |
|---|---|---|---|
| 1.1 | **Data warehouse unificado** | Banco PostgreSQL com dados de TOTVS, RP e planilhas integrados, padronizados e documentados. Schema documentado com dicionário de dados. | Query de validação cruzada com relatórios existentes |
| 1.2 | **Pipeline de ingestão automático** | Sistema que recebe arquivos (CSV, planilhas) e automaticamente detecta colunas, mapeia schemas e sincroniza com o warehouse. Interface simples de upload. | Teste com arquivo real: upload → disponível no banco em < 5 min |
| 1.3 | **Painel de comparação entre lojas** | Dashboard web com indicadores normalizados por faturamento, porte e região. Filtros por loja, região, período. Comparação lado a lado de qualquer conjunto de lojas. | Sessão de validação com diretoria |
| 1.4 | **Documentação de padronização** | Catálogo de cadastros padronizados (produtos, categorias, centros de custo) e regras de normalização aplicadas | Entregue como documento + glossário no painel |

### Fase 2 — Entender e agir (Mês 12)

| # | Entregável | Descrição | Validação |
|---|---|---|---|
| 2.1 | **Modelo de direcionadores de custo** | Sistema que cruza custo operacional com atributos estruturais de cada loja e classifica cada componente como passivo (estrutural) ou gerenciável (decisão). Interface mostra drivers por loja com recomendações. | Sessão com diretoria: "o que explica a diferença de margem entre loja X e Y?" |
| 2.2 | **Chat com dados** | Interface de chat em linguagem natural conectada ao warehouse. Usuário pergunta em português, sistema busca, cruza tabelas e responde com números e gráficos. Sem SQL. | Teste com 10 perguntas reais de negócio definidas com o cliente |
| 2.3 | **Relatórios automáticos** | Sistema que gera e distribui relatórios em datas determinadas ou sob demanda. Cada relatório chega com desvios destacados, comparação com período anterior e ações sugeridas baseadas nas melhores lojas. | Primeiro relatório automático entregue e aprovado |
| 2.4 | **Motor de recomendações** | Sistema que identifica correlações entre práticas operacionais e resultados, sugerindo ações para lojas com desempenho abaixo da média da rede. | Pelo menos 3 recomendações geradas e validadas como aplicáveis |
| 2.5 | **Automatização de processos com agentes** | Agentes de IA especializados por domínio (análise financeira, CRM de fornecedores, compras/procurement, análise estratégica) que automatizam tarefas recorrentes e respondem a perguntas com dados reais do warehouse | Cada agente executa pelo menos um processo ponta a ponta com dados reais |
| 2.6 | **Plataforma unificada** | Aplicação web que unifica todos os módulos num ambiente único: painel comparativo, chat com dados, direcionadores de custo, relatórios e agentes. Autenticação centralizada, navegação por loja/região/período. | Sessão de uso com diretoria: executar um fluxo completo (ex: "mostre a loja com pior margem em perecíveis, explique o driver e sugira ação") |

---

## 4. Diferencial estratégico: Direcionadores de custo

A pergunta que toda rede se faz: *"Por que esta loja fatura X% mais que a outra e ainda assim dá menos lucro?"*

A plataforma cruza os dados operacionais de cada loja com seus atributos estruturais — idade dos equipamentos, localização, perfil de consumo de energia e água, e outras variáveis levantadas no diagnóstico. O resultado é um modelo que **separa o custo passivo** (loja mal localizada, equipamento antigo — estruturais, não corrigíveis no curto prazo) **do custo gerenciável** (decisões operacionais que podem ser ajustadas). A diretoria para de tratar todas as lojas como se fossem iguais e passa a agir onde realmente faz diferença.

---

## 5. O que NÃO está incluso

- Substituição ou migração do TOTVS ou RP existentes — a plataforma integra, não substitui
- Criação de conteúdo operacional (procedimentos, manuais) — podemos recomendar padrões, não escrever do zero
- Hardware ou infraestrutura de rede nas lojas
- Manutenção contínua pós-entrega (pode ser contratada à parte)
- Treinamento de equipe além do escopo de adoção da plataforma

---

## 6. Stack prevista

| Camada | Tecnologia |
|---|---|
| Banco de dados | PostgreSQL (data warehouse unificado) |
| Pipeline de ingestão | Automatizado — detecção de colunas, mapeamento de schemas |
| Backend | FastAPI + Python |
| IA / Agentes | DeepSeek (LLM principal) + Groq (transcrição de áudio) |
| Frontend | Painel web + chat em linguagem natural |
| Infraestrutura | AWS ou própria do cliente (a definir) |
| Autenticação | A definir (integração com AD/existente ou própria) |

---

## 7. Cronograma

**Duração total: 12 meses** (a confirmar com o cliente)

| Fase | Período | Descrição |
|---|---|---|
| Fase 0 — Diagnóstico | Meses 1–3 | Entrevistas, questionários, matriz de maturidade, especificação da plataforma |
| Gate | Final Mês 3 | Decisão sobre continuidade + escopo revisado das Fases 1 e 2 |
| Fase 1 — Unificar | Meses 4–7 | Integração de dados, pipeline automático, painel comparativo |
| Fase 2 — Agir | Meses 8–12 | Direcionadores, chat, relatórios automáticos, recomendações, agentes IA |

> 📅 Os 3 meses da Fase 0 são estimativa interna. O cronograma será ajustado com o cliente.

---

## 8. Investimento e pagamento

### Projeto completo (12 meses): R$ 200.000

Contrato de 1 ano com pagamento fracionado, atrelado a entregas e eventos:

| # | Parcela | Valor | Gatilho |
|---|---|---|---|
| 1 | Kickoff | R$ 40.000 (20%) | Na assinatura do contrato |
| 2 | Entrega Fase 0 | R$ 40.000 (20%) | Ao final do Mês 3 — diagnóstico + especificação entregues e aprovados |
| 3 | Entrega Fase 1 | R$ 50.000 (25%) | Ao final do Mês 7 — banco unificado + pipeline + painel em produção |
| 4 | Entrega Fase 2 | R$ 50.000 (25%) | Ao final do Mês 12 — plataforma completa em produção |
| 5 | Sustentação | R$ 20.000 (10%) | 30 dias após entrega final — período de estabilização e ajustes |

### Fase 0 isolada: R$ 60.000

| # | Parcela | Valor | Gatilho |
|---|---|---|---|
| 1 | Kickoff | R$ 30.000 (50%) | Na assinatura do contrato |
| 2 | Entrega | R$ 30.000 (50%) | Ao final do Mês 3 — diagnóstico + especificação entregues e aprovados |

---

## 9. Riscos e mitigação

| Risco | Nível | Mitigação |
|---|---|---|
| **Qualidade/consistência dos dados de origem** | Alto | Fase 0 mapeia fontes e avalia qualidade antes de qualquer integração |
| **Resistência dos gerentes aos questionários** | Médio | Questionários curtos, por função, com opção de áudio. Foco no que o colaborador já vê |
| **Dependência de acesso aos sistemas (TOTVS, RP)** | Alto | Alinhamento prévio com TI do Guanabara; a Fase 0 já levanta isso |
| **Escopo das Fases 1–2 muda radicalmente após diagnóstico** | Médio | Isso é esperado e desejável — o modelo prevê refinamento ao final da Fase 0 |
| **30+ lojas = volume e variabilidade alta** | Médio | Pipeline automatizado desde o início; a plataforma é desenhada para escala |
| **Time enxuto (só Lucas)** | Alto | Fases 1 e 2 podem exigir contratação de apoio técnico. Definir após Fase 0 |
| **Concorrência (outras propostas)** | Incerto | Ainda não sabemos se o Guanabara avalia outros fornecedores. Mitigação: diagnóstico gera valor tangível em 3 meses, independente da continuidade |

---

## 10. Próximos passos

- [ ] Lucas validar este documento de escopo (v0.2)
- [ ] Ajustar com base no alinhamento
- [ ] Apresentar proposta ao Guanabara (Fábio)
- [ ] Se aprovado: assinar contrato e agendar kickoff da Fase 0
