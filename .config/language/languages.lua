-- Source de vérité unique : langages + formatters.
-- Consommé par :
--   - nvim (init.lua)
--   - scripts/format.lua

local function file_dir(src)
  if src:sub(1, 1) == "@" then
    src = src:sub(2)
  end
  return src:match("^(.*[/\\])") or "./"
end

local LUA_GLOBALS = { "vim", "ya", "cx", "Tab", "Header", "Status", "ui", "_" }
local DIR = file_dir(debug.getinfo(1, "S").source)
local M = {}

local luacheck_config = { "--globals" }
for _, g in ipairs(LUA_GLOBALS) do
  luacheck_config[#luacheck_config + 1] = g
end
luacheck_config[#luacheck_config + 1] = "--no-max-line-length"

M.linters = {
  luacheck = { config = luacheck_config },
  markdownlint = { config = { "--config", DIR .. ".markdownlint.json" } },
}

-- key = nom du built-in conform (utilisé par nvim) ; aussi la clé référencée par languages[*].formatter
-- cmd   : exécutable (script)
-- args  : sous-commande / flags fixes (script)
-- config: flags pointant vers la config déplacée (prepend_args pour conform, et script)
-- write : flags d'écriture en place (script)
-- exts  : extensions de fichiers (script)
M.formatters = {
  stylua = {
    cmd = "stylua",
    args = {},
    config = { "--config-path", DIR .. ".stylua.toml" },
    write = {},
    exts = { "lua" },
  },
  ruff_format = {
    cmd = "ruff",
    args = { "format" },
    config = { "--config", DIR .. "ruff.toml" },
    write = {},
    exts = { "py", "pyi" },
  },
  biome = {
    cmd = "biome",
    args = { "format" },
    config = { "--config-path", DIR .. "biome.json" },
    write = { "--write" },
    exts = { "js", "jsx", "ts", "tsx", "json", "jsonc" },
  },
  rustfmt = {
    cmd = "rustfmt",
    args = { "--edition", "2021" },
    config = { "--config-path", DIR },
    write = {},
    exts = { "rs" },
  },
  ["clang-format"] = {
    cmd = "clang-format",
    args = {},
    config = { "-style=file:" .. DIR .. ".clang-format" },
    write = { "-i" },
    exts = { "c", "cc", "cpp", "cxx", "h", "hh", "hpp", "hxx" },
  },
  shfmt = {
    cmd = "shfmt",
    args = {},
    config = {},
    write = { "-w" },
    exts = { "sh", "bash", "zsh", "ksh", "dash", "mksh", "bats", "ash" },
  },
  taplo = {
    cmd = "taplo",
    args = { "format" },
    config = { "--config", DIR .. ".taplo.toml" },
    write = {},
    exts = { "toml" },
  },
}

M.languages = {
  lua = {
    filetypes = { "lua" },
    treesitter = "lua",
    linter = "luacheck",
    formatter = "stylua",
    lsp = {
      name = "lua_ls",
      config = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = LUA_GLOBALS },
            telemetry = { enable = false },
          },
        },
      },
    },
  },
  python = {
    filetypes = { "python" },
    treesitter = "python",
    linter = "ruff",
    formatter = "ruff_format",
    lsp = false,
  },
  javascript = {
    filetypes = { "javascript" },
    treesitter = "javascript",
    linter = "biomejs",
    formatter = "biome",
    lsp = { name = "ts_ls" },
  },
  typescript = {
    filetypes = { "typescript" },
    treesitter = "typescript",
    linter = "biomejs",
    formatter = "biome",
    lsp = { name = "ts_ls" },
  },
  json = {
    filetypes = { "json", "jsonc" },
    treesitter = "json",
    linter = "biomejs",
    formatter = "biome",
    lsp = false,
  },
  rust = {
    filetypes = { "rust" },
    treesitter = "rust",
    linter = "clippy",
    formatter = "rustfmt",
    lsp = { name = "rust_analyzer" },
  },
  c = {
    filetypes = { "c" },
    treesitter = "c",
    linter = { "clangtidy", "cppcheck" },
    formatter = "clang-format",
    lsp = { name = "clangd" },
  },
  cpp = {
    filetypes = { "cpp" },
    treesitter = "cpp",
    linter = { "clangtidy", "cppcheck" },
    formatter = "clang-format",
    lsp = { name = "clangd" },
  },
  bash = {
    filetypes = { "sh" },
    treesitter = "bash",
    linter = "shellcheck",
    formatter = "shfmt",
    lsp = false,
  },
  toml = {
    filetypes = { "toml" },
    treesitter = "toml",
    linter = false,
    formatter = "taplo",
    lsp = { name = "taplo" },
  },
  yaml = {
    filetypes = { "yaml" },
    treesitter = "yaml",
    linter = "yamllint",
    formatter = false,
    lsp = false,
  },
  markdown = {
    filetypes = { "markdown" },
    treesitter = "markdown",
    linter = "markdownlint",
    formatter = false,
    lsp = false,
  },
}

return M
