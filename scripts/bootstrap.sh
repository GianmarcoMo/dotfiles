#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/${NVIM_APPNAME:-nvim}"

if [[ ! "$config_dir" -ef "$repo_root/nvim" ]]; then
  printf 'ERROR: %s must link to %s/nvim first. See README.md. Nothing was replaced.\n' "$config_dir" "$repo_root" >&2
  exit 1
fi

for tool in nvim git curl tar gzip unzip cc tree-sitter; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'ERROR: Missing prerequisite: %s. Install the requirements in README.md, then retry.\n' "$tool" >&2
    exit 1
  fi
done

if [[ -z "${DOTFILES_LANGUAGES:-}" ]]; then
  printf 'ERROR: Choose language profiles with scripts/install.sh --languages <list>. See README.md.\n' >&2
  exit 1
fi

# The Lua entry point handles failures with :cquit so shell callers get a nonzero exit.
DOTFILES_BOOTSTRAP=1 nvim --headless \
  '+lua require("config.bootstrap").run()'
