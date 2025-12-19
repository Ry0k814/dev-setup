#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

# すでにあるなら何もしない
if command -v mise >/dev/null 2>&1; then
  ok "mise already installed: $(command -v mise)"
  exit 0
fi

INSTALL_DIR="$HOME/.local/bin"
INSTALL_URL="https://mise.jdx.dev/install.sh"

log "Installing mise to $INSTALL_DIR"

# ~/.local/bin は PATH に後で入れる（dotfiles 側の責務）
do_cmd mkdir -p "$INSTALL_DIR"

# 公式 install script
do_cmd curl -fsSL "$INSTALL_URL" | do_cmd sh

# 念のため存在確認
if ! is_dry_run && ! command -v mise >/dev/null 2>&1; then
  err "mise installation failed"
  exit 1
fi

ok "mise installed"
