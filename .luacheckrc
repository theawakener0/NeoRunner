-- luacheck: globals vim
return {
  read_globals = {
    "vim",
  },
  ignore = {
    "212", -- unused argument (opts in setup)
  },
  exclude_files = {
    "*.md",
  },
}
