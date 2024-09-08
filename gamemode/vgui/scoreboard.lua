local texGradient = surface.GetTextureID("gui/center_gradient")

local function SortFunc(a, b)
	return a:Frags() > b:Frags()
end

local colBackground = Color(40, 50, 40, 255)

local PANEL = {}

function PANEL:Init()
	SCOREBOARD = self
	self.Elements = {}
end

local function TruncateText(text, maxLength)
    if string.len(text) > maxLength then
        return string.sub(text, 1, maxLength - 3) .. "..."
    else
        return text
    end
end

function PANEL:Paint()
	local tall, wide = self:GetTall(), self:GetWide()
	local posx, posy = self:GetPos()

	draw.RoundedBox(16, 0, 0, wide, tall, colBackground)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(wide * 0.05, tall * 0.150087719298, wide * 0.4, tall * 0.651070175438)
	surface.DrawRect(wide * 0.55, tall * 0.150087719298, wide * 0.4, tall * 0.651070175438)

	surface.SetDrawColor(0, 50, 255, 255)
	surface.DrawOutlinedRect(wide * 0.05, tall * 0.150087719298, wide * 0.4, tall * 0.651070175438)

	surface.SetDrawColor(0, 255, 0, 255)
	surface.DrawOutlinedRect(wide * 0.55, tall * 0.150087719298, wide * 0.4, tall * 0.651070175438)

	draw.DrawText("Zombie Survival", "HUDFontBigFix", wide * 0.5, h * -0.015, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
	surface.SetFont("HUDFontBigFix")
	local gmw, gmh = surface.GetTextSize("Zombie Survival")
	draw.DrawText("("..GAMEMODE.Version.." "..GAMEMODE.SubVersion..")", "DefaultSmall", gmw * 0.65, gmh * 0.75, COLOR_GRAY, TEXT_ALIGN_LEFT)
	draw.DrawText(--[[TruncateText(GetGlobalString("servername"), 36)]]"poopy butt", "HUDFont2", wide * 0.5, gmh * 0.75, COLOR_GRAY, TEXT_ALIGN_CENTER)

	local colHuman = team.GetColor(TEAM_HUMAN)
	local colUndead = team.GetColor(TEAM_UNDEAD)

	local HumanPlayers = team.GetPlayers(TEAM_HUMAN)
	local UndeadPlayers = team.GetPlayers(TEAM_UNDEAD)

	table.sort(HumanPlayers, SortFunc)
	table.sort(UndeadPlayers, SortFunc)

	local y = tall * 0.15380116959
	local x = wide * 0.55

	draw.DrawText("Survivor", "Default", wide * 0.053125, tall * 0.13210526315, color_white, TEXT_ALIGN_LEFT)
	draw.DrawText("Kills", "Default", wide * 0.3, tall * 0.13210526315, color_white, TEXT_ALIGN_RIGHT)
	draw.DrawText("Ping", "Default", wide * 0.44375, tall * 0.13210526315, color_white, TEXT_ALIGN_RIGHT)

	draw.DrawText("Zombie", "Default", x + (wide * 0.003125), tall * 0.13210526315, color_white, TEXT_ALIGN_LEFT)
	draw.DrawText("Brains Eaten", "Default", x + (wide * 0.3), tall * 0.13210526315, color_white, TEXT_ALIGN_RIGHT)
	draw.DrawText("Ping", "Default", x + (wide * 0.396875), tall * 0.13210526315, color_white, TEXT_ALIGN_RIGHT)

	surface.SetFont("Default")
	local width, height = surface.GetTextSize("Q")

	for i, ply in ipairs(HumanPlayers) do
		if y >= tall - 285 then
			draw.DrawText("...", "Default", wide * 0.053125, y, colHuman, TEXT_ALIGN_LEFT)
			break
		else
			draw.DrawText(ply:Name(), "Default", wide * 0.053125, y, colHuman, TEXT_ALIGN_LEFT)
			draw.DrawText(ply:Frags(), "Default", wide * 0.3, y, colHuman, TEXT_ALIGN_CENTER)
			draw.DrawText(ply:Ping(), "Default", wide * 0.446875, y, colHuman, TEXT_ALIGN_RIGHT)
			y = y + height
		end
	end

	y = tall * 0.15380116959

	for i, ply in ipairs(UndeadPlayers) do
		if y >= tall - 285 then
			draw.DrawText("...", "Default", x + (wide * 0.003125), y, colUndead, TEXT_ALIGN_LEFT)
			break
		else
			draw.DrawText(ply:Name(), "Default", x + (wide * 0.003125), y, colUndead, TEXT_ALIGN_LEFT)
			draw.DrawText(ply:Frags(), "Default", x + (wide * 0.3), y, colUndead, TEXT_ALIGN_CENTER)
			draw.DrawText(ply:Ping(), "Default", x + (wide * 0.396875), y, colUndead, TEXT_ALIGN_RIGHT)
			y = y + height
		end
	end

	local y = tall * 0.825
	draw.DrawText("F1:  Help", "HUDFontSmallAAFix", wide * 0.04375, y * 0.975, COLOR_RED, TEXT_ALIGN_LEFT)
	local tw, th = surface.GetTextSize("F1:  Help")
	y = y + th + 5
	draw.DrawText("F2: Manual redeem", "HUDFontSmallAAFix", wide * 0.05, y * 0.975, COLOR_GRAY, TEXT_ALIGN_LEFT)
	y = y + th + 5
	draw.DrawText("F3: Change Zombie class", "HUDFontSmallAAFix", wide * 0.05, y * 0.975, COLOR_GRAY, TEXT_ALIGN_LEFT)
	y = y + th + 5
	draw.DrawText("F4: Options", "HUDFontSmallAAFix", wide * 0.05, y * 0.975, COLOR_GRAY, TEXT_ALIGN_LEFT)

	return true
end

function PANEL:PerformLayout()
	self:SetSize(640, h * 0.95)

	self:SetPos((w - self:GetWide()) * 0.5, (h - self:GetTall()) * 0.5)
end
vgui.Register("ScoreBoard", PANEL, "Panel")
