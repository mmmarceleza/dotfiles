----------------------------------------------------------------------------------------------------
--                                    Language Server Protocol
----------------------------------------------------------------------------------------------------
-- References:
--   - https://microsoft.github.io/language-server-protocol/
--   - https://github.com/neovim/nvim-lspconfig
--   - https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

local signs = {
	Hint = " ",
	Info = " ",
	Warn = " ",
	Error = " ",
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

----------------------
-- Lua language server
----------------------
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- https://luals.github.io/
-- https://luals.github.io/#neovim-install
-- pacman -S lua-language-server
require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" }, -- ignore vim as global variable
			},
		},
	},
})

---------------------------------
-- Google's lsp server for golang
---------------------------------
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- https://github.com/golang/tools/tree/master/gopls
-- pacman -S gopls
require("lspconfig").gopls.setup({})

---------------------------------
-- Language Server for YAML Files
---------------------------------
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
-- https://github.com/redhat-developer/yaml-language-server
-- pacman -S yaml-language-server
require("lspconfig").yamlls.setup({
	settings = {
		yaml = {
			schemas = {
				kubernetes = {
					"*namespace*.yaml",
					"*pod*.yaml",
					"*deploy*.yaml",
					"*daemonset*.yaml",
					"*statefulset*.yaml",
					"*service*.yaml",
					"*ingress*.yaml",
					"*configmap*.yaml",
					"*secret*.yaml",
					"*hpa*.yaml",
					"*pv*.yaml",
					"*cronjob*.yaml",
				},
				--["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
				--["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
				--["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
				--["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
				--["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
				--["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
				--["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
				--["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
				--["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
				--["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
				["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
				["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj/application_v1alpha1.json"] = "*application*.{yml,yaml}",
				["https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrelease-helm-v2beta1.json"] = "*helmrelease*.{yml,yaml}",
				["https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrepository-source-v1beta1.json"] = "*helmrepository*.{yml.yaml}",
			},
		},
	},
})

----------------------------
-- Terraform Language Server
----------------------------
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#terraformls
-- https://github.com/hashicorp/terraform-ls
-- paru -S terraform-ls-bin (AUR)
require("lspconfig").terraformls.setup({
	filetypes = {
		"terraform", --[[ "terraform-vars" ]]
	}, -- test terraform-vars in the future (https://github.com/hashicorp/terraform-ls/issues/1464)
})

-----------------------
-- Bash Language Server
-----------------------
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls
-- https://github.com/koalaman/shellcheck (dependency)
-- pacman -S bash-language-server shellcheck
require("lspconfig").bashls.setup({})

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
		source = "always", -- Or "if_many"
		border = "rounded",
	},
})
-- Some usefull commands
-- :LspInfo
