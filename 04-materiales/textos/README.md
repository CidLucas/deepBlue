# Textos — Copy Library da Deep Blue

**Finalidade:** linguagem única da casa. Proposta, deck, site e posts **puxam**
daqui — nunca reescrevem do zero.

## Como usar

1. Cada produto/capability/serviço tem **4 camadas** de texto:
   - **One-liner** (~10 palavras) — hero, card, post.
   - **Parágrafo curto** (2–3 frases) — seção, proposta, site.
   - **Parágrafo completo** — drawer, página de produto, proposta detalhada.
   - **Bullets** — o que entrega, em lista.
2. Escolha a camada pelo artefato; não copie texto de outro artefato.
3. Todo texto novo de produto/capability entra aqui **primeiro**.
4. Voz: skill `deep-blue-voice` (anti-hype, cliente como herói, IA como
   ferramenta, dados reais, frases curtas).

## Estrutura

```
textos/
├── TEMPLATE-produto-servico.md  ← estrutura obrigatória (dor → para quem → camadas)
├── produtos/        ← por produto: blu, formly, brain-mcp
├── capabilities/    ← o KIT TÉCNICO (README + docs): plataformas e produtos,
│                      agentes e fluxos, assistente com ferramentas, rotinas e
│                      monitoramento, memória e dados, consultoria
├── servicos/        ← 3 FORMAS de trabalho (README + docs): diagnóstico e
│                      boas práticas · escopo fechado · consultoria estratégica
├── exemplos/        ← textos do Lucas (padrão ouro)
└── apresentacao/    ← estrutura padrão do deck
```

## Regras

- **Dor primeiro.** Todo produto/serviço abre com "A dor que resolve", na
  linguagem do consumidor — as camadas de texto nascem dela.
- **Alinhamento com o mindmap** (`referencias/pesquisa/05-…`): cada doc cita no
  header de onde a necessidade veio (referências §1–§5).
- **Um canônico por conceito.** Se o texto mudou em algum lugar, atualiza aqui
  e propaga — nunca o contrário.
- **Camadas sempre preenchidas.** Arquivo sem as 4 camadas está em draft.
- **Exemplos do Lucas têm prioridade máxima** (pasta `exemplos/`); quando ele
  editar algo, o editado vira exemplo e o arquivo correspondente é atualizado.
