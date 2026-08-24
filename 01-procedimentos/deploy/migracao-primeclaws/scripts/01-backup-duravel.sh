#!/usr/bin/env bash
# 01-backup-duravel.sh — RODAR NA EC2 ATUAL.
# Empacota SOMENTE o durável (análise README) + gera manifest do ambiente.
# Uso: bash 01-backup-duravel.sh [--full]
#   --full  inclui state.db (histórico de sessões) no backup.
set -euo pipefail

TS=$(date +%Y%m%d-%H%M)
OUT=~/backups/primeclaws/backup-$TS
mkdir -p "$OUT"
echo "▶ Backup durável em: $OUT"

# ── 1. Durável (sempre) ──────────────────────────────────────────────
echo "▸ ~/.hermes (config/profiles/skills/scripts/state/cron/mnemosyne)..."
rsync -a \
  --exclude='hermes-agent' --exclude='node' --exclude='bin' \
  --exclude='cache' --exclude='state.db' --exclude='runtime' \
  --exclude='plugins' --exclude='*.tmp' \
  ~/.hermes/ "$OUT/hermes/"

echo "▸ Credenciais (~/.aws ~/.cloudflare ~/.ssh ~/.claude ~/.config/opencode ~/.brevo ~/.oci)..."
mkdir -p "$OUT/creds"
for d in .aws .cloudflare .ssh .claude .brevo .oci; do
  [ -d ~/$d ] && rsync -a ~/$d/ "$OUT/creds/$d/"
done
[ -d ~/.config/opencode ] && rsync -a ~/.config/opencode/ "$OUT/creds/opencode/"

echo "▸ ~/.local (uv/claude/opencode — bin+state; lib/share reinstaláveis)..."
[ -d ~/.local ] && rsync -a --exclude='share' --exclude='lib' ~/.local/ "$OUT/local/"

echo "▸ linkedin-callback + projetos-docs/repo..."
[ -d ~/linkedin-callback ] && rsync -a ~/linkedin-callback/ "$OUT/linkedin-callback/"
[ -d ~/projetos-docs ] && rsync -a ~/projetos-docs/ "$OUT/projetos-docs/"
[ -d ~/projetos-repo ] && rsync -a ~/projetos-repo/ "$OUT/projetos-repo/"

echo "▸ Units systemd (referência)..."
mkdir -p "$OUT/systemd-user"
[ -d ~/.config/systemd/user ] && cp -a ~/.config/systemd/user/. "$OUT/systemd-user/" || true

# ── 2. state.db (opcional: --full) ───────────────────────────────────
if [ "${1:-}" = "--full" ]; then
  echo "▸ state.db (histórico de sessões)..."
  if command -v sqlite3 >/dev/null; then
    sqlite3 ~/.hermes/state.db ".backup '$OUT/state.db'"
  else
    cp ~/.hermes/state.db "$OUT/state.db" 2>/dev/null || echo "  ⚠ sem state.db ou sem sqlite3"
  fi
else
  echo "▸ state.db: pulado (regenerável). Use --full para incluir."
fi

# ── 3. Manifest (para validar a VPS depois) ───────────────────────────
echo "▸ Manifest..."
{
  echo "# Manifest $TS"
  echo "## Versões"
  for t in uv node npm gh claude opencode; do
    v=$(command -v $t >/dev/null && $t --version 2>/dev/null | head -1 || echo "ausente")
    echo "$t: $v"
  done
  echo "## Crons"
  hermes cron list 2>/dev/null | grep -E "Name:|Schedule:|Script:" | head -90 || echo "sem hermes cron list"
  echo "## Units systemd"
  systemctl --user list-units --type=service 2>/dev/null | grep -E "hermes" || true
  echo "## Portas"
  ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | sort -u
  echo "## Tailscale"
  tailscale status 2>/dev/null | head -8
  echo "## Monorepo branches no origin (WIP ok)"
  git -C ~/monorepo ls-remote --heads origin 2>/dev/null | wc -l
} > "$OUT/MANIFEST.txt"
echo "branches origin: $(git -C ~/monorepo ls-remote --heads origin 2>/dev/null | wc -l)"

# ── 4. Empacota ─────────────────────────────────────────────────────
tar -czf "$OUT.tar.gz" -C "$OUT" . 2>/dev/null || tar -czf "$OUT.tar.gz" -C "$(dirname "$OUT")" "$(basename "$OUT")"
sha256sum "$OUT.tar.gz" > "$OUT.tar.gz.sha256"
echo
echo "✅ Pronto: $OUT.tar.gz ($(du -h "$OUT.tar.gz" | cut -f1))"
echo "   SHA256: $(cut -d' ' -f1 "$OUT.tar.gz.sha256")"
echo
echo "NEXT: transferir para a VPS (rsync/scp) e rodar 02-vps-bootstrap.sh lá."
