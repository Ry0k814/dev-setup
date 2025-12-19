#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

DOT_SRC="$ROOT_DIR/dotfiles"
DOT_DST="$HOME/.config/dotfiles"

[[ -d "$DOT_SRC" ]] || { err "Missing dotfiles directory: $DOT_SRC"; exit 1; }

do_cmd mkdir -p "$DOT_DST"

# Link "real" files under ~/.config/dotfiles
safe_ln_sf "$DOT_SRC/bash/exports.bash"     "$DOT_DST/exports.bash"
safe_ln_sf "$DOT_SRC/bash/aliases.bash"     "$DOT_DST/aliases.bash"
safe_ln_sf "$DOT_SRC/bash/functions.bash"   "$DOT_DST/functions.bash"
safe_ln_sf "$DOT_SRC/bash/bashrc"           "$DOT_DST/bashrc"
safe_ln_sf "$DOT_SRC/bash/bash_profile"     "$DOT_DST/bash_profile"

safe_ln_sf "$DOT_SRC/git/.gitconfig"        "$DOT_DST/gitconfig"
safe_ln_sf "$DOT_SRC/git/.gitignore_global" "$DOT_DST/gitignore_global"

safe_ln_sf "$DOT_SRC/vim/.vimrc"            "$DOT_DST/vimrc"

# Link from home to fixed location
safe_ln_sf "$DOT_DST/bashrc"                "$HOME/.bashrc"
safe_ln_sf "$DOT_DST/bash_profile"          "$HOME/.bash_profile"
safe_ln_sf "$DOT_DST/gitconfig"             "$HOME/.gitconfig"
safe_ln_sf "$DOT_DST/gitignore_global"      "$HOME/.gitignore_global"
safe_ln_sf "$DOT_DST/vimrc"                 "$HOME/.vimrc"

ok "Dotfiles linked via ~/.config/dotfiles (bash/git/vim)."
