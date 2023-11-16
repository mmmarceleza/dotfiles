require("tokyonight").setup({
  style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
})

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd[[colorscheme tokyonight]]
