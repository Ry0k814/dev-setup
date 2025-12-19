#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

if ! need_cmd vim; then
  warn "vim not installed; skipping vim setup."
  exit 0
fi

do_cmd mkdir -p "$HOME/.vim/backup" "$HOME/.vim/swap" "$HOME/.vim/undo" || true

ok "Vim directories ensured."
