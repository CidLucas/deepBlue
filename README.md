# 🏢 Deep Blue

> **Repo:** CidLucas/deepBlue — documentação, padrões e procedimentos da empresa.
> **Índice central:** este arquivo.

---

## Quem somos

Deep Blue é uma empresa de IA aplicada a negócios. Construímos agentes,
automações e produtos de IA para PMEs e clientes corporativos.

## 📚 Estrutura do repositório

| Pasta | Conteúdo |
|---|---|
| [00-empresa/](./00-empresa/) | Contexto da empresa: visão, stack, clientes, posicionamento |
| [01-procedimentos/](./01-procedimentos/) | **★ Padrões operacionais por área** + [ritmo-operativo/](./01-procedimentos/ritmo-operativo/) (briefing, fechamento, recap, retro) |
| [02-projetos/](./02-projetos/) | Um diretorio por **projeto vigente** (inclui contexto do cliente, propuesta, reuniones dentro do projeto) |
| [03-negocio/](./03-negocio/) | **Cuestiones de negocio**: marketing, producto, herramientas, pipeline |
| [04-materiales/](./04-materiales/) | Material visible: presentações, textos, marketing web/LinkedIn |
| [05-referencias/](./05-referencias/) | Referências: design systems, marcas, pesquisa, catálogo IA |
| [90-archivo/](./90-archivo/) | Proyectos/material no vigentes (se archiva, não se borra) |
| `__profiles__/` | Entregáveis por profile/agente (pm, writer, ...) |
| `TEMPLATE-PROJETO.md` | Template base para novos projetos |
| `TEMPLATE-DELIVERABLE.md` | Padrão de entrega para todos os profiles |

## 🤝 Clientes

O **cliente vive dentro do projeto** (não tem pasta própria): contexto, proposta,
contrato e reuniões ficam em `02-projetos/<projeto>/cliente/`. Cliente sem projeto
não é relevante — a negociação gera um projeto na hora.

## 🧭 Procedimentos (como fazemos)

- [**Produção de código**](./01-procedimentos/producao-de-codigo/) — pipeline de issues → specs → agentes → verificação → PR
- [**Conteúdo LinkedIn**](./01-procedimentos/conteudo-linkedin/) — fluxo de criação de conteúdo
- [**Gerência de projetos**](./01-procedimentos/) — ADRs, decisions, status
- [**Deploy**](./01-procedimentos/deploy/) — padrões de deploy
- [**Ritmo operativo**](./01-procedimentos/ritmo-operativo/) — briefing matinal, fechamento viernes, recap lunes, retrospectiva
- *(em construção — cada área ganha seu procedimento)*

## 📋 Proyectos vixentes

| Projeto | Tipo | Fase |
|---|---|---|
| [assistente-pessoal](./02-projetos/assistente-pessoal/) | Produto próprio | Build |
| [plataforma-blu](./02-projetos/plataforma-blu/) | Produto próprio | Build |
| [mcp-brain](./02-projetos/mcp-brain/) | Produto B2B próprio | Descoberta |
| [cruzeiro-do-sul](./02-projetos/cruzeiro-do-sul/) | Sales Coach AI — Cruzeiro do Sul | Pré-contrato (setup) |
| [cladtek](./02-projetos/cladtek/) | Cladtek | Pré-contrato |
| [senac](./02-projetos/senac/) | SENAC | Pré-kickoff |
| [formly](./02-projetos/formly/) | Formly | Build |

_Archivados (24/09): agente-bloquo, guanabara, rastro, sales-coach-ai → [90-archivo/proyectos/](./90-archivo/proyectos/)._

## ⚙️ Stack da empresa

FastAPI · React+TS+Vite · Supabase · Neon (Postgres) · Agno (agentes) ·
LangGraph (legado, migrando) · MCP · Playwright · Hermes Agent (orquestração)
— detalhes em [00-empresa/visao-da-empresa/](./00-empresa/visao-da-empresa/).