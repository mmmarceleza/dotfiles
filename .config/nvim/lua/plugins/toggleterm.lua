----------------------------------------------------------------------------------------------------
--                                          Toggleterm
----------------------------------------------------------------------------------------------------
-- References:
-- - https://github.com/akinsho/toggleterm.nvim

local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = 30,
	open_mapping = [[<c-\>]],
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
	shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
	persist_size = true,
	persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
	direction = "horizontal",
	close_on_exit = true, -- close the terminal window when the process exits
	-- Change the default shell. Can be a string or a function returning a string
	shell = vim.o.shell,
	auto_scroll = true, -- automatically scroll to the bottom on terminal output
	-- This field is only relevant if direction is set to 'float'
	winbar = {
		enabled = false,
		name_formatter = function(term) --  term: Terminal
			return term.name
		end,
	},
})

function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
--vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
	cmd = "lazygit",
	dir = "git_dir",
	direction = "float",
	float_opts = {
		border = "double",
	},
	-- function to run on opening the terminal
	on_open = function(term)
		vim.cmd("startinsert!")
		vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	end,
	-- function to run on closing the terminal
	on_close = function(term)
		vim.cmd("startinsert!")
	end,
})

function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { noremap = true, silent = true })

local htop = Terminal:new({
	cmd = "htop",
	dir = "git_dir",
	direction = "float",
	float_opts = {
		border = "double",
	},
	-- function to run on opening the terminal
	on_open = function(term)
		vim.cmd("startinsert!")
		vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	end,
	-- function to run on closing the terminal
	on_close = function(term)
		vim.cmd("startinsert!")
	end,
})

function _HTOP_TOGGLE()
	htop:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua _HTOP_TOGGLE()<CR>", { noremap = true, silent = true })
