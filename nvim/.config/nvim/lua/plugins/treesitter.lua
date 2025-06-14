----------------------------------------------------------------------------------------------------
--                                          Treesitter
----------------------------------------------------------------------------------------------------
-- References:
-- - https://github.com/nvim-treesitter/nvim-treesitter

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = {
		"bash",
		"c",
		"json",
		"lua",
		"python",
		"css",
		"yaml",
		"markdown",
		"markdown_inline",
		"hcl",
		"terraform",
		"dockerfile",
		"go",
	}, -- one of "all" or a list of languages
	auto_install = true,
	ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		additional_vim_regex_highlighting = false,
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = {} },
})
