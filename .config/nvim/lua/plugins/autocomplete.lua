----------------------------------------------------------------------------------------------------
--                                         Autocompletion
----------------------------------------------------------------------------------------------------
-- References:
--   - https://github.com/hrsh7th/nvim-cmp
--   - https://github.com/hrsh7th/cmp-nvim-lsp
--   - https://github.com/hrsh7th/cmp-buffer
--   - https://github.com/hrsh7th/cmp-path
--   - https://github.com/hrsh7th/cmp-cmdline
--   - https://github.com/hrsh7th/cmp-nvim-lua
--   - https://github.com/saadparwaiz1/cmp_luasnip

local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local border_opts = {
	border = "rounded",
	winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
}

local kind_icons = {
	Array = " ",
	Boolean = "󰨙 ",
	Class = " ",
	Codeium = "󰘦 ",
	Color = " ",
	Control = " ",
	Collapsed = " ",
	Constant = "󰏿 ",
	Constructor = " ",
	Copilot = " ",
	Enum = " ",
	EnumMember = " ",
	Event = " ",
	Field = " ",
	File = " ",
	Folder = " ",
	Function = "󰊕 ",
	Interface = " ",
	Key = " ",
	Keyword = " ",
	Method = "󰊕 ",
	Module = " ",
	Namespace = "󰦮 ",
	Null = " ",
	Number = "󰎠 ",
	Object = " ",
	Operator = " ",
	Package = " ",
	Property = " ",
	Reference = " ",
	Snippet = " ",
	String = " ",
	Struct = "󰆼 ",
	TabNine = "󰏚 ",
	Text = " ",
	TypeParameter = " ",
	Unit = " ",
	Value = " ",
	Variable = "󰀫 ",
}

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	formatting = {
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			-- Source
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				buffer = "[Buffer]",
				nvim_lua = "[Lua]",
				path = "[Path]",
				cmdline = "[CmdLine]",
			})[entry.source.name]
			return vim_item
		end,
	},
	window = {
		completion = cmp.config.window.bordered(border_opts),
		documentation = cmp.config.window.bordered(border_opts),
	},
	view = {
		entries = { name = "custom", selection_order = "near_cursor" },
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 1000 },
		{ name = "nvim_lua", priority = 800 },
		{ name = "luasnip", priority = 750 }, -- For luasnip users.
		{ name = "buffer", priority = 500 },
		{ name = "path", priority = 250 },
		-- { name = 'cmdline', priority = 100, max_item_count = 8 },
	}),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
