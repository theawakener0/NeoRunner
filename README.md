# NeoRunner

> A simple, lightweight, and extensible code runner for Neovim.

NeoRunner allows you to compile and run code directly from Neovim using a terminal split. It comes with defaults for many popular languages but is fully customizable.

## Features

- **Configurable**: Custom runners, terminal size, direction, position, and keymaps.
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
    size = 15,        -- Terminal height/width
    direction = "horizontal", -- "horizontal" or "vertical"
    position = "bottom", -- "top", "bottom", "left", or "right"
  },
  keymaps = {
    { "<leader>r", ":NeoRun<CR>", "Run code" },
    { "<leader>b", ":NeoBuild<CR>", "Build code" },
    { "<leader>c", ":NeoClose<CR>", "Close terminal" },
  },
})
```

### Default Runners

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

### Adding Custom Runners

```lua
require("neorunner").setup({
  java = {
    run = "javac % && java %<",
    build = "javac %",
  },
  bash = {
    run = "bash %",
  },
})
```

## Placeholders

- `%%` - Full path to file (`/home/user/project/main.py`)
- `%%<` - Path without extension (`/home/user/project/main`)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE) for details.
