#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

MISE_BIN="${MISE_BIN:-$HOME/.local/bin/mise}"
INSTALL_URL="https://mise.jdx.dev/install.sh"

# すでにバイナリがあるなら何もしない（PATHに依存しない）
if [[ -x "$MISE_BIN" ]]; then
  ok "mise already installed: $MISE_BIN"
  # ついでにバージョン表示（dry-runなら表示だけ）
  if ! is_dry_run; then
    "$MISE_BIN" --version || true
  fi
  exit 0
fi

log "Installing mise (expected path: $MISE_BIN)"

do_cmd mkdir -p "$(dirname "$MISE_BIN")"

# 公式インストールスクリプトを実行
# （標準で ~/.local/bin に入る想定）
do_cmd curl -fsSL "$INSTALL_URL" | do_cmd sh

# インストール結果を「ファイル存在」で確認（PATHに依存しない）
if is_dry_run; then
  ok "dry-run: skipped mise post-check"
  exit 0
fi

if [[ -x "$MISE_BIN" ]]; then
  ok "mise installed: $MISE_BIN"
  "$MISE_BIN" --version || true
  exit 0
fi

err "mise installation check failed: $MISE_BIN not found or not executable"
err "Tip: verify install output and check $HOME/.local/bin"
exit 1
