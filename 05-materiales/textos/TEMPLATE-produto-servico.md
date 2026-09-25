# Template — Documento de referência (produto / serviço)

Todo produto e serviço da Deep Blue tem um documento de referência em
`textos/produtos/` ou `textos/servicos/`, com esta estrutura. A ordem importa:
**começa pela dor do consumidor**, não pela feature.

## Estrutura obrigatória

```
# <Nome> — texto de referência

**Alinhamento:** mindmap §<n> (tema) · ...   ← referencias/pesquisa/05-…
**Dores que ataca:** D<n> · ...              ← referencias/pesquisa/06-mapa-dores-pme.md

## A dor que resolve        ← o que o consumidor sente hoje (linguagem dele),
                              em bullets com as dores D<n> da matriz
## Para quem                ← perfil exato
## One-liner                ← ~10 palavras (hero, card, post)
## Parágrafo curto          ← 2-3 frases (seção, proposta, site)
## Parágrafo completo       ← drawer, página de produto
## O que entrega (bullets)  ← lista de entregas concretas
## Por que acessível        ← custo/escala/implantação (mindmap §1)
```

## Regras

1. **Dor primeiro.** A seção "A dor que resolve" é a fonte das outras camadas —
   escrita na linguagem do dono, com as dores D1–D10 do mapa de dores
   (`referencias/pesquisa/06-mapa-dores-pme.md`).
2. **Linguagem do consumidor** — o dono de PME não fala "busca semântica";
   fala "eu não acho mais nada nessa empresa".
3. Voz Deep Blue (anti-hype, cliente como herói, IA como ferramenta, dados
   reais) — ver skill `deep-blue-voice`.
4. Alinhamento com o mindmap (`referencias/pesquisa/05-…`) e dores no header,
   para rastrear de onde cada necessidade veio.
5. As 4 camadas de texto sempre preenchidas (one-liner → completo → bullets).
