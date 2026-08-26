# 🛰️ Fila Sequencial de Issues via Watchdog Cron

> **Procedimento:** como rodar uma fila ordenada de issues (uma por vez) com
> cron determinístico, workers OpenCode/Claude Code e PR automático.
> **Status:** vigente (validado 2026-08-26 na fila blu-novo #430–#435).
> **Doc irmão:** [pipeline-issues-fases.md](pipeline-issues-fases.md) — o fluxo
> macro issue→spec→dispatch→verificação. Este documento cobre a **orquestração
> da fila** (watchdog).

---

## 1. Princípio

Um script Python determinístico (`no_agent`, sem LLM por tick) guarda o estado
da fila em JSON e garante o contrato:

```
1 worker por vez — a próxima issue só despacha quando a anterior é PUSHADA.
Tick silencioso quando tudo bem. Mensagem no chat só em transição.
```

## 2. Componentes

| Peça | Caminho | Papel |
|:-----|:--------|:------|
| Watchdog | `~/.hermes/scripts/<fila>-watchdog.py` | Decide o que fazer a cada tick |
| Estado da fila | `~/.hermes/state/<fila>_queue.json` | Fonte única de verdade do dispatch |
| Dispatcher OpenCode | `~/.hermes/scripts/dispatch-opencode-wt.sh` | Worktree isolado + preflight + run |
| Dispatcher Claude | `~/.hermes/scripts/dispatch-claude.sh` | Idem, print-mode com teto de RAM |
| Specs | `scripts/prompts/<id>.md` (DENTRO do monorepo) | Versionadas na main ANTES do dispatch |
| Cron | job `no_agent`, `script=<fila>-watchdog.py` | Tick fixo (20min), stdout = mensagem |

## 3. Formato do estado (`<fila>_queue.json`)

```json
{
 "current": "bn-430",          // issue em execução (ou null)
 "done": ["bn-430"],
 "items": [
   {"id": "bn-431", "issue": 431,
    "spec": "scripts/prompts/bn-431-intake-backend.md",
    "branch": "feat/bn-431",
    "base": "feat/bn-430",     // encadeada: nasce da anterior, nunca da main
    "tool": "opencode",
    "deps": ["bn-430"],
    "status": "ready|pending|running|pushed|stalled"}
 ]
}
```

O cron despacha pelo **state.json**, não pelo estado da issue no GitHub.
Validou uma issue manualmente? Marque `done` no JSON na mesma operação —
senão o tick REDESPACHA trabalho já entregue.

## 4. Contrato por tick (lógica do watchdog)

1. Fila esgotada → relatório final UMA vez, `finished=true`, ticks mudos
   para sempre, lembrar de pausar o próprio cron.
2. Worker atual com branch **pushada no origin** (`git ls-remote`) → marca
   done, **abre PR automático** (`gh pr create --base main --head <branch>`,
   body com `Closes #N`), imprime 🔗 link e **lança a próxima no mesmo tick**.
3. Log termina em `PREFLIGHT FALHOU` → o wrapper abortou ANTES de lançar o
   agente: volta pra `ready` e re-despacha (sem esperar timeout).
4. Log parado >45min E branch sem push → ⛔ marca `stalled`, REPORTA e PARA a
   fila. Investigação manual antes de retomar (nada de re-despatch às cegas).
5. Sem current → lança a próxima com deps resolvidas.

## 5. Regras duras (lições já pagas)

- **Dispatch assíncrono SEMPRE**: `subprocess.Popen(..., start_new_session=True)`
  e retorno imediato. `subprocess.run(timeout=...)` síncrono dentro do tick mata
  a orquestração (incidente F0 7h30).
- **Preflight aponta pro host ATUAL** (`~/monorepo`). Após migração de máquina,
  caminho velho (`/home/ec2-user/...`) faz TODO dispatch falhar silenciosamente
  (aconteceu 26/08 — agora o watchdog detecta e reagendaa).
- **Specs versionadas na main antes do dispatch** (commit chore direto ou via
  worktree se o clone principal estiver em outra branch). O worker lê a spec
  DENTRO do worktree nascido de origin/main.
- **Nunca julgar pelo exit code nem pelo relato do agente**: progresso real =
  commit na branch + push no origin + testes rodados por você (PYTHONPATH/
  UV_NO_SYNC=1 do worktree).
- **1 worker por vez** — o preflight bloqueia dispatch se já há agente rodando.
- **Fim de fila desliga o próprio cron** (pedido do dono: crons não moram
  para sempre em silêncio).

## 6. Subir uma fila nova (checklist)

```bash
# 1. Specs na main do monorepo (worktree se o clone estiver sujo)
git -C ~/monorepo fetch origin main && git worktree add /tmp/specs-wt origin/main -b chore/specs
cp meus-prompts/*.md /tmp/specs-wt/scripts/prompts/
cd /tmp/specs-wt && git add scripts/prompts && git commit -m "chore(scripts): specs ..." && git push -u origin chore/specs
git -C ~/monorepo push origin chore/specs:main        # fast-forward
cd ~/monorepo && git worktree remove /tmp/specs-wt

# 2. Escrever o state JSON (~/.hermes/state/<fila>_queue.json)
#    (ids únicos, bases encadeadas, tool por item, status ready/pending)

# 3. Adaptar/copiar o watchdog (QUEUE items, paths) e py_compile nele

# 4. Criar o cron (no_agent, script relativo a ~/.hermes/scripts/)
hermes cron create --name <fila> --schedule "*/20 * * * *" \
  --script <fila>-watchdog.py --repeat 100

# 5. Despacho imediato (não esperar o 1º tick):
python3 ~/.hermes/scripts/<fila>-watchdog.py
```

## 7. Verificação empírica (pós-push, por entrega)

```bash
git ls-remote --heads origin <branch>                 # push real?
git -C ~/worktrees/wk-<N> log --oneline origin/main..HEAD   # commits da issue?
PYTHONPATH=<wt>/services/<svc>/src ~/monorepo/.venv/bin/python -m pytest <arquivos_tocados> -q
```

Comentário na issue com tabela peça-entregue/evidência antes do merge.
Merge é decisão do dono.

---

*Validado em produção na fila blu-novo (26/08/2026): #430 e #431 entregues
com PR automático (#447, #449); defeito real encontrado pelos testes do worker
(`now()` vs `clock_timestamp()` na trilha de eventos) corrigido na própria
issue; dívida de ambiente registrada como issue separada (#446).*
