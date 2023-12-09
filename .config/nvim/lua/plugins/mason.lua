----------------------------------------------------------------------------------------------------
--                                Package Manager for Neovim
----------------------------------------------------------------------------------------------------
-- References:
--   - https://github.com/williamboman/mason.nvim
--   - https://github.com/williamboman/mason-lspconfig.nvim
--   - https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim

local mason_status_ok, mason = pcall(require, "mason")
if not mason_status_ok then
	return
end

local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status_ok then
	return
end

local mason_tool_installer_status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if not mason_tool_installer_status_ok then
	return
end

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		"lua_ls",
		"bashls",
		"gopls",
		"yamlls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})

mason_tool_installer.setup({
	ensure_installed = {
		"prettier", -- prettier formatter
		"stylua", -- lua formatter
		"actionlint", -- github action linter
		"hadolint", -- dockerfile linter
		"markdownlint", -- markdown linter
		"shellcheck", -- shell script linter
		"tflint", --  terraform linter
		"vale", -- markup-aware linter
		"gofumpt", -- go formatter
		"goimports", -- go formatter
		"golines", -- go formatter
	},
})
