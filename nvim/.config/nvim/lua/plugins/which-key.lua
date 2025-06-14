----------------------------------------------------------------------------------------------------
--                                          Which-Key
----------------------------------------------------------------------------------------------------
-- References:
-- - https://github.com/folke/which-key.nvim

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

-- local setup = {}

which_key = require("which-key")
which_key.add({
	{
		mode = "n",
		icon = { icon = "󰊢 ", color = "orange" },
		{ "<leader>g", group = "git" }, -- group
		{ "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", desc = "Lazygit" },
		{ "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
		{ "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = "Prev Hunk" },
		{ "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame Line" },
		{ "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
		{ "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
		{ "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
		{ "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
		{ "<leader>gS", "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", desc = "Stage Buffer" },
		{ "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },
		{ "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
		{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
		{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
		{ "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Diff", icon = { icon = " ", color = "orange" } },
		{ "<leader>gt", "<cmd>lua require 'gitsigns'.toggle_current_line_blame()<cr>", desc = "Toggle Line Blame" },
	},
	{
		mode = "n",
		{ "<leader>s", group = "search" }, -- group
		{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find File" },
		{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
		{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Marks" },
		{ "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>sr", "<cmd>Telescope registers<cr>", desc = "Registers" },
		{ "<leader>sc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
		{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
		{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
	},
	{
		mode = "n",
		{ "<leader>t", group = "terminal" }, -- group
		{ "<leader>tt", "<cmd>lua _HTOP_TOGGLE()<cr>", desc = "Htop" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
		{ "<leader>th", "<cmd>ToggleTerm size=20 direction=horizontal<cr>", desc = "Horizontal" },
		{ "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical" },
	},
	{
		mode = "n",
		{ "<leader>l", group = "LSP" }, -- group
		{ "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
		{ "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
		{ "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
	},
})

-- local opts = {
-- 	mode = "n", -- NORMAL mode
-- 	prefix = "<leader>",
-- 	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
-- 	silent = true, -- use `silent` when creating keymaps
-- 	noremap = true, -- use `noremap` when creating keymaps
-- 	nowait = true, -- use `nowait` when creating keymaps
-- }
--
-- local mappings = {
-- 	["b"] = {
-- 		"<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
-- 		"Buffers",
-- 	},
-- 	["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
-- 	["w"] = { "<cmd>w!<CR>", "Save Buffer" },
-- 	["q"] = { "<cmd>qa<CR>", "Quit" },
-- 	["c"] = { "<cmd>w<CR>:bd<CR>", "Save and Close Buffer" },
-- 	["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
-- 	["x"] = { "<cmd>wa<CR>:qa<CR>", "Save all and quit" },
-- 	["f"] = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files" },
-- 	["F"] = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
-- 	-- ["P"] = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
--
-- 	g = {
-- 		name = "Git",
-- 		g = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
-- 		j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
-- 		k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
-- 		l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
-- 		p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
-- 		r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
-- 		R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
-- 		s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
-- 		S = { "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", "Stage Buffer" },
-- 		u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" },
-- 		o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
-- 		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
-- 		c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
-- 		d = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },
-- 		t = { "<cmd>lua require 'gitsigns'.toggle_current_line_blame()<cr>", "Toggle Line Blame" },
-- 	},
--
-- 	l = {
-- 		name = "LSP",
-- 		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
-- 		d = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Document Diagnostics" },
-- 		w = { "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics" },
-- 		f = { "<cmd>lua vim.lsp.buf.format{async=true}<cr>", "Format" },
-- 		i = { "<cmd>LspInfo<cr>", "Info" },
-- 		I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
-- 		j = { "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", "Next Diagnostic" },
-- 		k = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
-- 		l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
-- 		q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
-- 		r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
-- 		s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
-- 		S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
-- 	},
--
-- 	s = {
-- 		name = "Search",
-- 		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
-- 		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
-- 		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
-- 		M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
-- 		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
-- 		R = { "<cmd>Telescope registers<cr>", "Registers" },
-- 		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
-- 		C = { "<cmd>Telescope commands<cr>", "Commands" },
-- 	},
--
-- 	t = {
-- 		name = "Terminal",
-- 		t = { "<cmd>lua _HTOP_TOGGLE()<cr>", "Htop" },
-- 		f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
-- 		h = { "<cmd>ToggleTerm size=20 direction=horizontal<cr>", "Horizontal" },
-- 		v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
-- 	},
-- }
--
-- which_key.setup(setup)
-- which_key.register(mappings, opts)
