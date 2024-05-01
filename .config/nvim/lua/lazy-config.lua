local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	--------
	-- Theme
	--------
	"folke/tokyonight.nvim", -- https://github.com/folke/tokyonight.nvim

	----------------
	-- File Explorer
	----------------
	"nvim-tree/nvim-tree.lua", -- https://github.com/nvim-tree/nvim-tree.lua

	--------
	-- Icons
	--------
	"nvim-tree/nvim-web-devicons", -- https://github.com/nvim-tree/nvim-web-devicons

	-----------------------------------------
	-- Buffer line (with tabpage integration)
	-----------------------------------------
	{
		"akinsho/bufferline.nvim", -- https://github.com/akinsho/bufferline.nvim
		version = "v4.4.0",
		dependencies = "nvim-tree/nvim-web-devicons",
	},

	---------------------
	-- Indentation guides
	---------------------
	{
		"lukas-reineke/indent-blankline.nvim", -- https://github.com/luka-s-reineke/indent-blankline.nvim
		main = "ibl",
		opts = {},
	},

	-------------
	-- Statusline
	-------------
	{
		"nvim-lualine/lualine.nvim", -- https://github.com/nvim-lualine/lualine.nvim
		dependencies = "nvim-tree/nvim-web-devicons",
	},

	---------------
	-- Fuzzy finder
	---------------
	{
		"nvim-telescope/telescope.nvim", -- https://github.com/nvim-telescope/telescope.nvim
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- BurntSushi/ripgrep is required for live_grep and grep_string and is the first priority for find_files.
	-- arch instalation: pacman -S ripgrep

	------------------------------
	-- Git integration for buffers
	------------------------------
	"lewis6991/gitsigns.nvim", -- https://github.com/lewis6991/gitsigns.nvim

	------------------------------------------------------------------
	-- Persist and toggle multiple terminals during an editing session
	------------------------------------------------------------------
	{
		"akinsho/toggleterm.nvim", -- https://github.com/akinsho/toggleterm.nvim
		version = "*",
		config = true,
	},

	-----------------------------
	-- Automatically highlighting
	-----------------------------
	{
		"RRethy/vim-illuminate", -- https://github.com/RRethy/vim-illuminate
		enabled = true,
	},

	-------------------------------------------------------
	-- Nvim Treesitter configurations and abstraction layer
	-------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter", -- https://github.com/nvim-treesitter/nvim-treesitter
		build = ":TSUpdate",
	},

	-----------------
	-- Autocompletion
	-----------------
	-- A completion plugin for neovim coded in Lua.
	"hrsh7th/nvim-cmp", -- https://github.com/hrsh7th/nvim-cmp

	-- nvim-cmp source for neovim builtin LSP client
	"hrsh7th/cmp-nvim-lsp", -- https://github.com/hrsh7th/cmp-nvim-lsp

	-- nvim-cmp source for buffer words
	"hrsh7th/cmp-buffer", -- https://github.com/hrsh7th/cmp-buffer

	-- nvim-cmp source for path
	"hrsh7th/cmp-path", -- https://github.com/hrsh7th/cmp-path

	-- nvim-cmp source for vim's cmdline
	"hrsh7th/cmp-cmdline", -- https://github.com/hrsh7th/cmp-cmdline

	-- nvim-cmp source for nvim lua
	"hrsh7th/cmp-nvim-lua", -- https://github.com/hrsh7th/cmp-nvim-lua

	----------
	-- Snippet
	----------
	-- Snippet Engine for Neovim
	{
		"L3MON4D3/LuaSnip", -- https://github.com/L3MON4D3/LuaSnip
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		build = "make install_jsregexp",
	}, -- install jsregexp (optional!).
	-- luasnip completion source for nvim-cmp
	"saadparwaiz1/cmp_luasnip", -- https://github.com/saadparwaiz1/cmp_luasnip

	------
	-- LSP
	------
	"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig

	------------
	-- Autopairs
	------------
	"windwp/nvim-autopairs", -- https://github.com/windwp/nvim-autopairs

	-----------
	-- Comments
	-----------
	{
		"numToStr/Comment.nvim", -- https://github.com/numToStr/Comment.nvim
		opts = {
			-- add any options here
		},
		lazy = false,
	},

	------------
	-- Which Key
	------------
	{
		"folke/which-key.nvim", -- https://github.com/folke/which-key.nvim
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},

	------------
	-- Formatter
	------------
	{
		"stevearc/conform.nvim", -- https://github.com/stevearc/conform.nvim
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
	},

	----------
	-- Linters
	----------
	{
		"mfussenegger/nvim-lint", -- https://github.com/mfussenegger/nvim-lint
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
	},

	-----------------------------
	-- Package Manager for Neovim
	-----------------------------
	{
		"williamboman/mason.nvim", -- https://github.com/williamboman/mason.nvim
		dependencies = {
			"williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
		},
	},

	----------------------------------------
	-- Improve the default vim.ui interfaces
	----------------------------------------
	"stevearc/dressing.nvim", -- https://github.com/stevearc/dressing.nvim

	----------------------------------------
	-- Vim syntax for helm templates
	----------------------------------------
	"towolf/vim-helm",

	----------------------------------------
	-- Markdown Preview for (Neo)vim
	----------------------------------------
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
})

-- TODO
-- mbbil/undotree
-- {"mfussenegger/nvim-lint"},
-- https://github.com/someone-stole-my-name/yaml-companion.nvim
