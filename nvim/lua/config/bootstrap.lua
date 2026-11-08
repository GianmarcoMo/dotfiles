local M = {}

local function install()
  assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
  local tools = require("config.tools").select(vim.env.DOTFILES_LANGUAGES or "")
  assert(#tools.names > 0, "Choose languages with scripts/install.sh --languages <list>")
  for _, executable in ipairs(tools.requires) do
    assert(vim.fn.executable(executable) == 1, "Missing language prerequisite: " .. executable .. ". See README.md.")
  end
  local failures = {}
  local function fail(message)
    failures[#failures + 1] = message
    print("FAIL: " .. message)
  end

  print("Restoring locked plugin versions...")
  require("lazy").restore({ wait = true, show = false })
  local plugins = require("lazy.core.config").plugins
  local names = {}
  for name, plugin in pairs(plugins) do
    assert(vim.uv.fs_stat(plugin.dir), "Plugin missing: " .. name)
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), "Plugin failed: " .. name .. "\n" .. task:output())
    end
    names[#names + 1] = name
  end
  require("lazy").load({ plugins = names })
  assert(vim.v.errmsg == "", vim.v.errmsg)
  print("OK: plugins loaded")

  local registry = require("mason-registry")
  local refreshed, refresh_ok = false, false
  print("Refreshing Mason registry...")
  registry.refresh(function(success)
    refresh_ok = success
    refreshed = true
  end)
  if not vim.wait(120000, function() return refreshed end, 100) or not refresh_ok then
    fail("Mason registry download failed or timed out. Check :MasonLog and retry this command.")
  else
    local pending = {}
    -- Mason package names differ from LSP IDs (e.g. lua_ls -> lua-language-server).
    local mappings = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
    local packages = vim.deepcopy(tools.formatters)
    for _, server in ipairs(tools.servers) do
      local package_name = assert(mappings[server], "No Mason package for " .. server)
      if not vim.list_contains(packages, package_name) then
        table.insert(packages, package_name)
      end
    end
    for _, name in ipairs(packages) do
      local pkg = registry.get_package(name)
      if pkg:is_installed() then
        print("OK: " .. name .. " already installed")
      else
        pending[name] = true
        print("Installing " .. name .. "...")
        pkg:install({}, function(success, result)
          if success then
            print("OK: " .. name)
          else
            fail(name .. ": " .. tostring(result))
          end
          pending[name] = nil
        end)
      end
    end
    if not vim.wait(300000, function() return next(pending) == nil end, 100) then
      for name in pairs(pending) do
        fail(name .. ": installation timed out")
      end
    end
    -- Validate each package's actual executable links, not a language-specific list.
    for _, name in ipairs(packages) do
      local pkg = registry.get_package(name)
      for executable in pairs(pkg.spec.bin or {}) do
        if vim.fn.executable(executable) ~= 1 then
          fail("Executable unavailable: " .. executable)
        end
      end
    end
  end

  print("Installing syntax parsers...")
  local ok, err = pcall(function()
    require("nvim-treesitter").install(tools.parsers):wait(300000)
    for _, parser in ipairs(tools.parsers) do
      local loaded, reason = pcall(vim.treesitter.language.add, parser)
      assert(loaded, parser .. ": " .. tostring(reason))
    end
  end)
  if ok then
    print("OK: syntax parsers")
  else
    fail("Syntax parsers: " .. tostring(err))
  end

  assert(#failures == 0, table.concat(failures, "\n"))
  print("Bootstrap complete. Open a project with this Neovim profile.")
end

function M.run()
  local ok, err = pcall(install)
  if not ok then
    io.stderr:write("\nBOOTSTRAP FAILED\n" .. tostring(err) .. "\nFix the problem and rerun the same bootstrap command.\n")
    vim.cmd("cquit 1")
    return
  end
  vim.cmd("qa!")
end

return M
