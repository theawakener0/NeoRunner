local M = {}
local project = require("neorunner.project")

local function is_term_buffer(bufnr)
  return vim.bo[bufnr].buftype == "terminal"
end

function M.setup(opts)
  local cfg = require("neorunner.config")
  local defaults = cfg.defaults

  M.config = vim.tbl_deep_extend("force", defaults, opts or {})
  M.config.runners = vim.tbl_deep_extend("force", cfg.runners, M.config.runners or {})

  vim.api.nvim_create_user_command("NeoRun", function() project.execute("run") end, {})
  vim.api.nvim_create_user_command("NeoBuild", function() project.execute("build") end, {})
  vim.api.nvim_create_user_command("NeoClose", M.close_term, {})
  vim.api.nvim_create_user_command("NeoTermResize", M.resize_term, { nargs = "?" })
  vim.api.nvim_create_user_command("NeoClearCache", project.clear_cache, {})

  for _, mapping in ipairs(M.config.keymaps or {}) do
    vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3] or "", silent = true })
  end
end

function M.run()
  project.execute("run")
end

function M.build()
  project.execute("build")
end

function M.close_term()
  local bufnr = vim.api.nvim_get_current_buf()
  if is_term_buffer(bufnr) then
    vim.cmd("bdelete!")
  else
    vim.notify("NeoRunner: Not in a terminal buffer", vim.log.levels.INFO)
  end
end

function M.resize_term(size)
  local new_size = tonumber(size) or M.config.term.size
  M.config.term.size = new_size

  local bufnr = vim.api.nvim_get_current_buf()
  if is_term_buffer(bufnr) then
    local pos = M.config.term.position
    if pos == "left" or pos == "right" then
      vim.cmd(string.format("vertical resize %d", new_size))
    else
      vim.cmd(string.format("resize %d", new_size))
    end
  end
end

return M
