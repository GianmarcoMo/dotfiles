return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night" },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  { "nvim-tree/nvim-web-devicons", opts = {} },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    opts = { defaults = { layout_config = { prompt_position = "top" }, sorting_strategy = "ascending" } },
    keys = {
      { "<leader>gg", "<cmd>Telescope live_grep<cr>", desc = "Search project text" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Changed Git files" },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { view_options = { show_hidden = true }, delete_to_trash = true },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git / grep" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>c", group = "Code" },
        { "<leader>r", group = "Rename" },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      if vim.fn.executable("tree-sitter") == 1 then
        vim.cmd.TSUpdate()
      end
    end,
    config = function()
      require("nvim-treesitter").setup({})
      -- Parser downloads are explicit: the installer uses the selected languages.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          -- Fall back to normal syntax highlighting until the parser is installed.
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
  },
}
