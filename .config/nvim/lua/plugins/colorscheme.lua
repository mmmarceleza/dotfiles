----------------------------------------------------------------------------------------------------
--                                          Colorscheme
----------------------------------------------------------------------------------------------------
-- References:
-- - https://github.com/folke/tokyonight.nvim

local colorscheme = "tokyonight"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	return
end

require("tokyonight").setup({
	style = "moon", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
})

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd([[colorscheme tokyonight]])
