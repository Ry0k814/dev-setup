#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

DOT_SRC="$ROOT_DIR/dotfiles"
DOT_DST="$HOME/.config/dotfiles"

[[ -d "$DOT_SRC" ]] || { err "Missing dotfiles directory: $DOT_SRC"; exit 1; }

do_cmd mkdir -p "$DOT_DST"

backup_path() {
  local p="$1"
  if [[ -e "$p" || -L "$p" ]]; then
    local ts backup
    ts="$(date +%Y%m%d%H%M%S)"
    backup="${p}.bak.${ts}"
    do_cmd mv "$p" "$backup"
    warn "Backed up: $p -> $backup"
  fi
}

# Copy a source file into DOT_DST as a REAL FILE (not a symlink).
# - If dest exists (file or symlink), back it up and replace.
# - Ensures parent dir exists.
copy_real_file() {
  local src="$1"
  local dst="$2"

  [[ -f "$src" || -L "$src" ]] || { err "Source not found: $src"; exit 1; }
  do_cmd mkdir -p "$(dirname "$dst")"

  # If destination is symlink or file, replace with a real file
  if [[ -L "$dst" ]]; then
    backup_path "$dst"
  elif [[ -e "$dst" ]]; then
    # If it's already a regular file, keep it (idempotent) unless src differs.
    # We do a cheap check with cmp if possible.
    if ! is_dry_run && command -v cmp >/dev/null 2>&1; then
      if cmp -s "$src" "$dst"; then
        ok "File up-to-date: $dst"
        return 0
      fi
    fi
    backup_path "$dst"
  fi

  # Copy as real file
  do_cmd cp -a "$src" "$dst"
  ok "Copied: $src -> $dst"
}

# -----------------------
# 1) Place REAL files under ~/.config/dotfiles
# -----------------------

# Bash
copy_real_file "$DOT_SRC/bash/bashrc"         "$DOT_DST/bashrc"
copy_real_file "$DOT_SRC/bash/bash_profile"   "$DOT_DST/bash_profile"
copy_real_file "$DOT_SRC/bash/exports.bash"   "$DOT_DST/exports.bash"
copy_real_file "$DOT_SRC/bash/aliases.bash"   "$DOT_DST/aliases.bash"
copy_real_file "$DOT_SRC/bash/functions.bash" "$DOT_DST/functions.bash"

# Git
copy_real_file "$DOT_SRC/git/.gitconfig"        "$DOT_DST/gitconfig"
copy_real_file "$DOT_SRC/git/.gitignore_global" "$DOT_DST/gitignore_global"

# Optional: local overrides (NOT tracked / safe to edit)
# Only create if absent; never overwrite.
if [[ ! -e "$DOT_DST/gitconfig.local" && ! -L "$DOT_DST/gitconfig.local" ]]; then
  do_cmd touch "$DOT_DST/gitconfig.local"
  ok "Created: $DOT_DST/gitconfig.local"
fi

# Ensure base gitconfig includes local (append once)
if ! is_dry_run; then
  if ! grep -q '^\[include\]' "$DOT_DST/gitconfig" 2>/dev/null || ! grep -q 'gitconfig\.local' "$DOT_DST/gitconfig" 2>/dev/null; then
    {
      echo ""
      echo "[include]"
      echo "  path = ~/.config/dotfiles/gitconfig.local"
    } >> "$DOT_DST/gitconfig"
    ok "Updated: include local gitconfig"
  fi
else
  log "Dry-run: would ensure gitconfig includes ~/.config/dotfiles/gitconfig.local"
fi

# Vim
copy_real_file "$DOT_SRC/vim/.vimrc" "$DOT_DST/vimrc"

# -----------------------
# 2) Link entrypoints in $HOME to the fixed location
# -----------------------
safe_ln_sf "$DOT_DST/bashrc"          "$HOME/.bashrc"
safe_ln_sf "$DOT_DST/bash_profile"    "$HOME/.bash_profile"
safe_ln_sf "$DOT_DST/gitconfig"       "$HOME/.gitconfig"
safe_ln_sf "$DOT_DST/gitignore_global" "$HOME/.gitignore_global"
safe_ln_sf "$DOT_DST/vimrc"           "$HOME/.vimrc"

ok "Dotfiles installed: real files in ~/.config/dotfiles + symlinks in home."
