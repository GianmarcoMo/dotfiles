local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Browse files" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Buffer diagnostics" })
map("n", "<leader>gl", function()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("Install lazygit first; see the dotfiles README.", vim.log.levels.WARN)
    return
  end
  -- A separate tab keeps the terminal out of the editing layout.
  vim.cmd.tabnew()
  local git_root = vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
  vim.fn.jobstart({ "lazygit" }, { term = true, cwd = git_root })
  vim.cmd.startinsert()
end, { desc = "Open Lazygit" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal input mode" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local function lspmap(key, action, description)
      map("n", key, action, { buffer = event.buf, desc = description })
    end
    lspmap("gd", vim.lsp.buf.definition, "Go to definition")
    lspmap("gr", require("telescope.builtin").lsp_references, "Find references")
    lspmap("gD", vim.lsp.buf.declaration, "Go to declaration")
    lspmap("gy", vim.lsp.buf.type_definition, "Go to type definition")
    lspmap("K", vim.lsp.buf.hover, "Documentation / type")
    lspmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    lspmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})
