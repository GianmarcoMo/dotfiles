#!/usr/bin/env bash
# Called only after explicit confirmation by install.sh --install-system.
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    command -v brew >/dev/null 2>&1 || { printf 'Install Homebrew from https://brew.sh first, then retry.\n' >&2; exit 1; }
    brew install neovim git node python ripgrep fd tree-sitter lazygit git-delta
    if ! xcrun --find clang >/dev/null 2>&1; then
      printf 'Install Apple command-line tools with xcode-select --install, then rerun the installer.\n' >&2
      exit 1
    fi
    ;;
  Linux)
    elevate=()
    if [[ "$(id -u)" != 0 ]]; then
      command -v sudo >/dev/null 2>&1 || { printf 'sudo is required to install system packages.\n' >&2; exit 1; }
      elevate=(sudo)
    fi
    if command -v apt-get >/dev/null 2>&1; then
      "${elevate[@]}" apt-get update
      "${elevate[@]}" apt-get install -y neovim git curl tar gzip unzip build-essential nodejs npm python3 python3-venv ripgrep fd-find
      if apt-cache show tree-sitter-cli >/dev/null 2>&1; then
        "${elevate[@]}" apt-get install -y tree-sitter-cli
      fi
    elif command -v dnf >/dev/null 2>&1; then
      "${elevate[@]}" dnf install -y neovim git curl tar gzip unzip gcc make nodejs npm python3 ripgrep fd-find tree-sitter-cli
    elif command -v pacman >/dev/null 2>&1; then
      # No partial system upgrade; use the normal complete upgrade transaction.
      "${elevate[@]}" pacman -Syu --needed --noconfirm neovim git curl tar gzip unzip base-devel nodejs npm python ripgrep fd tree-sitter-cli lazygit git-delta
    else
      printf 'No supported package manager found. Install requirements manually; see README.md.\n' >&2
      exit 1
    fi
    printf 'Linux: install lazygit/delta and a clipboard provider separately if needed; see README.md.\n'
    ;;
  *) printf 'Only macOS and Linux are supported.\n' >&2; exit 1 ;;
esac

printf 'Base package step finished. The installer will now check actual tool versions.\n'
printf 'Some distributions ship older Neovim or no tree-sitter CLI; see the manual guide if checks fail.\n'
