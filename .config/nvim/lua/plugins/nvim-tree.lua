----------------------------------------------------------------------------------------------------
--                                            Nvim-tree
----------------------------------------------------------------------------------------------------
-- References: 
--   GitHub: https://github.com/nvim-tree/nvim-tree.lua
--   Defaults: https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree.lua
--   Doc: https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local function edit_or_open()
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
      -- expand or collapse folder
      api.node.open.edit()
    else
      -- open file
      api.node.open.edit()
      -- Close the tree if file was opened
      -- api.tree.close()
    end
  end

  -- open as vsplit on current node
  local function vsplit_preview()
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
      -- expand or collapse folder
      api.node.open.edit()
    else
      -- open file as vsplit
      api.node.open.vertical()
    end

    -- Finally refocus on tree if it was lost
    api.tree.focus()
  end

  -- global
  vim.api.nvim_set_keymap("n", "<C-e>", ":NvimTreeToggle<cr>", {silent = true, noremap = true})

  -- on_attach
  vim.keymap.set("n", "l", edit_or_open,                   opts("Edit Or Open"))
  vim.keymap.set("n", "L", vsplit_preview,                 opts("Vsplit Preview"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
  vim.keymap.set("n", "H", api.tree.collapse_all,          opts("Collapse All"))

end

nvim_tree.setup({
  on_attach = on_attach,
  view = {
    adaptive_size = true,
    width = 30,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  renderer = {
    root_folder_modifier = ":t",
    icons = {
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          untracked = "U",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
  filters = {
    dotfiles = true,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
})
