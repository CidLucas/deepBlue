# Mapa de Dores — Pequenos e Médios Empreendedores

**Origem:** síntese das 5 referências (`referencias/pesquisa/01`–`05`) + dados
que já usamos (Itaú/Locomotiva 90%, Sebrae). Objetivo: as dores centrais do
dono de PME e **onde cada uma ataca na Deep Blue**.

**Alinhamento:** mindmap `05-notebooklm-mindmap-oportunidades-pme.md` (§1–§5)

---

## As dores centrais (10)

### D1 · Decisão solitária
O dono decide sozinho em 5 áreas diferentes, sem apoio estruturado. Tudo passa
pela cabeça dele; quando ele não está, a decisão espera.
- *Origem:* mindmap §5 ("empreendedor faz-tudo"); dado 90% (Itaú/Locomotiva)
- *Ataca na Deep Blue:* **Consulting** (diagnóstico), **Blu** (sala de estratégia), **Brain** (contexto p/ decidir), **Advisory** (acompanhamento contínuo)

### D2 · Informação espalhada, nada consolidado
Planilha, e-mail, Drive, ERP, caderninho. "Quanto vendi ontem?" vira caçada
por arquivos. Não existe uma visão única do negócio.
- *Origem:* mindmap §3 (consultas via linguagem natural, dashboards)
- *Ataca na Deep Blue:* **Blu** (ambiente único + busca semântica), **Brain** (memória)

### D3 · Volume de coisas pra acompanhar
Agenda, atendimento, estoque, finanças, pessoas, prazos. O dono não dá conta
de monitorar tudo — e não consegue estar em todo lugar ao mesmo tempo
(enquanto atende um cliente, a operação anda sem supervisão).
- *Origem:* mindmap §2–§3 (atendimento, gestão em tempo real)
- *Ataca na Deep Blue:* **Blu** (agentes de rotina/monitoramento), **AtendAI** (atendimento), **assistente diário**

### D4 · Conhecimento preso nas pessoas
O que a equipe sabe não vira ativo da empresa. Saiu uma pessoa, saiu o
conhecimento. O que a unidade A aprendeu não chega na unidade B.
- *Origem:* mindmap §4 (memória/contexto); nossa experiência de diagnóstico
- *Ataca na Deep Blue:* **Brain MCP**, **Blu** (gestão de conhecimento)

### D5 · Trabalho manual repetitivo
Proposta, relatório, orçamento, transcrição — tudo do zero, toda vez. Ex:
100–500 cotações por dia lidas por humano. Tempo que deveria gerar negócio é
gasto repetindo processo.
- *Origem:* mindmap §2 (automação de orçamentos); REASE (automação)
- *Ataca na Deep Blue:* **fluxos de agentes** (case Rastro), **Formly** (transcrição/coleta)

### D6 · Atendimento que escapa
Contato chega solto (WhatsApp, site, e-mail) sem triagem nem resposta rápida.
Cliente espera, vendedor perde tempo com repetição em vez de negociar.
- *Origem:* mindmap §2 (automação e triagem de contatos)
- *Ataca na Deep Blue:* **AtendAI**, **Blu** (agentes), **fluxos de agentes**

### D7 · Documentos sem estrutura (esteira manual)
Do lead ao contrato, cada documento nasce do zero: proposta, orçamento,
contrato, relatório. Sem pipeline, sem rastreabilidade, sem padrão.
- *Origem:* nosso diagnóstico (lead→serviço→documentos→proposta→contrato); mindmap §2
- *Ataca na Deep Blue:* **Blu** (pipeline de documentos), **fluxos de agentes**

### D8 · Medo e custo percebido da IA
O dono acha que IA é caro, é pra grande empresa, exige equipe técnica. Não
sabe por onde começar — e comprar ferramenta sem diagnóstico não resolve.
- *Origem:* mindmap §1 (desconstrução do paradigma de alto custo)
- *Ataca na Deep Blue:* **F1 Diagnóstico** (porta de entrada), **assinaturas** (custo acessível)

### D9 · Sem prova de valor
"IA funciona no meu negócio?" Promessa não convence. Comprometer orçamento
grande sem ver resultado é risco demais.
- *Origem:* mindmap §1 (entrega rápida, semipronta); guia 04 (teste prático)
- *Ataca na Deep Blue:* **F2 Escopo Fechado** (piloto opcional: métricas antes/depois)

### D10 · Sem direção depois do piloto
O piloto deu certo — e agora? Ferramentas soltas que não conversam; sem
roadmap, a transformação não acontece.
- *Origem:* mindmap §4 (orquestração de modelos); guia 04 (integração)
- *Ataca na Deep Blue:* **F2 Escopo Fechado** (direção combinada) · **F3 Consultoria Estratégica**

---

## Matriz dor → produto/serviço

| Dor | Blu | Formly | Brain | AtendAI* | Agentes sob medida | F1 Diagnóstico | F2 Escopo | F3 Consultoria |
|---|---|---|---|---|---|---|---|---|
| D1 decisão solitária | ● | | ● | | | ● | | ● |
| D2 info espalhada | ● | | ● | | | | | |
| D3 volume p/ acompanhar | ● | | | ● | ● | | | |
| D4 conhecimento preso | ● | | ● | | | | | |
| D5 trabalho manual | ● | ● | | | ● | | ● | |
| D6 atendimento escapa | ● | | | ● | ● | | | |
| D7 documentos sem estrutura | ● | | | | ● | | ● | |
| D8 medo/custo da IA | | | | | | ● | | ● |
| D9 sem prova de valor | | | | | | | ● | |
| D10 sem direção pós-piloto | | | | | | | ● | ● |

\* AtendAI está no catálogo do Labs (agente de atendimento multicanal) — ainda
sem doc de referência próprio; entra na próxima leva.

Serviços de consultoria: **3 formas de trabalho** (ver `textos/servicos/README.md`):
1 Diagnóstico e Boas Práticas (D1·D8) · 2 Escopo Fechado (D5·D7·D9·D10, piloto
opcional como porta de entrada) · 3 Consultoria Estratégica (D1·D8·D10, formatos:
direção, ferramenta, estruturação de equipe). Pilot e Adoção de IA absorvidos
nas formas 2 e 3 — poucas opções, que se falam.

## Regra de uso

- Todo doc de produto/serviço cita no header as dores que ataca (D1…D10).
- A seção "A dor que resolve" é escrita na **linguagem do dono**, não na nossa
  (D2 vira "quanto vendi ontem? vira caçada por planilhas").
- Novas dores descobertas em diagnóstico entram aqui antes de entrar em copy.
