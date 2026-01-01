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
  ruby = {
    run = "ruby %",
  },
  java = {
    run = "java %<",
    build = "javac %",
  },
  kotlin = {
    run = "kotlinc % -include-runtime -d %<.jar && java -jar %<.jar",
    build = "kotlinc %",
  },
  scala = {
    run = "scala %",
    build = "scalac %",
  },
  csharp = {
    run = "dotnet run",
    build = "dotnet build",
  },
  php = {
    run = "php %",
  },
  swift = {
    run = "swift %",
    build = "swiftc % -o %<",
  },
  haskell = {
    run = "runhaskell %",
    build = "ghc -o %< %",
  },
  elixir = {
    run = "elixir %",
  },
  dart = {
    run = "dart %",
    build = "dart compile exe %",
  },
  bash = {
    run = "bash %",
  },
  powershell = {
    run = "pwsh -File %",
  },
  dockerfile = {
    run = "docker build -t myapp . && docker run -it --rm myapp",
  },
  zig = {
    run = "zig run %",
    build = "zig build-exe %",
  },
  ocaml = {
    run = "ocaml %",
  },
}

return M
