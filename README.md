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
| [00-empresa/](./00-empresa/) | Contexto da empresa: visão, stack, **clientes**, posicionamento |
| [01-procedimentos/](./01-procedimentos/) | **★ Padrões operacionais por área** — como fazemos as coisas (consultáveis e editáveis) |
| [02-projetos/](./02-projetos/) | Um diretório por projeto ativo (visão, arquitetura, roadmap, decisions) |
| [03-referencias/](./03-referencias/) | Referências: design systems, marcas, pesquisa |
| `__profiles__/` | Entregáveis por profile/agente (pm, writer, ...) |
| `TEMPLATE-PROJETO.md` | Template base para novos projetos |
| `TEMPLATE-DELIVERABLE.md` | Padrão de entrega para todos os profiles |

## 🤝 Clientes

Resumo comercial de cada cliente (propostas, apresentações, docs):
[00-empresa/clientes/](./00-empresa/clientes/) — SENAC, Cladtek, Rastro, Guanabara, Formly, MCP Brain.

## 🧭 Procedimentos (como fazemos)

- [**Produção de código**](./01-procedimentos/producao-de-codigo/) — pipeline de issues → specs → agentes → verificação → PR (o que estamos usando hoje)
- [**Conteúdo LinkedIn**](./01-procedimentos/conteudo-linkedin/) — fluxo de criação de conteúdo
- [**Gerência de projetos**](./01-procedimentos/gerencia-de-projetos/) — ADRs, decisions, status
- [**Deploy**](./01-procedimentos/deploy/) — padrões de deploy (GCP, Neon, Cloud Run)
- *(em construção — cada área ganha seu procedimento)*

## 📋 Projetos ativos

| Projeto | Tipo | Fase |
|---|---|---|
| [assistente-pessoal](./02-projetos/assistente-pessoal/) | Produto próprio | Build (F0 entregue) |
| [plataforma-blu](./02-projetos/plataforma-blu/) | Produto próprio | Build |
| [agente-bloquo](./02-projetos/agente-bloquo/) | Produto próprio | Build |
| [mcp-brain](./02-projetos/mcp-brain/) | Produto B2B próprio | Descoberta |
| [senac](./02-projetos/senac/) | SENAC | Pré-kickoff |
| [cladtek](./02-projetos/cladtek/) | Cladtek | Pré-contrato |
| [sales-coach-ai](./02-projetos/sales-coach-ai/) | Sales Coach AI — Cruzeiro do Sul | Pré-contrato (setup) |
| [rastro](./02-projetos/rastro/) | Rastro | Pré-proposta |

## ⚙️ Stack da empresa

FastAPI · React+TS+Vite · Supabase · Neon (Postgres) · Agno (agentes) ·
LangGraph (legado, migrando) · MCP · Playwright · Hermes Agent (orquestração)
— detalhes em [00-empresa/visao-da-empresa/](./00-empresa/visao-da-empresa/).
