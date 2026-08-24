#!/usr/bin/env bash
# 03-restore-vps.sh — RODAR NA VPS NOVA, após 02-vps-bootstrap.sh.
# Restaura o durável do backup, clona o monorepo, sobe units systemd e valida.
# Pré-requisito: tar do backup em ~/migracao/backup-*.tar.gz (copiado da EC2).
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
BACKUP=$(ls -t ~/migracao/backup-*.tar.gz 2>/dev/null | head -1 || true)
[ -z "$BACKUP" ] && { echo "❌ Nenhum backup-*.tar.gz em ~/migracao/. Copie da EC2 primeiro."; exit 1; }
echo "▶ Restaurando de: $BACKUP"
tar -xzf "$BACKUP" -C ~/migracao/
SRC=~/migracao/backup-*  # dir extraído (1º match)
SRC=$(ls -dt ~/migracao/backup-*/ | head -1)

# ── 1. Credenciais (permissões!) ───────────────────────────────────
echo "▸ Credenciais..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
[ -d "$SRC/creds/.ssh" ] && { cp -a "$SRC/creds/.ssh/." ~/.ssh/ 2>/dev/null || true; chmod 600 ~/.ssh/id_* 2>/dev/null || true; }
for pair in ".aws:.aws" ".cloudflare:.cloudflare" ".claude:.claude" ".brevo:.brevo" ".oci:.oci" "opencode:.config/opencode"; do
  s="${pair%%:*}"; d="${pair##*:}"
  [ -d "$SRC/creds/$s" ] && { mkdir -p ~/$(dirname "$d"); cp -a "$SRC/creds/$s/." ~/$d/; echo "  ~/$d ok"; }
done

# ── 2. ~/.local (uv/claude/opencode) ───────────────────────────────
[ -d "$SRC/local" ] && { cp -a "$SRC/local/." ~/.local/ 2>/dev/null || true; echo "▸ ~/.local restaurado"; }
command -v claude >/dev/null || echo "⚠ claude não encontrado — rodar: curl -fsSL https://claude.ai/install.sh | bash"
command -v opencode >/dev/null || echo "⚠ opencode não encontrado — rodar: curl -fsSL https://opencode.ai/install | bash"

# ── 3. ~/.hermes durável (EXCETO hermes-agent — instalação é do provedor) ──
echo "▸ ~/.hermes (durável)..."
mkdir -p ~/.hermes
rsync -a --exclude='hermes-agent' --exclude='node' --exclude='bin' \
  --exclude='cache' --exclude='state.db' --exclude='runtime' \
  "$SRC/hermes/" ~/.hermes/
# NOTA: se o provedor instalou Hermes em outro caminho, mover: rsync para onde o config apontar (HERMES_HOME)

# ── 4. Monorepo (clone fresco — WIP já está no origin) ─────────────
echo "▸ Clonando monorepo..."
git clone --quiet https://github.com/CidLucas/monorepo.git ~/monorepo || { echo "⚠ clone falhou (token?) — gh auth status"; }
if [ -d ~/monorepo ]; then
  git -C ~/monorepo checkout -q design/kanban-6-colunas 2>/dev/null || git -C ~/monorepo checkout -q -b design/kanban-6-colunas origin/design/kanban-6-colunas 2>/dev/null || true
  echo "▸ uv sync --all-packages (venv completo, regra #377)..."
  (cd ~/monorepo && env -u UV_NO_SYNC uv sync --all-packages 2>&1 | tail -3)
fi

# ── 5. Units systemd (referência do backup → ajustar paths) ────────
echo "▸ Units systemd..."
if [ -d "$SRC/systemd-user" ]; then
  cp -a "$SRC/systemd-user/." ~/.config/systemd/user/ 2>/dev/null || true
  # Ajusta HERMES_HOME/PATH se o provedor instalou Hermes noutro lugar (ex.: venv próprio)
  sed -i "s|/home/ec2-user|$HOME|g" ~/.config/systemd/user/hermes-*.service 2>/dev/null || true
  systemctl --user daemon-reload || true
  echo "  Units copiadas — REVISE os ExecStart (caminho do venv do provedor) antes do enable:"
  grep -H "ExecStart" ~/.config/systemd/user/hermes-gateway*.service 2>/dev/null | head -5
fi

# ── 6. Validação base ──────────────────────────────────────────────
echo
echo "▶ VALIDAÇÃO (6/9 do checklist):"
echo "  1) gh auth:   $(gh auth status 2>&1 | head -1)"
echo "  2) git branch: $(git -C ~/monorepo branch --show-current 2>/dev/null)"
echo "  3) uv:        $(uv --version 2>/dev/null)"
echo "  4) tailscale: $(tailscale ip -4 2>/dev/null | head -1)"
echo
echo "NEXT (manual): ajustar ExecStart das units p/ o venv do provedor → systemctl --user enable --now hermes-gateway* → validar bots → atualizar Funnel/CF/LinkedIn (checklist §5-6)."
