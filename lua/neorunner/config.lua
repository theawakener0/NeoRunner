local M = {}

M.defaults = {
  term = {
    size = 12,
    position = "bottom",
  },
  keymaps = {},
}

M.runners = {
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

return M
