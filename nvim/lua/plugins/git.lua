return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, key, action, description)
          vim.keymap.set(mode, key, action, { buffer = buffer, desc = description })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Next Git change")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Previous Git change")
        map("n", "<leader>gp", gs.preview_hunk, "Preview changed block")
        map("n", "<leader>gr", function()
          if vim.fn.confirm("Discard this changed block?", "&No\n&Yes", 1) == 2 then
            gs.reset_hunk()
          end
        end, "Discard changed block (confirm)")
        map("x", "<leader>gr", function()
          local first, last = vim.fn.line("v"), vim.fn.line(".")
          if vim.fn.confirm("Discard selected changed lines?", "&No\n&Yes", 1) == 2 then
            gs.reset_hunk({ math.min(first, last), math.max(first, last) })
          end
        end, "Discard selected changes (confirm)")
        map("n", "<leader>gR", function()
          if vim.fn.confirm("Discard ALL unstaged changes in this buffer?", "&No\n&Yes", 1) == 2 then
            gs.reset_buffer()
          end
        end, "Discard file changes (confirm)")
        map("n", "<leader>gd", gs.diffthis, "Diff file against Git index")
      end,
    },
  },
}
