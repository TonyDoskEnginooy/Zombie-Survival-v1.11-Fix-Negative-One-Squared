local function SwitchClass(btn)
	RunConsoleCommand("zs_class", btn.Class.Name)
	surface.PlaySound("buttons/button15.wav")
	pClasses:SetVisible(false)
end

function MakepClasses()
	if pClasses then
		pClasses:Remove()
		pClasses = nil
	end
	local h = ScrH()
	local w = ScrW()

	local Window = vgui.Create("DFrame")
	local wide = w * 0.25
	local tall = h * 0.95

	Window:SetSize(wide, tall)
	Window:CenterVertical()
	Window:CenterHorizontal()
	Window:SetPos(w * 0.375, h * 0.025)
	Window:SetTitle(" ")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetScreenLock(true)
	Window:SetCursor("pointer")
	pClasses = Window

	local DScrollPanel = vgui.Create( "DScrollPanel", Window )
	DScrollPanel:Dock( FILL )

	surface.SetFont("HUDFontAA")
	local tw, th = surface.GetTextSize("Choose a class...")
	local label = vgui.Create("DLabel", DScrollPanel)
	label:SetY(25)
	label:SetSize(tw, th)
	label:SetPos(w * 0.08, h * 0.01)

	label:SetFont("HUDFontAA")
	label:SetText("Choose a class...")
	label:SetTextColor(color_white)

	local y = 95

	print(w)
	print(h)

	for i, class in ipairs(ZombieClasses) do
		if not class.Hidden then
			local button = vgui.Create("SpawnIcon", DScrollPanel)
			button:SetPos(41, y)
			button:SetSize(w * 0.04, h * 0.07)
			button:SetModel(class.Model)
			button.Class = class
			button.OnMousePressed = SwitchClass

			surface.SetFont("HUDFontSmallAA")
			local tw, th = surface.GetTextSize(class.Name)
			local label = vgui.Create("DLabel", DScrollPanel)
			label:SetPos(button:GetWide() + 49, y - 30)
			label:SetSize(tw, th)
			label:SetFont("HUDFontSmallAA")
			label:SetText(class.Name)
			if class.Threshold <= INFLICTION then
				label:SetTextColor(COLOR_LIMEGREEN)
			else
				label:SetTextColor(COLOR_RED)
			end

			local yy = y + 2 + th
			for i, line in ipairs(string.Explode("@", class.Description)) do
				surface.SetFont("Default")
				local tw, th = surface.GetTextSize(line)
				local label = vgui.Create("DLabel", DScrollPanel)
				label:SetPos(button:GetWide() + 52, yy - 30)
				label:SetSize(tw, th)
				label:SetFont("Default")
				label:SetText(line)
				label:SetTextColor(COLOR_GRAY)
				yy = yy + th + 1
			end

			y = y + button:GetTall() + 16
		end
	end
end
