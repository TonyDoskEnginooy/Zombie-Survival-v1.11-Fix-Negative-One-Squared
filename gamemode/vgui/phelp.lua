function MakepHelp()
	if pHelp then
		pHelp:SetVisible(true)
		pHelp:MakePopup()
		return
	end

	local Window = vgui.Create("DFrame")
	local tall = h * 0.95 -- Limit the height -- Xala
	Window:SetSize(640, tall)
	local wide = (w - 640) * 0.5
	local tall = (h - tall) * 0.5
	Window:SetPos(wide, tall)
	Window:SetTitle(" ")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetCursor("pointer")
	Window:SetScreenLock(true)
	pHelp = Window

	local DScrollPanel = vgui.Create( "DScrollPanel", Window )
	DScrollPanel:Dock( FILL )

	local labelY = 1

	local label = vgui.Create("DLabel", DScrollPanel)
	label:SetTextColor(COLOR_RED)
	label:SetFont("noxnetnormal")
	label:SetText("F1: Help")
	label:SetPos(16, labelY)
	surface.SetFont("noxnetnormal")
	local texw, texh = surface.GetTextSize("F1: Help")
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", DScrollPanel)
	label:SetTextColor(COLOR_RED)
	label:SetFont("noxnetnormal")
	label:SetText("F2: Manual Redeem")
	surface.SetFont("noxnetnormal")
	local texw, texh = surface.GetTextSize("F2: Manual Redeem")
	label:SetPos(190 - texw * 0.5, labelY)
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", DScrollPanel)
	label:SetTextColor(COLOR_RED)
	label:SetFont("noxnetnormal")
	label:SetText("F3: Change Zombie Class")
	surface.SetFont("noxnetnormal")
	local texw, texh = surface.GetTextSize("F3: Change Zombie Class")
	label:SetPos(400 - texw * 0.5, labelY)
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", DScrollPanel)
	label:SetTextColor(COLOR_RED)
	label:SetFont("noxnetnormal")
	label:SetText("F4: Options")
	surface.SetFont("noxnetnormal")
	local texw, texh = surface.GetTextSize("F4: Options")
	label:SetPos(640 - texw - 16, labelY)
	label:SetSize(texw, texh)

	surface.SetFont("Default")
	local ___, defh = surface.GetTextSize("|")

	local touse = HELP_TEXT
	if SURVIVALMODE then
		touse = HELP_TEXT_SURVIVALMODE
	end
	local y = 24
	for i, text in ipairs(touse) do
		if string.len(text) <= 1 then
			y = y + defh
		else
			local label = vgui.Create("DLabel", DScrollPanel)
			local pretext = string.sub(text, 1, 2)
			if pretext == "^r" then
				label:SetTextColor(COLOR_READABLERED)
				text = string.sub(text, 3)
			elseif pretext == "^g" then
				label:SetTextColor(COLOR_LIMEGREEN)
				text = string.sub(text, 3)
			elseif pretext == "^y" then
				label:SetTextColor(COLOR_YELLOW)
				text = string.sub(text, 3)
			elseif pretext == "^b" then
				label:SetTextColor(COLOR_CYAN)
				text = string.sub(text, 3)
			else
				label:SetTextColor(color_white)
			end
			if i == 1 then
				label:SetFont("HUDFontSmallAA")
			else
				label:SetFont("DefaultSmall")
			end
			label:SetText(text)
			label:SetPos(16, y)
			label:SetSize(640, 64)
			y = y + defh
		end
	end

	local button = vgui.Create("DButton", Window)
	button:SetPos(240, Window:GetTall() - 64)
	button:SetSize(160, 32)
	button:SetText("Close")
	button.DoClick = function(btn) btn:GetParent():SetVisible(false) end
end
