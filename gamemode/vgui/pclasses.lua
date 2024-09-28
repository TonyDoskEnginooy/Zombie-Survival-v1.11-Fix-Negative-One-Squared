local function SwitchClass(btn)
	RunConsoleCommand("zs_class", btn.Class.Name)
	surface.PlaySound("buttons/button15.wav")
	pClasses:SetVisible(false)
end

local ChooseText = "Choose a class..."
local bossMode = false

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

	local ClassButton = vgui.Create( "DButton", Window )
	ClassButton:SetText( "Classes" )
	ClassButton:SetPos( 25, 0 )
	ClassButton:SetSize( 150, 30 )
	ClassButton.DoClick = function()
		bossMode = false
		RefreshMenu()
	end

	local BossButton = vgui.Create( "DButton", Window )
	BossButton:SetText( "Bosses" )
	BossButton:SetPos( 450, 0 )
	BossButton:SetSize( 150, 30 )
	BossButton.DoClick = function()
		bossMode = true
		RefreshMenu()
	end

	function RefreshMenu()
		pClasses:Remove()
		pClasses = nil
		MakepClasses()
	end

	label = vgui.Create("DLabel", DScrollPanel)

	local y = 50

	function MakeButtons()
		if bossMode then
			ChooseText = "Choose a boss..."
		else
			ChooseText = "Choose a class..."
		end

		surface.SetFont("HUDFontAAFix")
		tw, th = surface.GetTextSize(ChooseText)

		label:SetY(25)
		label:SetSize(tw, th)
		label:SetPos(w * 0.05, 0)

		label:SetFont("HUDFontAAFix")
		label:SetText(ChooseText)
		label:SetTextColor(color_white)

		for i, class in ipairs(ZombieClasses) do
			if not bossMode then 
				if not class.Hidden and not class.Boss then
					local button = vgui.Create("SpawnIcon", DScrollPanel)
					button:SetPos(41, y)
					button:SetSize(w * 0.04, h * 0.07)
					button:SetModel(class.Model)
					button.Class = class
					button.OnMousePressed = SwitchClass

					surface.SetFont("HUDFontSmallAAFix")
					local tw, th = surface.GetTextSize(class.Name)
					local label = vgui.Create("DLabel", DScrollPanel)
					label:SetPos(button:GetWide() + 49, y - 5)
					label:SetSize(tw, th)
					label:SetFont("HUDFontSmallAAFix")
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
						label:SetPos(button:GetWide() + 52, yy - 5)
						label:SetSize(tw, th)
						label:SetFont("Default")
						label:SetText(line)
						label:SetTextColor(COLOR_GRAY)
						yy = yy + th + 1
					end

					y = y + button:GetTall() + 16
				end
			else
				if not class.Hidden and class.Boss then
					local button = vgui.Create("SpawnIcon", DScrollPanel)
					button:SetPos(41, y)
					button:SetSize(w * 0.04, h * 0.07)
					button:SetModel(class.Model)
					button.Class = class
					button.OnMousePressed = SwitchClass

					surface.SetFont("HUDFontSmallAAFix")
					local tw, th = surface.GetTextSize(class.Name)
					local label = vgui.Create("DLabel", DScrollPanel)
					label:SetPos(button:GetWide() + 49, y - 5)
					label:SetSize(tw, th)
					label:SetFont("HUDFontSmallAAFix")
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
						label:SetPos(button:GetWide() + 52, yy - 5)
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
	end

	MakeButtons()

end
