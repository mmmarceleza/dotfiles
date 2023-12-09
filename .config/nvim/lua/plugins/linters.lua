----------------------------------------------------------------------------------------------------
--                                          Linters
----------------------------------------------------------------------------------------------------
-- References:
--   - https://github.com/mfussenegger/nvim-lint

local lint_status_ok, lint = pcall(require, "lint")
if not lint_status_ok then
	return
end

lint.linters_by_ft = {
	dockerfile = { "hadolint" },
	terraform = { "tflint" },
	yaml = { "actionlint" },
	markdown = {
		"markdownlint",
		-- "vale",
	},
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		lint.try_lint()
	end,
})

vim.keymap.set("n", "<leader>l", function()
	lint.try_lint()
end, { desc = "Trigger linting for current file" })
