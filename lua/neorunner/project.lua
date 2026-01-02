local M = {}

-- Cache for detected project root and its config
local cached_root = nil
local cached_project_config = nil
local cached_has_neorunner_file = nil

-- Fast-path: cache the language defaults at module load
local language_defaults = require("neorunner.config").runners

local priority_markers = {
  ".neorunner.lua",
  ".git",
}

-- Fallback markers
local marker_groups = {
  { "go.mod", "go.work" },                           -- Go
  { "Cargo.toml", "Cargo.lock" },                    -- Rust
  { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb" }, -- Node.js
  { "deno.json", "deno.jsonc" },                     -- Deno
  { "pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", "Pipfile", "pyrightconfig.json" }, -- Python
  { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "gradlew" }, -- Java/Kotlin
  { "Makefile", "CMakeLists.txt", "meson.build", "build.zig", "vcpkg.json", "conanfile.txt", "conanfile.py" }, -- C/C++
  { "build.sbt" },                                   -- Scala
  { "stack.yaml", "cabal.project" },                 -- Haskell
  { "mix.exs" },                                     -- Elixir
  { "pubspec.yaml" },                                -- Dart/Flutter
  { "composer.json" },                               -- PHP
  { "Gemfile" },                                     -- Ruby
  { ".csproj", ".sln" },                             -- .NET
  { "zig.mod" },                                     -- Zig
}

local function has_project_file(dir, filename)
  return vim.fn.filereadable(dir .. filename) == 1 or vim.fn.isdirectory(dir .. filename) == 1
end

local function find_project_root(path)
  if cached_root then
    return cached_root
  end

  local start_path = path or vim.fn.expand("%:p:h")
  if start_path == "" or start_path == nil then
    return nil
  end

  local current = vim.fn.fnamemodify(start_path, ":p")
  local max_depth = 20
  local home = vim.fn.expand("~")

  for _ = 1, max_depth do
    if current == "/" or current == "" or current == home then
      break
    end

    -- Check priority markers first 
    for _, marker in ipairs(priority_markers) do
      if has_project_file(current, marker) then
        cached_root = current
        return cached_root
      end
    end

    -- Check grouped markers
    for _, group in ipairs(marker_groups) do
      for _, marker in ipairs(group) do
        if has_project_file(current, marker) then
          cached_root = current
          return cached_root
        end
      end
    end

    current = vim.fn.fnamemodify(current, ":h")
  end

  return nil
end

local function load_project_config(root)
  local config_path = root .. ".neorunner.lua"

  -- Fast-path: if we know there's no .neorunner.lua, skip the file check
  if cached_has_neorunner_file == false then
    return nil
  end

  if vim.fn.filereadable(config_path) ~= 1 then
    cached_has_neorunner_file = false
    return nil
  end

  -- Cache the config result
  local ok, config = pcall(dofile, config_path)

  if not ok then
    vim.notify(string.format("NeoRunner: Error loading .neorunner.lua: %s", config), vim.log.levels.ERROR)
    cached_has_neorunner_file = false
    return nil
  end

  if type(config) ~= "table" then
    vim.notify("NeoRunner: .neorunner.lua must return a table", vim.log.levels.WARN)
    cached_has_neorunner_file = false
    return nil
  end

  cached_has_neorunner_file = true
  cached_project_config = config
  return config
end

local function resolve_command(filetype, command_type)
  local root = find_project_root()

  -- Load project config if root found
  if root and not cached_project_config then
    load_project_config(root)
  end

  -- Priority 1: Project config, language-specific
  if cached_project_config then
    local lang_config = cached_project_config[filetype]
    if type(lang_config) == "table" then
      local cmd = lang_config[command_type]
      if type(cmd) == "string" and cmd ~= "" then
        return cmd
      end
    end
  end

  -- Priority 2: Project config, global
  if cached_project_config then
    local cmd = cached_project_config[command_type]
    if type(cmd) == "string" and cmd ~= "" then
      return cmd
    end
  end

  -- Priority 3: Language defaults
  local lang_runner = language_defaults[filetype]
  if lang_runner and lang_runner[command_type] then
    return lang_runner[command_type]
  end

  return nil
end

local function expand_placeholders(cmd)
  local file_path = vim.fn.expand("%:p")
  local file_no_ext = vim.fn.expand("%:p:r")

  -- Single-pass replacement for better performance
  return (cmd:gsub("%%", "'" .. file_path .. "'"):gsub("%%<", "'" .. file_no_ext .. "'"))
end

function M.execute(command_type)
  local filetype = vim.bo.filetype

  if filetype == "" then
    vim.notify("NeoRunner: Cannot determine file type", vim.log.levels.WARN)
    return
  end

  local cmd = resolve_command(filetype, command_type)

  if not cmd then
    vim.notify(
      string.format("NeoRunner: No %s command for '%s'", command_type, filetype),
      vim.log.levels.WARN
    )
    return
  end

  vim.cmd("write")

  local expanded = expand_placeholders(cmd)

  local size = M.config and M.config.term.size or 12
  local pos = M.config and M.config.term.position or "bottom"

  local term_cmd
  if pos == "left" then
    term_cmd = string.format("leftabove vsplit | vertical resize %d | terminal %s", size, expanded)
  elseif pos == "right" then
    term_cmd = string.format("rightbelow vsplit | vertical resize %d | terminal %s", size, expanded)
  elseif pos == "top" then
    term_cmd = string.format("topleft split | resize %d | terminal %s", size, expanded)
  else
    term_cmd = string.format("belowright split | resize %d | terminal %s", size, expanded)
  end

  vim.cmd(term_cmd)
  vim.cmd("startinsert")
end

function M.clear_cache()
  cached_root = nil
  cached_project_config = nil
  cached_has_neorunner_file = nil
end

return M
