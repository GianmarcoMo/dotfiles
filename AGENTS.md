# Repository guide for coding/install agents

## Purpose

This repository contains a portable, modular Neovim configuration for macOS and Linux.
It is language-general: configure common languages, install only user-selected tools.
`nvim/lua/config/tools.lua` is the source of truth for language support and formatting.

## Safety rules

- Never delete, overwrite, reset, or clean an existing configuration or user data without explicit approval.
- Never run `Lazy clean` or `Lazy sync` as part of installation; use locked restoration.
- Never commit, push, change remotes, or install system packages without the user's authorization.
- The installer refuses conflicting links. Do not bypass that check with `ln -sf`.
- Do not assume a username, repository location, Homebrew prefix, Linux distribution, or login shell.
- Do not put credentials, downloaded plugins, language servers, or build artifacts in Git.

## Before installing

1. Read `README.md`, this file, and `scripts/install.sh --help` (run it with Bash).
2. Ask which language profiles the user needs; do not choose `all` silently.
3. Confirm profile name (default `nvim-dotfiles`) versus the default `nvim` configuration.
4. Inspect the destination under `${XDG_CONFIG_HOME:-$HOME/.config}` for conflicts.
5. Check Neovim 0.12+, tree-sitter CLI 0.26.1+, and the base/language prerequisites.
6. Ask permission before system package changes; `--install-system` is opt-in.

## Automatic installation

From the repository, after the user's choices:

```sh
bash scripts/install.sh --languages <comma-separated-profiles> --appname nvim-dotfiles
```

With explicit system-package authorization, append `--install-system`; only append
`--yes` when the user has already approved noninteractive installation. Native package
availability varies; never report success just because the package-manager step finished.
Toolchains such as Go, Rust, Java, .NET, Ruby, PHP, and Terraform must satisfy the selected
language's requirements. The installer does not silently install or replace these toolchains.

If a config exists, stop and ask how the user wants to back it up. No destructive fallback.
On unsupported distributions, follow the manual guide instead of guessing package commands.

## Validation and troubleshooting

- `bash -n scripts/install.sh scripts/install-system.sh scripts/bootstrap.sh`.
- Run installation only for selected languages and with a timeout long enough for downloads.
- Check the bootstrap exit status; a failed/timed-out download is not a completed install.
- Check startup with `NVIM_APPNAME=<profile> nvim --headless +qa`.
- In a real project file, verify the expected server is attached with `:checkhealth vim.lsp`.
- Do not create test projects or claim interactive behavior was tested from headless startup.
- Check `:MasonLog` for download errors. Retry the installer without deleting user directories.
- Report what changed, what was verified, and anything still unavailable.

## Maintenance

- Keep Lua modules small and use existing two-space indentation.
- Keep language selections, README tables, and installer profile validation in sync.
- Preserve `lazy-lock.json`; update it intentionally, not as a side effect of unrelated work.
- Adding an LSP requires its lspconfig ID; resolve Mason package names through mason-lspconfig mappings.
- Keep macOS and Linux paths configurable and quote every shell path.
- This guide is `AGENTS.md` (the standard discovery name), not `agent.md`.
