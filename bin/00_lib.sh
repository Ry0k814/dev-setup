#!/usr/bin/env bash
set -Eeuo pipefail

log()  { printf "\033[0;36m[INFO]\033[0m %s\n" "$*"; }
ok()   { printf "\033[0;32m[ OK ]\033[0m %s\n" "$*"; }
warn() { printf "\033[0;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[0;31m[ERR ]\033[0m %s\n" "$*"; }

is_dry_run() { [[ "${DRY_RUN:-0}" -eq 1 ]]; }

# Print a command and run it unless dry-run.
do_cmd() {
  printf "\033[0;36m[CMD ]\033[0m"
  for a in "$@"; do
    printf " %q" "$a"
  done
  printf "\n"

  if is_dry_run; then
    return 0
  fi
  "$@"
}

run() {
  local script="$1"
  if [[ ! -x "$script" ]]; then
    do_cmd chmod +x "$script" || true
  fi
  log "Running: $(basename "$script")"
  "$script"
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

ensure_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    return 0
  fi
  if ! need_cmd sudo; then
    err "sudo not found. Install sudo or run as root."
    exit 1
  fi

  if is_dry_run; then
    warn "Dry-run: skipping sudo credential check."
    return 0
  fi

  if ! sudo -n true 2>/dev/null; then
    log "Sudo permission required for package install. You may be prompted."
    sudo true
  fi
}

safe_ln_sf() {
  local src="$1"
  local dst="$2"

  do_cmd mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
      ok "Link exists: $dst -> $src"
      return 0
    fi

    local ts backup
    ts="$(date +%Y%m%d%H%M%S)"
    backup="${dst}.bak.${ts}"
    do_cmd mv "$dst" "$backup"
    warn "Backed up: $dst -> $backup"
  fi

  do_cmd ln -s "$src" "$dst"
  ok "Linked: $dst -> $src"
}
