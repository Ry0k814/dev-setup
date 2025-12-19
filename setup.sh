#!/usr/bin/env bash
set -Eeuo pipefail

# ---------- arg parsing ----------
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --help|-h)
      cat <<'EOF'
Usage:
  ./setup.sh [--dry-run|-n]

Options:
  --dry-run, -n   Print actions without making changes
  --help, -h      Show help
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

export DRY_RUN

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/bin/00_lib.sh"

log "Starting setup (root: $ROOT_DIR, dry-run: $DRY_RUN)"

run "$ROOT_DIR/bin/10_create_dirs.sh"
run "$ROOT_DIR/bin/20_install_packages.sh"
run "$ROOT_DIR/bin/25_install_mise.sh"
run "$ROOT_DIR/bin/30_setup_dotfiles.sh"
run "$ROOT_DIR/bin/40_setup_git.sh"
run "$ROOT_DIR/bin/50_setup_vim.sh"

ok "All done."
