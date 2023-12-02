----------------------------------------------------------------------------------------------------
--                                            Indentline
----------------------------------------------------------------------------------------------------
-- References: 
--   GitHub: https://github.com/lukas-reineke/indent-blankline.nvim
--   Doc: https://github.com/lukas-reineke/indent-blankline.nvim/blob/master/doc/indent_blankline.txt

local status_ok, ibl = pcall(require, "ibl")
if not status_ok then
  return
end

ibl.setup({
  indent = {
      char = "▏",
  },
})
