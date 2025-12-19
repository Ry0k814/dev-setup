export LANG=ja_JP.UTF-8
export EDITOR=vim

# ---------- PATH helpers ----------
path_prepend() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in *":$dir:"*) ;; *) PATH="$dir:$PATH" ;; esac
}

path_append() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in *":$dir:"*) ;; *) PATH="$PATH:$dir" ;; esac
}

# ---------- user bins ----------
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/tools/bin"

# ---------- mise ----------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# ---------- asdf (optional / lower priority) ----------
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  . "$HOME/.asdf/asdf.sh"
  ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
  path_append "$ASDF_DATA_DIR/bin"
  path_append "$ASDF_DATA_DIR/shims"
fi
