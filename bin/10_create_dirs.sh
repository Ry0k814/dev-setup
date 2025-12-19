#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

CONF="$ROOT_DIR/config/dirs.conf"
[[ -f "$CONF" ]] || { err "Missing config: $CONF"; exit 1; }

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^# ]] && continue
  do_cmd mkdir -p "$HOME/$line"
done < "$CONF"

ok "Directories created/ensured."
