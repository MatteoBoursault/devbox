-- ============================================================
-- Helpers
-- ============================================================
Map = vim.keymap.set
function Nmap(lhs, rhs, desc, opts)
	Map("n", lhs, rhs, vim.tbl_extend("force", { desc = desc, silent = true, noremap = true }, opts or {}))
end
function Vmap(lhs, rhs, desc, opts)
	Map("v", lhs, rhs, vim.tbl_extend("force", { desc = desc, silent = true, noremap = true }, opts or {}))
end
function Nvmap(lhs, rhs, desc, opts)
	Map({ "n", "v" }, lhs, rhs, vim.tbl_extend("force", { desc = desc, silent = true, noremap = true }, opts or {}))
end

-- ============================================================
-- SECTION 1 : FONDATIONS
-- ============================================================
do
	vim.loader.enable()

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	vim.opt.updatetime = 250
	vim.opt.timeoutlen = 500

	-- UI
	vim.g.have_nerd_font = true
	vim.opt.termguicolors = true
	vim.opt.showmode = false
	vim.opt.showmatch = true
	vim.opt.cursorline = false
	vim.opt.signcolumn = "yes"
	vim.opt.cmdheight = 1
	vim.opt.pumheight = 10
	vim.opt.pumblend = 0
	vim.opt.winblend = 0
	vim.opt.conceallevel = 0
	vim.opt.concealcursor = ""
	vim.opt.fillchars = { eob = " " }
	vim.opt.errorbells = false

	-- Numérotation
	vim.opt.number = true
	vim.opt.relativenumber = true

	-- Curseur
	vim.opt.wrap = false
	vim.opt.scrolloff = 10
	vim.opt.sidescrolloff = 10

	-- Indentation
	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.softtabstop = 2
	vim.opt.expandtab = true
	vim.opt.smartindent = true
	vim.opt.autoindent = true

	-- Recherche
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.incsearch = true
	vim.opt.path:append("**")
	vim.opt.inccommand = "split"

	-- Cache
	vim.opt.backup = false
	vim.opt.writebackup = false
	vim.opt.swapfile = false
	vim.opt.undofile = true

	-- Édition
	vim.opt.iskeyword:append("-")
	vim.opt.selection = "inclusive"
	vim.opt.backspace = "indent,eol,start"
	vim.opt.completeopt = "menuone,noinsert,noselect"

	-- Folding (treesitter)
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.opt.foldlevel = 99

	-- Splits
	vim.opt.splitbelow = true
	vim.opt.splitright = true

	-- Divers
	vim.opt.hidden = true
	vim.opt.autoread = true
	vim.opt.autochdir = false
	vim.opt.modifiable = true
	vim.opt.encoding = "utf-8"
	vim.schedule(function()
		vim.opt.clipboard = "unnamedplus"
	end)

	-- Navigation (dvorak)
	Nvmap("t", function()
		return vim.v.count == 0 and "gj" or "j"
	end, "Down (wrap-aware)", { expr = true })
	Nvmap("n", function()
		return vim.v.count == 0 and "gk" or "k"
	end, "Up (wrap-aware)", { expr = true })
	Nvmap("h", "l", "Right")
	Nvmap("s", "h", "Left")

	-- Splits
	Nmap("<leader>sv", ":vsplit<CR>", "Split vertical")
	Nmap("<leader>sb", ":split<CR>", "Split horizontal")

	-- Recherche
	Nmap("l", "nzzzv", "Next search result (centered)")
	Nmap("L", "Nzzzv", "Previous search result (centered)")

	-- Buffers
	Nmap("<leader>bl", ":bnext<CR>", "Buffer suivant")
	Nmap("<leader>bp", ":bprevious<CR>", "Buffer précédent")

	-- Diagnostics
	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },
		virtual_text = true,
		virtual_lines = false,
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
			end,
		},
	})

	Nmap("<leader>d", vim.diagnostic.setloclist, "Open diagnostic quickfix list")
	Nmap("<leader>td", function()
		vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	end, "Toggle diagnostics")

	-- Indentation
	Vmap("<", "<gv", "Désindenter et resélectionner")
	Vmap(">", ">gv", "Indenter et resélectionner")

	-- Divers
	Nmap("J", "mzJ`z", "Join lines keeping cursor position")

	Nmap("<leader>q", ":q!<CR>", "Quit (force)")
	Nmap("<leader>w", ":w<CR>", "Save")

	Nmap("<Esc>", "<cmd>nohlsearch<CR>")

	local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking",
		group = augroup,
		callback = function()
			vim.hl.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("BufReadPost", {
		group = augroup,
		desc = "Restore last cursor position",
		callback = function()
			if vim.o.diff then
				return
			end
			local last_pos = vim.api.nvim_buf_get_mark(0, '"')
			local last_line = vim.api.nvim_buf_line_count(0)
			if last_pos[1] < 1 or last_pos[1] > last_line then
				return
			end
			pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "markdown", "text", "gitcommit" },
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
		end,
	})
end

-- ============================================================
-- SECTION 2 : LANGAGES
-- [1] filetypes   [2] treesitter   [3] linter   [4] formatter   [5] lsp
-- ============================================================
local lua_ls_settings = {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
}

local languages = {
	lua = { { "lua" }, "lua", "luacheck", "stylua", { "lua_ls", lua_ls_settings } },
	python = { { "python" }, "python", "ruff", "ruff_format", false },
	javascript = { { "javascript" }, "javascript", "biomejs", "biome", { "ts_ls" } },
	typescript = { { "typescript" }, "typescript", "biomejs", "biome", { "ts_ls" } },
	json = { { "json", "jsonc" }, "json", "biomejs", "biome", false },
	rust = { { "rust" }, "rust", "clippy", "rustfmt", { "rust_analyzer" } },
	c = { { "c" }, "c", { "clangtidy", "cppcheck" }, "clang_format", { "clangd" } },
	cpp = { { "cpp" }, "cpp", { "clangtidy", "cppcheck" }, "clang_format", { "clangd" } },
	bash = { { "sh" }, "bash", "shellcheck", "shfmt", false },
	toml = { { "toml" }, "toml", false, "taplo", { "taplo" } },
	yaml = { { "yaml" }, "yaml", "yamllint", false, false },
	markdown = { { "markdown" }, "markdown", "markdownlint", false, false },
}

-- ============================================================
-- SECTION 3 : PLUGINS
-- ============================================================
do
	vim.pack.add({
		"https://github.com/rebelot/kanagawa.nvim",
		"https://github.com/nvim-mini/mini.nvim",
		"https://github.com/ibhagwan/fzf-lua",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/stevearc/conform.nvim",
		"https://github.com/mfussenegger/nvim-lint",
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
		{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
		{ src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
		"https://github.com/rafamadriz/friendly-snippets",
	})

	vim.api.nvim_create_user_command("PackUpdate", function()
		vim.pack.update()
	end, {})
end

-- ============================================================
-- SECTION 4 : THÈME & UI
-- ============================================================
do
	require("kanagawa").setup({ commentStyle = { italic = false }, theme = "wave" })
	vim.cmd.colorscheme("kanagawa-wave")

	require("mini.comment").setup({})
	require("mini.trailspace").setup({})
	require("mini.notify").setup({})
	require("mini.icons").setup({})
	require("mini.surround").setup({})
	require("mini.ai").setup({
		mappings = { around_next = "aa", inside_next = "ii" },
		n_lines = 500,
	})
	require("mini.statusline").setup({})
end

-- ============================================================
-- SECTION 5 : PICKER (fzf-lua + skim)
-- ============================================================
do
	local fzf = require("fzf-lua")
	fzf.setup({ fzf_bin = "sk" })

	Nmap("<leader>ff", fzf.files, "Find files")
	Nmap("<leader>fg", fzf.live_grep, "Live grep")
	Nmap("<leader>fb", fzf.buffers, "Buffers")
	Nmap("<leader>fh", fzf.help_tags, "Help tags")
	Nmap("<leader>fr", fzf.resume, "Resume last picker")
	Nmap("<leader>f.", fzf.oldfiles, "Recent files")
	Nmap("<leader>sw", fzf.grep_cword, "Grep word under cursor")
	Nmap("<leader>fx", fzf.diagnostics_document, "Buffer diagnostics")
	Nmap("<leader>fX", fzf.diagnostics_workspace, "Workspace diagnostics")
end

-- ============================================================
-- SECTION 6 : LSP
-- ============================================================
do
	local fzf = require("fzf-lua")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("K", vim.lsp.buf.hover, "Hover")
			map("grn", vim.lsp.buf.rename, "Rename")
			map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
			map("grD", vim.lsp.buf.declaration, "Declaration")
			map("grr", fzf.lsp_references, "References")
			map("gri", fzf.lsp_implementations, "Implementations")
			map("grd", fzf.lsp_definitions, "Definitions")
			map("grt", fzf.lsp_typedefs, "Type definition")
			map("gO", fzf.lsp_document_symbols, "Document symbols")
			map("gW", fzf.lsp_live_workspace_symbols, "Workspace symbols")
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "Toggle inlay hints")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method("textDocument/documentHighlight", event.buf) then
				local grp = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = grp,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = grp,
					callback = vim.lsp.buf.clear_references,
				})
			end
		end,
	})

	for _, lang in pairs(languages) do
		local lsp = lang[5]
		if lsp then
			if lsp[2] then
				vim.lsp.config(lsp[1], lsp[2])
			end
			vim.lsp.enable(lsp[1])
		end
	end
end

-- ============================================================
-- SECTION 7 : FORMATAGE (conform)
-- ============================================================
do
	local formatters_by_ft = {}
	for _, lang in pairs(languages) do
		if lang[4] then
			for _, ft in ipairs(lang[1]) do
				formatters_by_ft[ft] = { lang[4] }
			end
		end
	end

	require("conform").setup({
		formatters_by_ft = formatters_by_ft,
		format_on_save = { timeout_ms = 500 },
		default_format_opts = { lsp_format = "fallback" },
	})

	Nmap("<leader>f", function()
		require("conform").format({ async = true })
	end, "Format buffer")
end

-- ============================================================
-- SECTION 8 : LINT (nvim-lint)
-- ============================================================
do
	local linters_by_ft = {}
	for _, lang in pairs(languages) do
		if lang[3] then
			local linters = type(lang[3]) == "table" and lang[3] or { lang[3] }
			for _, ft in ipairs(lang[1]) do
				linters_by_ft[ft] = linters
			end
		end
	end

	require("lint").linters_by_ft = linters_by_ft

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("lint", { clear = true }),
		callback = function()
			require("lint").try_lint()
		end,
	})
end

-- ============================================================
-- SECTION 9 : TREESITTER
-- ============================================================
do
	local parsers = { "diff", "query", "vim", "vimdoc", "luadoc" }
	for _, lang in pairs(languages) do
		if lang[2] and not vim.tbl_contains(parsers, lang[2]) then
			table.insert(parsers, lang[2])
		end
	end

	require("nvim-treesitter").install(parsers)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(args.match)
			if not lang or not vim.treesitter.language.add(lang) then
				return
			end
			vim.treesitter.start(args.buf, lang)
		end,
	})
end

-- ============================================================
-- SECTION 10 : AUTOCOMPLÉTION & SNIPPETS
-- ============================================================
do
	require("luasnip").setup({})
	require("luasnip.loaders.from_vscode").lazy_load()

	require("blink.cmp").setup({
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
		sources = { default = { "lsp", "path", "snippets" } },
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "lua" },
		signature = { enabled = true },
	})
end

-- ============================================================
-- SECTION 11 : DIFF (vimdiff)
-- ============================================================
do
	vim.opt.diffopt:append({ "algorithm:histogram", "indent-heuristic" })
end
