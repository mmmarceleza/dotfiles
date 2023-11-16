-- References: 
--   GitHub: https://github.com/nvim-tree/nvim-tree.lua
--   Defaults: https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree.lua
--   Doc: https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt

require("nvim-tree").setup({
  view = {
    adaptive_size = true,
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- nvim-tree keymaps
local api = require('nvim-tree.api')

local function opts(desc)
  return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
end
vim.keymap.set('n', '<Space>e', '<Cmd>NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
