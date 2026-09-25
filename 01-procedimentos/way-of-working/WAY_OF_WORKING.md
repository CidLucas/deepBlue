# WAY OF WORKING — Deep Blue

> Documento canônico do modo de trabalhar da empresa. Fonte da verdade.
> Versões antigas vão para [historico/](./historico/) — nunca se apagam.

## 1. Repositório único
- **Tudo vive no repositório** [CidLucas/deepBlue](https://github.com/CidLucas/deepBlue) (sem Drive). Git é a fonte e o histórico.
- Lido/editado por Lucas + sócio(s); agentes (Hermes PM) também leem e gravam.

## 2. Estrutura (resumo)
```
00-empresa/     visão · atas · analises · societario · financeiro
01-procedimentos/  ★ como fazemos (way-of-working, comercial, marketing, producao-de-codigo, deploy, rotinas, ritmo-operativo)
02-projetos/    um dir por projeto vigente (+ cliente/ dentro do projeto)
03-negocio/     questões de negócio: marketing, producto, herramientas, pipeline
04-materiales/  texto visible: presentações, textos, marketing operacional
05-referencias/ design systems, marcas, pesquisa, catálogo IA
90-archivo/     no vigentes (se arquiva, não se borra)
```

## 3. Convenção de nomes
- **Arquivo datado:** `AAAA-MM-DD-tipo-descricao.ext` — minúsculas, sem acento, palavras por hífen. Ex.: `2026-09-28-sessao-segunda.md`
- **Documento vivo:** nome curto, sem data (`editoria.md`, `plano-comercial.md`); `README.md`/`STATUS.md` como hoje.
- **Versão** de documento vivo fica no **histórico do git**; não criar `-v2` no nome (exceção: proposta comercial, ex. `proposta-v6`, que já segue assim).
- Versão antiga que precisa ficar visível → `historico/` na mesma pasta. **Nunca se apaga.**

## 4. Ritmo
- Ciclo: **briefing** matinal (09:00) · follow-ups ter/qua · quinta (tópico) · **fechamento** sexta · recap segunda · retro último sexta do mês.
- Detalhe em [01-procedimentos/ritmo-operativo/](../ritmo-operativo/). Reuniões de cliente/projeto → dentro do projeto; atas de sessão longa → `00-empresa/atas/`.

## 5. Projeto
- **Unidade = projeto.** O cliente vive **dentro** do projeto (`cliente/`: contexto, proposta, contrato, reuniones) — não há pasta separada de clientes.
- Cada projeto: `README.md` · `STATUS.md` (atualizado no rito semanal) · `docs/` · `decisions/`.

## 6. Dívida técnica
- Toda dívida/defeito/decisão pendente → issue no GitHub (`gh issue create`, labels `tech-debt`/`bug`/`enhancement`/`contrato`). A fila é o GitHub. Ver `monorepo/CLAUDE.md`.

## 7. Histórico deste documento
- `2026-09-25` — primeira versão (decisão de 24–25/09: sem Drive, clientes no projeto, convenção de nomes, pastas atas/analises/societario/financeiro/comercial/marketing, way-of-working).
