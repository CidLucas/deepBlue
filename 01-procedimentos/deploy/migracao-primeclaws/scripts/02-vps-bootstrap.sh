#!/usr/bin/env bash
# 02-vps-bootstrap.sh — RODAR NA VPS NOVA (PrimeClaws/DO), como usuário com sudo.
# Prepara o sistema base: tools, gh, tailscale, uv. NÃO instala o Hermes
# (provedor gerenciado faz isso — silent updates) nem restaura dados (script 03).
set -euo pipefail

echo "▶ Bootstrap da VPS — $(hostname) | $(. /etc/os-release && echo $PRETTY_NAME)"

# ── 1. Base tools ──────────────────────────────────────────────────
sudo apt-get update -y -qq 2>/dev/null || sudo yum update -y -q 2>/dev/null || true
for t in git curl rsync unzip jq ca-certificates; do
  command -v $t >/dev/null || { echo "▸ instalando $t..."; sudo apt-get install -y -qq $t 2>/dev/null || sudo yum install -y -q $t 2>/dev/null; }
done

# ── 2. gh (GitHub CLI) ─────────────────────────────────────────────
if ! command -v gh >/dev/null; then
  echo "▸ instalando gh..."
  (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg) 2>/dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
    && sudo apt-get update -y -qq && sudo apt-get install -y -qq gh || echo "⚠ gh: instale manualmente (https://github.com/cli/cli)"
fi
command -v gh >/dev/null && echo "  gh: $(gh --version | head -1)"

# ── 3. uv ──────────────────────────────────────────────────────────
if ! command -v uv >/dev/null; then
  echo "▸ instalando uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
echo "  uv: $(uv --version 2>/dev/null)"

# ── 4. Tailscale ───────────────────────────────────────────────────
if ! command -v tailscale >/dev/null; then
  echo "▸ instalando tailscale (curl -fsSL https://tailscale.com/install.sh)..."
  curl -fsSL https://tailscale.com/install.sh | sudo sh
fi
echo "▸ Conectando ao tailnet — SIGA O LINK DE AUTORIZAÇÃO:"
sudo tailscale up
sleep 2
tailscale status 2>/dev/null | head -4 || true
echo "  IP novo: $(tailscale ip -4 2>/dev/null | head -1)"

# ── 5. Diretórios base ─────────────────────────────────────────────
mkdir -p ~/migracao ~/.config/systemd/user
echo
echo "✅ Bootstrap OK. Próximo: transferir o backup (01) e rodar 03-restore-vps.sh"
echo "   (copie o tar da EC2: scp ec2-user@<ec2>:~/migracao-primeclaws/backup-*.tar.gz ~/migracao/)"
