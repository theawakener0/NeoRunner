local M = {}

local expand_cmd do
  local gsub = string.gsub
  local expand = vim.fn.expand

  function expand_cmd(cmd)
    local file = expand("%:p")
    return gsub(gsub(cmd, "%%", file), "%%<", expand("%:p:r"))
  end
end

local function get_term_cmd(cmd)
  local size = M.config.term.size
  local pos = M.config.term.position
  local expanded = expand_cmd(cmd)

  if pos == "left" then
    return string.format("leftabove vsplit | vertical resize %d | terminal %s", size, expanded)
  elseif pos == "right" then
    return string.format("rightbelow vsplit | vertical resize %d | terminal %s", size, expanded)
  elseif pos == "top" then
    return string.format("topleft split | resize %d | terminal %s", size, expanded)
  else
    return string.format("belowright split | resize %d | terminal %s", size, expanded)
  end
end

local function is_term_buffer(bufnr)
  return vim.bo[bufnr].buftype == "terminal"
end

function M.setup(opts)
  local cfg = require("neorunner.config")
  local defaults = cfg.defaults

  M.config = vim.tbl_deep_extend("force", defaults, opts or {})
  M.config.runners = vim.tbl_deep_extend("force", cfg.runners, M.config.runners or {})

  vim.api.nvim_create_user_command("NeoRun", M.run, {})
  vim.api.nvim_create_user_command("NeoBuild", M.build, {})
  vim.api.nvim_create_user_command("NeoClose", M.close_term, {})
  vim.api.nvim_create_user_command("NeoTermResize", M.resize_term, { nargs = "?" })

  for _, mapping in ipairs(M.config.keymaps or {}) do
    vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3] or "", silent = true })
  end
end

function M.run()
  local runner = M.config.runners[vim.bo.filetype]
  if not runner or not runner.run then
    vim.notify(string.format("NeoRunner: No run command for '%s'", vim.bo.filetype), vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  vim.cmd(get_term_cmd(runner.run))
  vim.cmd("startinsert")
end

function M.build()
  local runner = M.config.runners[vim.bo.filetype]
  if not runner or not runner.build then
    vim.notify(string.format("NeoRunner: No build command for '%s'", vim.bo.filetype), vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  vim.cmd(get_term_cmd(runner.build))
  vim.cmd("startinsert")
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
