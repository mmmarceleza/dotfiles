----------------------------------------------------------------------------------------------------
--                                    Language Server Protocol
----------------------------------------------------------------------------------------------------
-- References:
--   - https://neovim.io/doc/user/lsp.html
--   - https://gpanders.com/blog/whats-new-in-neovim-0-11/

------------------------------------
-- Diagnostic signs configuration
------------------------------------
local signs = {
	Hint = " ",
	Info = " ",
	Warn = " ",
	Error = " ",
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

------------------------------------
-- Global LSP configuration
------------------------------------
-- Get enhanced capabilities from cmp-nvim-lsp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
	capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
end

-- Apply global settings to all LSP servers
vim.lsp.config("*", {
	capabilities = capabilities,
	root_markers = { ".git" },
})

------------------------------------
-- Enable LSP servers
------------------------------------
-- Server configs are in ~/.config/nvim/lsp/
vim.lsp.enable({
	"lua_ls",
	"gopls",
	"yamlls",
	"helm_ls",
	"terraformls",
	"bashls",
})

------------------
-- Global mappings
------------------
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[e", vim.diagnostic.open_float)
vim.keymap.set("n", "[q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	float = {
		focusable = false,
		source = "always",
		border = "rounded",
	},
})

-- Useful commands:
-- :checkhealth lsp
-- :lua vim.print(vim.lsp.config.lua_ls)
