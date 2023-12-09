local ls = require("luasnip") --{{{

require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
require("luasnip").config.setup({ store_selection_keys = "<A-p>" })

-- Virtual Text{{{
local types = require("luasnip.util.types")
ls.config.set_config({
	history = true, --keep around last snippet local to jump back
	updateevents = "TextChanged,TextChangedI", --update changes as you type
	enable_autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "●", "GruvboxOrange" } },
			},
		},
		-- [types.insertNode] = {
		-- 	active = {
		-- 		virt_text = { { "●", "GruvboxBlue" } },
		-- 	},
		-- },
	},
}) --}}}

-- Key Mapping

vim.keymap.set({ "i" }, "<C-K>", function()
	ls.expand()
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-L>", function()
	ls.jump(1)
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function()
	ls.jump(-1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, { silent = true })
