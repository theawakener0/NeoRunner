local M = {}

-- Load default configuration
M.config = require("neorunner.config")

-- Helper to expand command placeholders
local function expand_cmd(cmd)
  local file = vim.fn.expand("%:p")
  return cmd:gsub("%%", file)
end

local function open_term(cmd)
  local expanded_cmd = expand_cmd(cmd)
  -- 'split' opens a new window, 'resize' sets height, 'terminal' runs the command
  vim.cmd("split | resize 12 | terminal " .. expanded_cmd)
  -- Enter insert mode automatically in the terminal
  vim.cmd("startinsert")
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Create user commands
  vim.api.nvim_create_user_command("NeoRun", M.run, {})
  vim.api.nvim_create_user_command("NeoBuild", M.build, {})
end

function M.run()
  local filetype = vim.bo.filetype
  local runner = M.config.runners[filetype]

  if not runner or not runner.run then
    vim.notify("NeoRunner: No run command configured for filetype '" .. filetype .. "'", vim.log.levels.WARN)
    return
  end

  vim.cmd("write") -- Save before running
  open_term(runner.run)
end

function M.build()
  local filetype = vim.bo.filetype
  local runner = M.config.runners[filetype]

  if not runner or not runner.build then
    vim.notify("NeoRunner: No build command configured for filetype '" .. filetype .. "'", vim.log.levels.WARN)
    return
  end

  vim.cmd("write") -- Save before building
  open_term(runner.build)
end

return M
