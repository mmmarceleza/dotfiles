local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "folke/tokyonight.nvim", -- https://github.com/folke/tokyonight.nvim
  "nvim-tree/nvim-tree.lua", -- https://github.com/nvim-tree/nvim-tree.lua
  "nvim-tree/nvim-web-devicons", -- https://github.com/nvim-tree/nvim-web-devicons
  {'akinsho/bufferline.nvim', version = "v4.4.0", dependencies = 'nvim-tree/nvim-web-devicons'}, -- https://github.com/akinsho/bufferline.nvim
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} }, -- https://github.com/lukas-reineke/indent-blankline.nvim
  {'nvim-lualine/lualine.nvim', dependencies = 'nvim-tree/nvim-web-devicons'}, -- https://github.com/nvim-lualine/lualine.nvim
  {'nvim-telescope/telescope.nvim', tag = '0.1.4', dependencies = { 'nvim-lua/plenary.nvim' }} -- https://github.com/nvim-telescope/telescope.nvim
    -- BurntSushi/ripgrep is required for live_grep and grep_string and is the first priority for find_files.
    -- arch instalation: pacman -S ripgrep
})
