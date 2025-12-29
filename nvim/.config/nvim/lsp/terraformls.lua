-- Terraform language server
-- https://github.com/hashicorp/terraform-ls
return {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform" },
	root_markers = { ".terraform", ".git" },
}
