# Contributing to NeoRunner

Thank you for your interest in contributing! This guide will help you get started.

## How to Contribute

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NeoRunner.git
   cd NeoRunner
   ```
3. **Create a branch** for your feature or bugfix:
   ```bash
   git checkout -b feature/amazing-new-language
   ```
4. **Make your changes**.
5. **Test your changes** with Neovim.
6. **Commit your changes** with a clear message.
7. **Push to GitHub** and open a Pull Request.

## Adding a New Language Runner

To add support for a new language, edit `lua/neorunner/config.lua`.

**Example: Adding Swift support**

```lua
swift = {
  run = "swift %",
  build = "swift build",
},
```

**Requirements for a good runner:**
- The `run` command should compile and execute in one step for interpreted languages.
- Use `%` to represent the current file path (automatically expanded).
- Use `%<` to represent the filename without extension (useful for compilation).
- Ensure commands are cross-platform friendly where possible.

## Code Style

- Use **2-space indentation**.
- Follow **Lua** naming conventions (`snake_case` for variables, `PascalCase` for modules).
- Add clear error messages using `vim.notify`.
- Keep functions small and focused.

## Reporting Issues

When reporting bugs, include:
- Neovim version (`nvim --version`)
- Operating system
- Steps to reproduce the issue
- Any error messages


