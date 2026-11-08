return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      -- Avoid a native binary/Rust build dependency on another computer.
      fuzzy = { implementation = "lua" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local tools = require("config.tools")
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = { typeCheckingMode = "basic", diagnosticMode = "openFilesOnly" },
            -- Ruff provides import actions and linting.
            disableOrganizeImports = true,
          },
        },
      })
      vim.lsp.config("ruff", {
        on_attach = function(client)
          -- Let basedpyright provide hover documentation.
          client.server_capabilities.hoverProvider = false
        end,
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } },
      })
      local all = tools.select("all")
      require("mason-lspconfig").setup({
        -- Enable installed servers, but never download every language on startup.
        ensure_installed = {},
        automatic_enable = all.servers,
      })
      for _, server in ipairs(all.system_servers) do
        local cmd = vim.lsp.config[server].cmd
        if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
          vim.lsp.enable(server)
        end
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = require("config.tools").formatters_by_ft,
      format_on_save = function(buffer)
        for _, formatter in ipairs(require("conform").list_formatters(buffer)) do
          if formatter.available then
            return { timeout_ms = 2000, lsp_format = "fallback" }
          end
        end
        if #vim.lsp.get_clients({ bufnr = buffer, method = "textDocument/formatting" }) > 0 then
          return { timeout_ms = 2000, lsp_format = "fallback" }
        end
      end,
    },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format file" },
    },
  },
}
