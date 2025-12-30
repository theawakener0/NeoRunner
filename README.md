# NeoRunner

A very simple plugin to solve a simple problem in nvim.

## Why?

It is reasonable to ask "Why I use this plugin when I can use the ternimal or any other plugin to run/build my code?", and I tell you that this plugin is a solution for a problem I face daily, so I just build it and share it.

You can use the plugin to run/build your code in a split terminal window with a single command. It supports multiple languages out of the box and allows you to easily add or override runners for your specific needs.

## Features

- **Run** and **Build** commands for various languages.
- **Easy configuration**: Add or override runners in your setup.
- **Terminal integration**: Runs commands in a split terminal window.
- **Automatic File Expansion**: Replaces `%` with the current absolute file path.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "dir/to/NeoRunner", -- If developing locally
  -- or if you push to git: "username/NeoRunner"
  config = function()
    require("neorunner").setup()
  end
}
```

## Usage

- `:NeoRun` - Run the current file.
- `:NeoBuild` - Build the current file.

## Configuration

You can configure existing runners or add new ones in the `setup` function.

### Adding a new language (e.g., Java)

```lua
require("neorunner").setup({
  runners = {
    java = {
      run = "javac % && java %<",
    }
  }
})
```

### Overriding an existing runner

```lua
require("neorunner").setup({
  runners = {
    python = {
      run = "python3 -u %", -- Added -u for unbuffered output
    }
  }
})
```

## Default Configuration

```lua
{
  go = {
    run = "go run %",
    build = "go build %",
  },
  python = {
    run = "python3 %",
  },
  lua = {
    run = "lua %",
  },
  c = {
    run = "gcc % -o /tmp/a.out && /tmp/a.out",
    build = "gcc % -o %<",
  },
  cpp = {
    run = "g++ % -std=c++20 -O2 -o /tmp/a.out && /tmp/a.out",
    build = "g++ % -std=c++20 -O2 -o %<",
  },
  rust = {
    run = "cargo run",
    build = "cargo build",
  },
  javascript = {
    run = "node %",
  },
  typescript = {
    run = "ts-node %",
  },
}
```

## Contributing

**Contributions are welcome!**
Feel free to open issues or submit pull requests for bug fixes, improvements, or new features!



