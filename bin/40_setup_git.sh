#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

if ! need_cmd git; then
  warn "git not installed; skipping git checks."
  exit 0
fi

do_cmd git config --global core.excludesfile "$HOME/.gitignore_global" || true

ok "Git configured."
