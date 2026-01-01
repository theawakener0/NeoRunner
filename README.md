# NeoRunner

> A simple, lightweight, and extensible code runner for Neovim.

NeoRunner allows you to compile and run code directly from Neovim using a terminal split. It comes with defaults for many popular languages but is fully customizable.

## Features

- **Per-Project Config**: Define run/build commands per-project with `.neorunner.lua`.
- **Configurable**: Custom runners, terminal size, position, and keymaps.
- **Smart Expansion**: `%%` for file path, `%%<` for path without extension.
- **Auto-Save**: Saves buffer automatically before execution.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "theawakener0/NeoRunner",
  config = function()
    require("neorunner").setup()
  end
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "theawakener0/NeoRunner",
  config = function()
    require("neorunner").setup()
  end
})
```

## Usage

| Command | Description |
|---------|-------------|
| `:NeoRun` | Run the current file |
| `:NeoBuild` | Build the current file |
| `:NeoClose` | Close the terminal buffer |
| `:NeoTermResize [size]` | Resize terminal (default: 12) |
| `:NeoClearCache` | Clear cached project root |

### Keybindings

```lua
vim.keymap.set("n", "<leader>r", ":NeoRun<CR>", { desc = "Run Code" })
vim.keymap.set("n", "<leader>b", ":NeoBuild<CR>", { desc = "Build Code" })
vim.keymap.set("n", "<leader>c", ":NeoClose<CR>", { desc = "Close Terminal" })
```

## Configuration

Pass options to `setup()`:

```lua
require("neorunner").setup({
  term = {
    size = 15,
    position = "bottom", -- "top", "bottom", "left", or "right"
  },
  keymaps = {
    { "<leader>r", ":NeoRun<CR>", "Run code" },
    { "<leader>b", ":NeoBuild<CR>", "Build code" },
    { "<leader>c", ":NeoClose<CR>", "Close terminal" },
  },
})
```

## Per-Project Configuration

Create a `.neorunner.lua` file in your project root to define project-specific commands.

### Priority Order

Commands are resolved in this order:
1. **Project config** (language-specific) - e.g., `.neorunner.lua` → `java.run`
2. **Project config** (global) - e.g., `.neorunner.lua` → `run`
3. **Language defaults** - Built-in runners
4. **Error** - No command found

### Global Commands

```lua
-- .neorunner.lua
return {
  run = "java Main",
  build = "javac Main.java"
}
```

### Language-Specific Commands

```lua
-- .neorunner.lua
return {
  java = {
    build = "mvn package",
    run = "java -jar target/app.jar"
  },
  python = {
    run = "python -m pytest"
  }
}
```

### Placeholders in Project Config

- `%%` - Full path to file (`/home/user/project/Main.java`)
- `%%<` - Path without extension (`/home/user/project/Main`)

```lua
-- .neorunner.lua
return {
  c = {
    build = "gcc % -o %< -Wall -Wextra",
    run = "%<"
  }
}
```

### Project Root Detection

NeoRunner searches upward from the current buffer for:
1. `.neorunner.lua` (highest priority)
2. `.git`
3. Common project markers: `go.mod`, `Cargo.toml`, `pom.xml`, `package.json`, etc.

The detected root is cached for the session. Use `:NeoClearCache` to refresh.

### Example Project Structure

```
my-java-app/
├── .neorunner.lua       -- Project-specific commands
├── pom.xml
└── src/main/java/
    └── Main.java
```

```lua
-- .neorunner.lua
return {
  java = {
    build = "mvn clean package",
    run = "java -jar target/my-app.jar"
  }
}
```

## Default Runners

| Language | Run Command | Build Command |
|----------|-------------|---------------|
| go | `go run %` | `go build %` |
| python | `python3 %` | - |
| lua | `lua %` | - |
| c | `gcc % -o /tmp/a.out && /tmp/a.out` | `gcc % -o %<` |
| cpp | `g++ % -std=c++20 -O2 -o /tmp/a.out && /tmp/a.out` | `g++ % -std=c++20 -O2 -o %<` |
| rust | `cargo run` | `cargo build` |
| javascript | `node %` | - |
| typescript | `ts-node %` | - |
| ruby | `ruby %` | - |
| java | `java %<` | `javac %` |
| kotlin | `kotlinc % -include-runtime -d %<.jar && java -jar %<.jar` | `kotlinc %` |
| scala | `scala %` | `scalac %` |
| csharp | `dotnet run` | `dotnet build` |
| php | `php %` | - |
| swift | `swift %` | `swiftc % -o %<` |
| haskell | `runhaskell %` | `ghc -o %< %` |
| elixir | `elixir %` | - |
| dart | `dart %` | `dart compile exe %` |
| bash | `bash %` | - |
| powershell | `pwsh -File %` | - |
| dockerfile | `docker build -t myapp . && docker run -it --rm myapp` | - |
| zig | `zig run %` | `zig build-exe %` |
| ocaml | `ocaml %` | - |

## Placeholders

- `%%` - Full path to file (`/home/user/project/main.py`)
- `%%<` - Path without extension (`/home/user/project/main`)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE) for details.
