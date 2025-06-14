vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- disable netrw to use nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- allows neovim to access the system clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.smartindent = true
vim.opt.scrolloff = 8

vim.cmd([[ set noswapfile ]])

--Line numbers
vim.wo.number = true
