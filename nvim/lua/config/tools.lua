-- Server names are nvim-lspconfig IDs; formatter names are Mason package IDs.
local M = {}
M.languages = {
  web = { label = "JavaScript, TypeScript, JSX/TSX, HTML, CSS", servers = { "vtsls", "html", "cssls" }, formatters = { "prettier" }, parsers = { "javascript", "typescript", "tsx", "html", "css" }, requires = { "node", "npm" } },
  python = { label = "Python", servers = { "basedpyright", "ruff" }, parsers = { "python" }, requires = { "node", "npm", "python3" } },
  lua = { label = "Lua", servers = { "lua_ls" }, formatters = { "stylua" }, parsers = { "lua" } },
  shell = { label = "Bash / shell", servers = { "bashls" }, formatters = { "shfmt" }, parsers = { "bash" }, requires = { "node", "npm" } },
  go = { label = "Go", servers = { "gopls" }, parsers = { "go", "gomod", "gosum" }, requires = { "go" } },
  rust = { label = "Rust", servers = { "rust_analyzer" }, parsers = { "rust" }, requires = { "cargo", "rustc", "rustfmt" } },
  c = { label = "C / C++", servers = { "clangd" }, formatters = { "clang-format" }, parsers = { "c", "cpp" } },
  java = { label = "Java", servers = { "jdtls" }, parsers = { "java" }, requires = { "java" } },
  csharp = { label = "C#", servers = { "omnisharp" }, parsers = { "c_sharp" }, requires = { "dotnet" } },
  ruby = { label = "Ruby", servers = { "ruby_lsp" }, parsers = { "ruby" }, requires = { "ruby", "gem" } },
  php = { label = "PHP", servers = { "intelephense" }, parsers = { "php" }, requires = { "node", "npm", "php" } },
  json = { label = "JSON / JSONC", servers = { "jsonls" }, formatters = { "prettier" }, parsers = { "json" }, requires = { "node", "npm" } },
  yaml = { label = "YAML", servers = { "yamlls" }, formatters = { "prettier" }, parsers = { "yaml" }, requires = { "node", "npm" } },
  toml = { label = "TOML", servers = { "taplo" }, parsers = { "toml" } },
  markdown = { label = "Markdown", servers = { "marksman" }, formatters = { "prettier" }, parsers = { "markdown", "markdown_inline" }, requires = { "node", "npm" } },
  docker = { label = "Dockerfile", servers = { "dockerls" }, parsers = { "dockerfile" }, requires = { "node", "npm" } },
  terraform = { label = "Terraform / HCL", servers = { "terraformls" }, parsers = { "terraform", "hcl" }, requires = { "terraform" } },
  sql = { label = "SQL", servers = { "sqls" }, formatters = { "sql-formatter" }, parsers = { "sql" }, requires = { "go", "node", "npm" } },
  cmake = { label = "CMake", servers = { "neocmake" }, parsers = { "cmake" }, requires = { "cmake" } },
  kotlin = { label = "Kotlin", servers = { "kotlin_lsp" }, parsers = { "kotlin" }, requires = { "java" } },
  scala = { label = "Scala", system_servers = { "metals" }, parsers = { "scala" }, requires = { "java", "metals" } },
  elixir = { label = "Elixir", servers = { "elixirls" }, parsers = { "elixir", "heex" }, requires = { "elixir", "mix" } },
  zig = { label = "Zig", servers = { "zls" }, parsers = { "zig" }, requires = { "zig" } },
  r = { label = "R", servers = { "r_language_server" }, parsers = { "r" }, requires = { "R", "Rscript" } },
  -- These servers are installed outside Mason, with their SDK or language tooling.
  dart = { label = "Dart / Flutter", system_servers = { "dartls" }, parsers = { "dart" }, requires = { "dart" } },
  swift = { label = "Swift", system_servers = { "sourcekit" }, parsers = { "swift" }, requires = { "swift", "sourcekit-lsp" } },
}

M.formatters_by_ft = {
  javascript = { "prettier" }, javascriptreact = { "prettier" },
  typescript = { "prettier" }, typescriptreact = { "prettier" },
  html = { "prettier" }, css = { "prettier" }, scss = { "prettier" },
  json = { "prettier" }, jsonc = { "prettier" }, yaml = { "prettier" },
  markdown = { "prettier" }, python = { "ruff_format" }, lua = { "stylua" },
  sh = { "shfmt" }, bash = { "shfmt" }, c = { "clang_format" }, cpp = { "clang_format" },
  go = { "gofmt" }, rust = { "rustfmt" }, sql = { "sql_formatter" },
}

function M.select(selection)
  local names = selection == "all" and vim.tbl_keys(M.languages)
    or vim.split(selection or "", ",", { trimempty = true })
  table.sort(names)
  local result = { names = names, servers = {}, system_servers = {}, formatters = {}, requires = {}, parsers = { "vim", "vimdoc" } }
  for _, name in ipairs(names) do
    local language = assert(M.languages[name], "Unknown language profile: " .. name)
    for _, field in ipairs({ "servers", "system_servers", "formatters", "parsers", "requires" }) do
      for _, value in ipairs(language[field] or {}) do
        if not vim.list_contains(result[field], value) then
          table.insert(result[field], value)
        end
      end
    end
  end
  return result
end

return M
