# Dotfiles

A general-purpose Neovim configuration for **macOS and Linux**, with a dark theme,
file/text search, completion, code navigation, diagnostics, formatting, and Git tools.
Install only the language tools you need. No configuration can provide full IDE
features for every language without an appropriate language server and project toolchain.

## Requirements

- Neovim **0.12+** and Git.
- Language runtimes only for the profiles you select (see the table below).
- `ripgrep` and `fd` (project text and file search).
- `curl`, `tar`, `gzip`, `unzip`, a C compiler, and **tree-sitter CLI 0.26.1+** (syntax parsers).
  Install the CLI with your package manager, not npm.
- Optional: **lazygit** for a full terminal Git UI, **git-delta** for its colored diffs.
- A Nerd Font selected in your terminal, for example PlemolJP Console NF.
- Your project's compiler/interpreter, dependencies, and build configuration.

## Automatic installation

Clone this repository to any location, then run its installer with Bash:

```sh
git clone <YOUR-REPOSITORY-URL> ~/dotfiles
cd ~/dotfiles
bash scripts/install.sh
```

It asks which language profiles you want, checks requirements, creates a safe symlink
at `~/.config/nvim-dotfiles`, restores locked plugins, and installs the selected language
servers, formatters, and syntax parsers. Already installed tools are reused. The installer
does not remove tools when you choose a different set of languages later.

Noninteractive examples (run from your clone):

```sh
bash scripts/install.sh --languages web,python,lua
bash scripts/install.sh --languages go,rust,c --appname nvim-work
bash scripts/install.sh --list
```

To also offer installation of base OS packages:

```sh
bash scripts/install.sh --languages lua,shell --install-system
```

This asks permission before using Homebrew (macOS), apt (Debian/Ubuntu), dnf (Fedora),
or pacman (Arch). It may request sudo. Arch uses a full system upgrade, not a partial
upgrade. `--yes` confirms this package step noninteractively; it **never** permits
overwriting an existing configuration. Other distributions can use the manual guide.
Some distro repositories have old Neovim or no tree-sitter CLI: the installer checks
versions and stops with instructions instead of claiming success.

System package installation does not install every optional language toolchain. Install
the runtimes in the language table first. On macOS, Homebrew itself must already be
installed. Nothing creates commits, pushes, changes your shell configuration, or deletes
your existing editor setup. Agent instructions are in [`AGENTS.md`](AGENTS.md).

## Language profiles

Choose comma-separated IDs with `--languages`. Use `all` only if you really want all
these tools and have their runtimes. These are common language families, not a promise
of every programming language or identical server features on every platform.

| Profile ID | Languages / files | Language server(s) | Formatting | Extra prerequisites |
| --- | --- | --- | --- | --- |
| `web` | JavaScript, TypeScript, React JSX/TSX, HTML, CSS | vtsls, HTML, CSS | Prettier | Node.js LTS + npm |
| `python` | Python | basedpyright, Ruff | Ruff | Node.js LTS + npm, Python 3 |
| `lua` | Lua | lua-language-server | StyLua | — |
| `shell` | Bash / shell scripts | bash-language-server | shfmt | Node.js LTS + npm |
| `go` | Go | gopls | gofmt | Current Go toolchain |
| `rust` | Rust | rust-analyzer | rustfmt | Rust toolchain, Cargo, rustfmt |
| `c` | C / C++ | clangd | clang-format | Project compiler/build system; compile_commands.json recommended |
| `java` | Java | jdtls | Server formatting | JDK 21+ (or newer if required by jdtls) |
| `csharp` | C# | OmniSharp | Server formatting | Compatible .NET SDK/runtime |
| `ruby` | Ruby | ruby-lsp | Server/project formatter when available | Current Ruby + gem; Bundler for projects |
| `php` | PHP | Intelephense | Server formatting when available | Node.js LTS + npm, PHP |
| `json` | JSON / JSONC | JSON language server | Prettier | Node.js LTS + npm |
| `yaml` | YAML | YAML language server | Prettier | Node.js LTS + npm |
| `toml` | TOML | Taplo | Server formatting | — |
| `markdown` | Markdown | Marksman | Prettier | Node.js LTS + npm |
| `docker` | Dockerfile | Docker language server | When supported by server | Node.js LTS + npm |
| `terraform` | Terraform / HCL | terraform-ls | Server formatting | Terraform |
| `sql` | SQL | sqls | sql-formatter | Go, Node.js LTS + npm; DB connection config for schema completion |
| `cmake` | CMake | neocmakelsp | Server formatting | CMake |
| `kotlin` | Kotlin | Kotlin LSP | Server formatting | Compatible JDK (21+ recommended; follow server requirements) |
| `scala` | Scala | Metals (externally installed) | Server/project formatting | Compatible JDK, Metals on PATH (e.g. installed with Coursier), project build tool |
| `elixir` | Elixir / HEEx | ElixirLS | Server formatting | Elixir, Erlang/OTP, Mix |
| `zig` | Zig | ZLS | Server formatting | Zig version compatible with ZLS |
| `r` | R | R languageserver | Server formatting | R, Rscript; package build dependencies may be needed |
| `dart` | Dart / Flutter | dart language-server (SDK-provided) | Server formatting | Dart SDK or Flutter SDK with `dart` on PATH |
| `swift` | Swift | sourcekit-lsp (SDK-provided) | When supported by server | Swift toolchain with `swift` and `sourcekit-lsp` on PATH |

Neovim still edits other file types normally. Add more languages in
`nvim/lua/config/tools.lua`; keep the installer's accepted IDs in sync. Installed
servers are enabled automatically for matching project files. Unselected languages
do not trigger silent downloads. Some tools have additional platform/version requirements;
an unsupported binary or failed download is reported by the installer.
For Dart and Swift, the SDK supplies the server; these are not downloaded by Mason.
Scala uses an externally installed `metals` executable (for example via Coursier).
Swift is available on both macOS and supported Linux distributions; install a matching
toolchain from swift.org. Mason cannot install compilers or project dependencies for you.

## Manual installation: step by step

### 1. Install base tools

**macOS** with [Homebrew](https://brew.sh):

```sh
brew install neovim git curl node python ripgrep fd tree-sitter lazygit git-delta
xcode-select --install
```

Run `xcode-select --install` only if Apple's command-line developer tools are missing.

**Debian / Ubuntu**:

```sh
sudo apt update
sudo apt install neovim git curl tar gzip unzip build-essential nodejs npm python3 python3-venv ripgrep fd-find
```

`fd` is named `fdfind` here; Telescope recognizes either. Install tree-sitter CLI from
your repository if available or the official release below. Optional tools include
`wl-clipboard` (Wayland), `xclip` (X11), `trash-cli` (Oil trash support), lazygit, and delta.

**Fedora**:

```sh
sudo dnf install neovim git curl tar gzip unzip gcc make nodejs npm python3 ripgrep fd-find tree-sitter-cli
```

**Arch Linux**:

```sh
sudo pacman -Syu --needed neovim git curl tar gzip unzip base-devel nodejs npm python ripgrep fd tree-sitter-cli lazygit git-delta
```

For other distributions, install the same tools with your package manager. Check versions:

```sh
nvim --version
tree-sitter --version
```

You need **Neovim 0.12+** and **tree-sitter CLI 0.26.1+**. If distro packages are older,
download the correct OS/architecture release from:

- [Neovim releases](https://github.com/neovim/neovim/releases): Linux x86_64/ARM64
  archives and installation instructions are provided. Extract into a new directory
  under `~/.local/opt`, then add the archive's `bin` directory to your shell's PATH.
- [Tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases): download
  the matching CLI binary, decompress it, mark it executable, and place it on your PATH
  as `tree-sitter` (for example `~/.local/bin/tree-sitter`). Do not overwrite an existing
  binary without reviewing it. Do **not** use npm to install this CLI.

Use maintained Node.js LTS when selecting Node-based tools. Old distro Node.js packages
may be too old for current language servers. Verify with `node --version` and `npm --version`.
Select a Nerd Font in your terminal for icons; it is not automatically configured.

### 2. Install your chosen language runtimes

Use the language table above. Install project dependencies separately as you normally
would; Neovim does not replace npm, virtual environments, Cargo, Maven, or other build tools.
For example, Go needs the Go toolchain, Rust needs `rustup` plus `rustfmt`, Java needs
a compatible JDK, and C# needs .NET. Use each language's official installation guide.

### 3. Clone the dotfiles

```sh
git clone <YOUR-REPOSITORY-URL> ~/dotfiles
cd ~/dotfiles
```

The clone can live anywhere. Substitute its actual path in the commands below.

### 4. Link a named configuration

Choose a name such as `nvim-dotfiles`. Inspect the destination first:

```sh
ls -ld ~/.config/nvim-dotfiles
```

If it exists and is not already linked to this clone, **stop** and decide whether to
back it up. To preserve it, rename it to an unused backup path, for example:

```sh
mv ~/.config/nvim-dotfiles ~/.config/nvim-dotfiles.backup
```

Only run that command after reviewing both paths. Never overwrite an existing backup.
Then create the link (no `-f`):

```sh
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim-dotfiles
```

These examples use the default config location. If you set `XDG_CONFIG_HOME`, substitute
that directory for `~/.config`; both scripts honor it automatically.

### 5. Install only the editor tools you want

```sh
env NVIM_APPNAME=nvim-dotfiles DOTFILES_LANGUAGES=lua,shell bash scripts/bootstrap.sh
```

Replace `lua,shell` with your own comma-separated selection. This restores locked plugin
versions, installs the selected language tools, and waits for syntax parsers. It exits
nonzero on failure. It does not change the existing default Neovim configuration.

### 6. Start and check Neovim

```sh
env NVIM_APPNAME=nvim-dotfiles nvim
```

Run `:Lazy` for plugins and `:Mason` for language tools. Open a real project file and run
`:checkhealth vim.lsp` to verify the server attached. A plugin loading successfully does
not prove a language server is attached or your project's dependencies are installed.

### 7. Add languages later / retry a failed download

```sh
bash scripts/install.sh --appname nvim-dotfiles --languages go,json
```

Rerun the same command after a network failure. Existing tools are reused; no tools are
uninstalled. Plugin revisions are pinned by `lazy-lock.json`; server and parser versions
are not. Registry refresh has a two-minute timeout; tool and parser installation each
have a five-minute timeout. Slow connections can require another attempt.

## Named profile versus default configuration

**Keep your old default untouched:** use a named profile each time:

```sh
NVIM_APPNAME=nvim-dotfiles nvim
```

The equivalent `env NVIM_APPNAME=nvim-dotfiles nvim` works in Bash, Zsh, and Fish.
The profile has separate config, plugin, server, state, and cache locations on macOS
and Linux (`XDG_*` overrides are respected). No hard-coded Homebrew or user paths are used.

**Make the named profile your usual `nvim`:** add this to your shell configuration:

```sh
# Bash: ~/.bashrc; Zsh: ~/.zshrc
export NVIM_APPNAME=nvim-dotfiles
```

In Fish, use `set -Ux NVIM_APPNAME nvim-dotfiles` instead. Open a new terminal and `nvim`
will use the named profile, including its installed tools. To bypass it once:
`env -u NVIM_APPNAME nvim`. To undo permanently, remove the export or run
`set -eU NVIM_APPNAME` in Fish, then open a new terminal.

**Alternatively, use the standard `~/.config/nvim` location:** inspect it first. If it
already exists, back it up to an unused path yourself; the installer never overwrites it.
Then run:

```sh
bash scripts/install.sh --default --languages lua,shell
env -u NVIM_APPNAME nvim
```

This uses Neovim's default data location too, so tools installed under a named profile
must be installed again. Remove any persistent `NVIM_APPNAME` override if you want plain
`nvim` to use this location. You do not need to delete the old profile or its data.

## Included tools

| Tool | Purpose |
| --- | --- |
| lazy.nvim | Plugin installation, updates, and version lockfile |
| Tokyo Night | Dark theme (`night` variant) |
| nvim-treesitter | More precise syntax highlighting |
| nvim-web-devicons | File icons |
| Telescope + plenary.nvim | Find files, search text, references, changed Git files |
| Neovim LSP + nvim-lspconfig | Definitions, references, hover, rename, diagnostics |
| Mason + mason-lspconfig | Install selected language servers and tools |
| blink.cmp | Completion, using its portable Lua fuzzy matcher |
| Conform | Format with installed tools, or a server that supports formatting |
| gitsigns.nvim | Git change markers, previews, diffs, selected-line/hunk/file resets |
| Lazygit (external, optional) | Repository-wide Git status, staging, commits, and diffs |
| oil.nvim | Edit a directory as a buffer to manage files |
| which-key.nvim | Discover shortcuts after pressing Space |

No AI assistant, debugger, extra dashboard, or full IDE distribution is included.
Neovim's built-in statusline is used.

## Everyday use

Open Neovim from your **project's root directory** so file search, grep, and Lazygit
use the right project. Activate any project environment before launching it. Navigation
and diagnostics depend on an attached server, project configuration, and dependencies.
Formatting on save runs only when an appropriate installed formatter/server is available.

All shortcuts below are in normal mode unless stated otherwise. `Space` is the leader
key; press the keys in order, not simultaneously. Uppercase letters mean Shift.

| Shortcut | Action |
| --- | --- |
| `Space w` / `Space q` | Save / close window |
| `Space g g` | Search text throughout the project (ripgrep) |
| `Space f f` | Find files by name |
| `Space f b` | Switch open buffers |
| `Space f h` | Search Neovim help |
| `Space e` | Browse files with Oil |
| `gd` | Go to definition (function body, variable declaration) |
| `gr` | Find references (where the symbol is used) |
| `gy` | Go to type definition |
| `K` | Hover documentation and type |
| `Ctrl-o` | Jump back after following a definition |
| `Space r n` | Rename symbol across the project |
| `Space c a` | Code actions / available fixes |
| `Space c f` | Format file (also happens on save) |
| `Space d d` | Show diagnostics for the current line |
| `Space d l` | List diagnostics for the current buffer |
| `[d` / `]d` | Previous / next diagnostic (built-in) |
| `Space g s` | List changed Git files, with diff preview |
| `[c` / `]c` | Previous / next changed block (hunk) |
| `Space g p` | Preview the current changed block |
| `Space g d` | Open file diff against the Git index; `:diffoff!` exits diff mode |
| `Space g r` | Discard current hunk, with confirmation |
| Visual selection + `Space g r` | Discard selected changed lines, with confirmation |
| `Space g R` | Discard all unstaged changes in this buffer, with confirmation |
| `Space g l` | Open Lazygit in a terminal tab; press `q` there to quit |
| `Esc Esc` in terminal | Return to normal mode; use `:q` to close the terminal tab |

Git resets above do **not** use stashes. They restore changes relative to the index
(staging area), not necessarily HEAD. Gitsigns operates on tracked files; manage
untracked/new files in Lazygit. Reset shortcuts ask before discarding edits; save
afterward to write the restored buffer to disk. Lazygit has its own confirmations:
read them before accepting destructive operations.

In completion menus, use `Ctrl-n` / `Ctrl-p` to select, `Ctrl-y` to accept,
`Ctrl-space` to open the menu, and `Ctrl-e` to dismiss. Enter keeps its usual newline
behavior. In Telescope, type your search, use `Ctrl-n` / `Ctrl-p`, Enter to open,
and Esc to cancel. Hidden/ignored files are excluded by default.

In Oil, Enter opens a file/directory and `-` goes to the parent. Edit filenames and
save with `:w` to apply operations; review the confirmation. Deletions use the system
trash when available (on Linux, Oil needs a supported trash command such as `trash-put`).

## Configuration layout

```text
nvim/
├── init.lua                 # Entry point
├── lazy-lock.json           # Exact plugin revisions; keep in Git
└── lua/
    ├── config/
    │   ├── options.lua      # Editor settings and diagnostics
    │   ├── keymaps.lua      # General and LSP shortcuts
    │   ├── lazy.lua         # Plugin manager bootstrap
    │   ├── tools.lua        # Shared server, formatter, and parser list
    │   └── bootstrap.lua    # Wait for installations and report failures
    └── plugins/
        ├── editor.lua      # Theme, search, explorer, help, syntax
        ├── coding.lua      # Completion, language servers, formatting
        └── git.lua         # Change markers and safe reset shortcuts
```

`scripts/install.sh` is the installer, `scripts/install-system.sh` handles optional OS
packages, and `scripts/bootstrap.sh` installs selected editor tools after linking.
Invoke scripts by their actual path; they do not depend on the current working directory.

## Updates and troubleshooting

- `:Lazy` shows plugins; `:Lazy update` updates them and rewrites `lazy-lock.json`.
  Review and commit that file yourself. `:Lazy restore` installs the locked revisions
  on another machine (first-time bootstrapping can also use `:Lazy! restore`).
- `:Mason` shows server/formatter installation status. Server and parser versions
  are not pinned by lazy's plugin lockfile.
- `:TSUpdate` updates existing syntax parsers; use the installer to add language profiles.
- `:checkhealth` diagnoses dependencies; `:checkhealth vim.lsp` checks language support.
- `:ConformInfo` explains formatter selection and failures. Prettier uses project
  configuration; prefer a project-local Prettier when you have one installed.
- If a new server does not attach, finish installation, then reopen the file or restart.
  Check `:set filetype?`, project root markers, dependencies, and `:checkhealth vim.lsp`.
- If a download fails, inspect `:MasonLog` and rerun the installer with your language list.
  Until installation succeeds, the affected language features are unavailable.
- Normal syntax colors remain available if parser installation is unavailable.
- A lightweight check is `env NVIM_APPNAME=nvim-dotfiles nvim --headless +qa`.

No credentials, virtual environments, downloaded plugins, or machine-specific paths
belong in this repository. This setup does not create commits or push automatically.
