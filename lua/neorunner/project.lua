local M = {}

-- Cache for detected project root
local cached_root = nil

-- Ordered by specificity: .neorunner.lua is most specific, then .git, then language markers.
local project_markers = {
  ".neorunner.lua",  -- Project config (highest priority)
  ".git",            -- Git repository root
  "go.mod",          -- Go modules
  "go.work",         -- Go workspace
  "pom.xml",         -- Maven
  "Cargo.toml",      -- Rust
  "package.json",    -- Node.js
  "package-lock.json", -- Node.js (npm)
  "yarn.lock",       -- Node.js (yarn)
  "pnpm-lock.yaml",  -- Node.js (pnpm)
  "bun.lockb",       -- Bun
  "deno.json",       -- Deno
  "deno.jsonc",      -- Deno
  "pyproject.toml",  -- Python (Poetry/setuptools)
  "requirements.txt", -- Python (pip)
  "setup.py",        -- Python (setuptools)
  "setup.cfg",       -- Python (setuptools)
  "Pipfile",         -- Python (pipenv)
  "Makefile",        -- C/C++
  "CMakeLists.txt",  -- C/C++
  "meson.build",     -- Meson build system
  "build.gradle",    -- Gradle (Java/Kotlin)
  "build.gradle.kts", -- Gradle Kotlin DSL
  "settings.gradle", -- Gradle
  "gradlew",         -- Gradle wrapper
  "build.sbt",       -- Scala (sbt)
  "stack.yaml",      -- Haskell (Stack)
  "cabal.project",   -- Haskell (Cabal)
  "mix.exs",         -- Elixir (Mix)
  "pubspec.yaml",    -- Dart/Flutter
  "composer.json",   -- PHP (Composer)
  "Gemfile",         -- Ruby (Bundler)
  ".csproj",         -- C# project
  ".sln",            -- .NET solution
  "zig.mod",         -- Zig
  "build.zig",       -- Zig
  "vcpkg.json",      -- C/C++ (vcpkg)
  "conanfile.txt",   -- C/C++ (Conan)
  "conanfile.py",    -- C/C++ (Conan)
}

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
    -- Stop at filesystem root or home
    if current == "/" or current == "" or current == home then
      break
    end

    -- Check if this directory contains any project marker
    for _, marker in ipairs(project_markers) do
      local marker_path = current .. marker
      if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
        cached_root = current
        return cached_root
      end
    end

    -- Move to parent directory
    current = vim.fn.fnamemodify(current, ":h")
  end

  return nil
end

--- Load .neorunner.lua from project root safely.
local function load_project_config(root)
  local config_path = root .. ".neorunner.lua"

  if vim.fn.filereadable(config_path) ~= 1 then
    return nil
  end

  local ok, config = pcall(dofile, config_path)

  if not ok then
    vim.notify(
      string.format("NeoRunner: Error loading .neorunner.lua: %s", config),
      vim.log.levels.ERROR
    )
    return nil
  end

  if type(config) ~= "table" then
    vim.notify(
      "NeoRunner: .neorunner.lua must return a table",
      vim.log.levels.WARN
    )
    return nil
  end

  return config
end

--- Resolve command for a given filetype using project config and language defaults.
local function resolve_command(filetype, command_type)
  local root = find_project_root()
  local project_config = root and load_project_config(root)
  local language_defaults = require("neorunner.config").runners

  -- Priority 1: Project config, language-specific
  if project_config and type(project_config[filetype]) == "table" then
    local cmd = project_config[filetype][command_type]
    if cmd and type(cmd) == "string" and cmd ~= "" then
      return cmd
    end
  end

  -- Priority 2: Project config, global
  if project_config then
    local cmd = project_config[command_type]
    if cmd and type(cmd) == "string" and cmd ~= "" then
      return cmd
    end
  end

  -- Priority 3: Language defaults
  local lang_runner = language_defaults[filetype]
  if lang_runner and lang_runner[command_type] then
    return lang_runner[command_type]
  end

  -- Priority 4: Not found - return nil
  return nil
end

--- Execute a command in the terminal.
function M.execute(command_type)
  local filetype = vim.bo.filetype

  if filetype == "" then
    vim.notify("NeoRunner: Cannot determine file type", vim.log.levels.WARN)
    return
  end

  local cmd = resolve_command(filetype, command_type)

  if not cmd then
    vim.notify(
      string.format(
        "NeoRunner: No %s command found for '%s' (project or language default)",
        command_type,
        filetype
      ),
      vim.log.levels.WARN
    )
    return
  end

  vim.cmd("write")

  local expanded = cmd
    :gsub("%%", vim.fn.expand("%:p"))
    :gsub("%%<", vim.fn.expand("%:p:r"))

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

--- Invalidate cached project root (for testing or manual refresh).
function M.clear_cache()
  cached_root = nil
end

return M
