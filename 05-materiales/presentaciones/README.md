# Apresentações — Padrão da Deep Blue

Pasta definitiva dos decks da empresa (negócio, reutilizável por agentes).

## Estrutura

```
apresentacoes/
└── deck-empresa/        ← deck institucional (base do padrão)
    ├── build_deck.py    ← gerador (identidade landing: #F2F2F0, #1D4ED8,
    │                      Instrument Serif itálico, kickers JetBrains Mono)
    ├── deck-empresa-v3.md   ← roteiro slide a slide + notas
    ├── deck-empresa-v3.pptx ← deck editável
    └── deck-empresa-v3.pdf  ← preview fiel
```

## Como criar um deck novo

1. Copie a pasta `deck-empresa` (ex: `deck-cliente-x`).
2. Edite o roteiro (`*.md`) — texto slide a slide, notas do apresentador.
3. Ajuste o gerador (`build_deck.py`) — copy e, se preciso, slides.
4. Rode `python3 build_deck.py deck-cliente-x.pptx`, gere o PDF e renderize
   para revisão visual.
5. Suba para o Google Drive: `Hermes - Entregáveis/Apresentações`.
6. Registre o link no `STATUS.md` do projeto.

## Regras do padrão

- Identidade fixa (landing clara) — ver `textos/apresentacao/deck-estrutura.md`.
- Copy puxa da biblioteca `textos/` (4 camadas) — nunca reescrever do zero.
- Voz: skill `deep-blue-voice`.
- Roteiro em markdown acompanha todo deck (sem roteiro = draft).
