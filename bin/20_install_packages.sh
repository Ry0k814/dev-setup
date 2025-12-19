#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

DISTRO="$(detect_distro)"
ensure_sudo

read_pkgs() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -vE '^\s*#|^\s*$' "$file" || true
}

COMMON_FILE="$ROOT_DIR/config/packages.common.txt"
DISTRO_FILE="$ROOT_DIR/config/packages.${DISTRO}.txt"

COMMON_PKGS="$(read_pkgs "$COMMON_FILE")"
DISTRO_PKGS="$(read_pkgs "$DISTRO_FILE")"

if [[ -z "${COMMON_PKGS}${DISTRO_PKGS}" ]]; then
  warn "No packages listed."
  exit 0
fi

install_debian() {
  do_cmd sudo apt-get update -y
  # shellcheck disable=SC2086
  do_cmd sudo apt-get install -y $COMMON_PKGS $DISTRO_PKGS
}

install_fedora() {
  do_cmd sudo dnf makecache -y
  # shellcheck disable=SC2086
  do_cmd sudo dnf install -y $COMMON_PKGS $DISTRO_PKGS
}

install_arch() {
  do_cmd sudo pacman -Sy --noconfirm
  # shellcheck disable=SC2086
  do_cmd sudo pacman -S --noconfirm --needed $COMMON_PKGS $DISTRO_PKGS
}

case "$DISTRO" in
  ubuntu|debian) install_debian ;;
  fedora)        install_fedora ;;
  arch|manjaro)  install_arch ;;
  *)
    warn "Unknown distro: $DISTRO"
    warn "Skipping package install. Install packages manually (see config/)."
    ;;
esac

ok "Packages installed (or attempted)."
