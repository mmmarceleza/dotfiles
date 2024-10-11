----------------------------------------------------------------------------------------------------
--                                            Mini.Icons
----------------------------------------------------------------------------------------------------
-- References:
--   GitHub: https://github.com/echasnovski/mini.icons
--   Doc: https://github.com/echasnovski/mini.icons/blob/main/doc/mini-icons.txt

local status_ok, mini = pcall(require, "mini")
if not status_ok then
	return
end

mini.setup()
