#!/usr/bin/env bash
# Run with Bash on macOS or Linux. Never overwrite an existing configuration.
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
appname="${NVIM_APPNAME:-nvim-dotfiles}"
languages="${DOTFILES_LANGUAGES:-}"
install_system=false
assume_yes=false

usage() {
  cat <<'HELP'
Usage: bash scripts/install.sh [options]
  --languages LIST   Comma-separated profiles, or all; prompts if omitted
  --appname NAME     Named configuration (default: nvim-dotfiles)
  --default          Use ~/.config/nvim (respects XDG_CONFIG_HOME)
  --install-system   Offer to install base packages using the OS package manager
  --yes              Confirm system package installation (never overwrites configs)
  --list             List language profiles and exit
  --help             Show this help

Profiles: web, python, lua, shell, go, rust, c, java, csharp, ruby, php,
          json, yaml, toml, markdown, docker, terraform, sql, cmake,
          kotlin, scala, elixir, zig, r, dart, swift

Examples:
  bash scripts/install.sh --languages web,python,lua
  bash scripts/install.sh --languages go,rust --appname nvim-work
  bash scripts/install.sh --languages lua,shell --default

Install project toolchains (Go, Rust, Java, .NET, etc.) separately; see README.md.
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --languages|--appname)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { printf 'ERROR: %s needs a value.\n' "$1" >&2; exit 1; }
      if [[ "$1" == --languages ]]; then languages="$2"; else appname="$2"; fi
      shift 2 ;;
    --default) appname=nvim; shift ;;
    --install-system) install_system=true; shift ;;
    --yes) assume_yes=true; shift ;;
    --list|--help|-h) usage; exit 0 ;;
    *) printf 'ERROR: Unknown option: %s\n' "$1" >&2; usage >&2; exit 1 ;;
  esac
done

case "$appname" in
  ""|.|..|*[!a-zA-Z0-9_-]*) printf 'ERROR: Use only letters, numbers, hyphens, or underscores in the app name.\n' >&2; exit 1 ;;
esac

if [[ -z "$languages" ]]; then
  usage
  [[ -t 0 ]] || { printf 'ERROR: Noninteractive installation requires --languages.\n' >&2; exit 1; }
  read -r -p 'Which profiles do you want? (comma-separated): ' languages
fi
case "$languages" in
  ""|,*|*,|*,,*) printf 'ERROR: Provide a nonempty comma-separated profile list.\n' >&2; exit 1 ;;
esac
IFS=',' read -r -a selected <<< "$languages"
for language in "${selected[@]}"; do
  case "$language" in
    all) [[ "$languages" == all ]] || { printf 'ERROR: Use all on its own.\n' >&2; exit 1; } ;;
    web|python|lua|shell|go|rust|c|java|csharp|ruby|php|json|yaml|toml|markdown|docker|terraform|sql|cmake|kotlin|scala|elixir|zig|r|dart|swift) ;;
    *) printf 'ERROR: Unknown language profile: %s. Use --list.\n' "$language" >&2; exit 1 ;;
  esac
done

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/$appname"
if [[ -e "$config_dir" || -L "$config_dir" ]]; then
  if [[ ! "$config_dir" -ef "$repo_root/nvim" ]]; then
    printf 'ERROR: %s already exists. Nothing was overwritten.\nBack it up manually as described in README.md, then retry.\n' "$config_dir" >&2
    exit 1
  fi
fi

if $install_system; then
  # Deliberately opt-in: these commands change the machine, not just the repo.
  printf 'This installs base packages using your package manager and may request sudo.\n'
  if [[ "$(uname -s)" == Linux ]] && command -v pacman >/dev/null 2>&1; then
    printf 'On Arch Linux this includes a full system upgrade (pacman -Syu).\n'
  fi
  if ! $assume_yes; then
    [[ -t 0 ]] || { printf 'ERROR: Use --yes to confirm noninteractive package installation.\n' >&2; exit 1; }
    read -r -p 'Continue? [y/N] ' answer
    [[ "$answer" == y || "$answer" == Y ]] || exit 1
  fi
  bash "$repo_root/scripts/install-system.sh"
fi

missing=false
for tool in nvim git curl tar gzip unzip cc tree-sitter rg; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'ERROR: Missing base tool: %s. See README.md or use --install-system.\n' "$tool" >&2
    missing=true
  fi
done
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
  printf 'ERROR: Install fd (called fdfind on Debian/Ubuntu).\n' >&2
  missing=true
fi
$missing && exit 1

nvim_version="$(nvim --version)"
if [[ ! "$nvim_version" =~ NVIM\ v([0-9]+)\.([0-9]+) ]]; then
  printf 'ERROR: Could not determine Neovim version.\n' >&2
  exit 1
fi
if (( BASH_REMATCH[1] == 0 && BASH_REMATCH[2] < 12 )); then
  printf 'ERROR: Neovim 0.12+ is required. Your distro package may be older; see README.md.\n' >&2
  exit 1
fi
ts_version="$(tree-sitter --version)"
if [[ ! "$ts_version" =~ tree-sitter\ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  printf 'ERROR: Could not determine tree-sitter CLI version.\n' >&2; exit 1
fi
major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"; patch="${BASH_REMATCH[3]}"
if (( major == 0 && (minor < 26 || (minor == 26 && patch < 1)) )); then
  printf 'ERROR: tree-sitter CLI 0.26.1+ is required. See README.md.\n' >&2; exit 1
fi

if [[ ! -e "$config_dir" && ! -L "$config_dir" ]]; then
  mkdir -p "$(dirname -- "$config_dir")"
  ln -s "$repo_root/nvim" "$config_dir"
  printf 'Created configuration link: %s\n' "$config_dir"
fi

NVIM_APPNAME="$appname" DOTFILES_LANGUAGES="$languages" bash "$repo_root/scripts/bootstrap.sh"
printf '\nReady. Launch with: NVIM_APPNAME=%s nvim\n' "$appname"
if [[ "$appname" == nvim ]]; then
  printf 'This is also the default when NVIM_APPNAME is unset: nvim\n'
fi
