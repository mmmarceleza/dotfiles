local wezterm = require("wezterm")

wezterm.on("update-right-status", function(window, pane)
	-- Cada célula contém o texto para um estilo "powerline" << fade
	local cells = {}

	-- Obter o workspace atual
	local workspace = window:active_workspace()
	table.insert(cells, "Workspace: " .. workspace)

	-- Formatar a data no estilo "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M")
	table.insert(cells, date)

	-- Símbolos de powerline
	local LEFT_ARROW = utf8.char(0xe0b3)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Paleta de cores para o fundo de cada célula
	local colors = {
		"#3c1361", -- Cor 1
		"#52307c", -- Cor 2
	}

	-- Cor de texto para as células
	local text_fg = "#c0c0c0"

	-- Elementos a serem formatados
	local elements = {}
	-- Contagem de células formatadas
	local num_cells = 0

	-- Função para adicionar elementos ao status
	local function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
	end

	-- Preencher as células com os valores atuais (Workspace e Data)
	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	-- Definir o status direito com os elementos formatados
	window:set_right_status(wezterm.format(elements))
end)

wezterm.on("update-right-status", function(window, _)
	local SOLID_LEFT_ARROW = ""
	local ARROW_FOREGROUND = { Foreground = { Color = "#2aa198" } }
	local prefix = ""

	if window:leader_is_active() then
		-- prefix = " " .. utf8.char(0x1f30a) -- ocean wave
		prefix = " " .. utf8.char(0x1F4A1) -- light bulb
		SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	end

	if window:active_tab():tab_id() == 1 then
		ARROW_FOREGROUND = { Foreground = { Color = "#333333" } }
	end -- arrow color based on if tab is first pane

	window:set_left_status(wezterm.format({
		{ Background = { Color = "#212121" } },
		{ Text = prefix },
		ARROW_FOREGROUND,
		{ Text = SOLID_LEFT_ARROW },
	}))
end)

return {}
