local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  -- Resolve the real path so the lockfile stays in the repo when using a symlink.
  lockfile = (vim.uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config"))
    .. "/lazy-lock.json",
  change_detection = { notify = false },
  checker = { enabled = false },
})
