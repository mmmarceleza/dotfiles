local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Navigate vim panes better
keymap("n", "<c-k>", ":wincmd k<CR>", opts)
keymap("n", "<c-j>", ":wincmd j<CR>", opts)
keymap("n", "<c-h>", ":wincmd h<CR>", opts)
keymap("n", "<c-l>", ":wincmd l<CR>", opts)

-- Disable highlight
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Save the current file with leader key + w
keymap("n", "<leader>w", ":w<CR>", opts)

-- Save and close the current file with leader key + c
keymap("n", "<leader>c", ":w<CR>:bd<CR>", opts)

-- Save all the files and quit the editor with leader key + x
keymap("n", "<leader>x", ":wa<CR>:qa<CR>", opts)

-- Close all without saving and quit the editor with leader key + q
keymap("n", "<leader>q", ":qa<CR>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Insert --
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- ThePrimeagen's tips goodies - https://github.com/ThePrimeagen/init.lua
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
vim.keymap.set("n", "<leader>ra", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
