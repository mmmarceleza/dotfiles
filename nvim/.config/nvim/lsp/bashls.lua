-- Bash language server
-- https://github.com/bash-lsp/bash-language-server
return {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = { ".git" },
}
