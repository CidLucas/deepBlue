# Design — ponteiro (migrado para o monorepo)

**A partir de 2026-08-18 (Fase 3), o design reutilizável vive no monorepo:**

```
monorepo/design/
├── design-systems/     ← blu-original (ex blu-design-system), brand-hub
├── telas/              ← blu (ex blu-novo-front), brain (ex blu-memory-api)
└── componentes/        ← UI kits (Fase 4)
```

| Antes (aqui) | Agora (monorepo) |
|---|---|
| `blu-novo-front/` | `design/telas/blu/` |
| `blu-memory-api/` | `design/telas/brain/` |
| `blu-design-system/` | `design/design-systems/blu-original/` |
| `brand-hub/` | `design/design-systems/brand-hub/` (fonte de edição do site; deploy via `scripts/local/sync-brand-hub.sh`) |

Motivo: monorepo = design reutilizável em código (DS, telas, componentes,
identidade). Projetos fica com a comunicação (textos/, referencias/,
apresentacoes/) — ver `deepblue/docs/01-proposta-estrutura-documentos.md`.

Previews na 8899 apontam para o monorepo (symlinks em
`~/.hermes/profiles/design-writer/drafts/proposals/`).
