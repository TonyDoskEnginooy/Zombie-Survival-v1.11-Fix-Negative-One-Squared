hook.Add("Think", "GetLocal", function()
	if LocalPlayer():IsValid() then
		RunConsoleCommand("PostPlayerInitialSpawn")
		hook.Remove("Think", "GetLocal")
	end
end)

include("shared.lua")
include("cl_scoreboard.lua")
include("cl_targetid.lua")
include("cl_hudpickup.lua")
include("cl_spawnmenu.lua")
include("cl_postprocess.lua")
include("cl_deathnotice.lua")
include("cl_beats.lua")
include("cl_splitmessage.lua")
include("vgui/poptions.lua")
include("vgui/phelp.lua")
include("vgui/pclasses.lua")
include("cl_dermaskin.lua")
include("zs_options.lua")

color_transparent = Color(255, 255, 255, 0)
color_white = Color(255, 255, 255, 220)
color_black = Color(50, 50, 50, 255)
color_black_alpha180 = Color(0, 0, 0, 180)
color_black_alpha90 = Color(0, 0, 0, 90)
color_white_alpha200 = Color(255, 255, 255, 200)
color_white_alpha180 = Color(255, 255, 255, 180)
color_white_alpha90 = Color(255, 255, 255, 90)
COLOR_INFLICTION = Color(235, 185, 0, 165)
COLOR_DARKBLUE = Color(5, 75, 150, 255)
COLOR_DARKGREEN = Color(0, 150, 0, 255)
COLOR_DARKRED = Color(185, 0, 0, 255)
COLOR_DARKRED_HUD = Color(185, 0, 0, 180)
COLOR_DARKCYAN = Color(0, 155, 155, 255)
COLOR_DARKCYAN_HUD = Color(0, 155, 155, 180)
COLOR_GRAY = Color(190, 190, 190, 255)
COLOR_GRAY_HUD = Color(190, 190, 190, 180)
COLOR_READABLERED = Color(255, 133, 133)
COLOR_RED = Color(255, 0, 0)
COLOR_BLUE = Color(0, 0, 255)
COLOR_GREEN = Color(0, 255, 0)
COLOR_LIMEGREEN = Color(50, 255, 50)
COLOR_YELLOW = Color(255, 255, 0)
COLOR_PURPLE = Color(255, 0, 255)
COLOR_CYAN = Color(0, 255, 255)
COLOR_WHITE = Color(255, 255, 255)
COLOR_BLACK = Color(0, 0, 0)

ENDTIME = 0

NearZombies = 0
ActualNearZombies = 0

local cvar_zs_roundtime = GetConVar("zs_roundtime")
local cvar_zs_intermission_time = GetConVar("zs_intermission_time")
local LASTHUMANSOUNDLENGTH = SoundDuration(LASTHUMANSOUND)
local UNLIFESOUNDLENGTH = SoundDuration(UNLIFESOUND)
local HALFLIFESOUNDLENGTH = SoundDuration(HALFLIFESOUND)

local Top = {}
local TopZ = {}
local TopZD = {}
local TopHD = {}

w, h = ScrW(), ScrH()

local matHumanHeadID = surface.GetTextureID("humanhead")
local matZomboHeadID = surface.GetTextureID("zombohead")

function GetZombieFocus2(mypos, range, multiplier, maxper)
	local zombies = 0

	for _, curPly in ipairs(player.GetAll()) do
		if curPly ~= LocalPlayer() and curPly:Team() == TEAM_UNDEAD and curPly:Alive() then
			local dist = curPly:GetPos():Distance(mypos)
			if dist < range then
				zombies = zombies + math.max((range - dist) * multiplier, maxper)
			end
		end
	end

	return math.min(zombies, 1)
end

function GM:Initialize()
	self.ShowScoreboard = false

	surface.CreateFont("ScoreboardHead", { 
		font = "Coolvetica",
		size = 48,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("ScoreboardSub", { 
		font = "Coolvetica",
		size = 24,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("ScoreboardText", { 
		font = "Tahoma",
		size = 16,
		weight = 1000,
		shadow = true
	})
	surface.CreateFont("Signs", { 
		font = "csd",
		size = 42,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("HUDFontTiny", { 
		font = "typenoksidi",
		size = 16,
		weight = 250,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontSmall", { 
		font = "typenoksidi",
		size = 28,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontSmallFix", { 
		font = "typenoksidi",
		size = ScrW() * 0.02,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFont", { 
		font = "typenoksidi",
		size = 42,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontFix", { 
		font = "typenoksidi",
		size = ScrW() * 0.03,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontBig", { 
		font = "typenoksidi",
		size = 72,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontBigFix", { 
		font = "akbar",
		size = ScrW() * 0.05,
		weight = 400,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("HUDFontTinyAA", { 
		font = "typenoksidi",
		size = 16,
		weight = 250,
		shadow = true
	})
	surface.CreateFont("HUDFontTinyAAFix", { 
		font = "typenoksidi",
		size = ScrW() * 0.015,
		weight = 250,
		shadow = true
	})
	surface.CreateFont("HUDFontSmallAA", { 
		font = "typenoksidi",
		size = 28,
		weight = 400,
		shadow = true
	})
	surface.CreateFont("HUDFontAA", { 
		font = "typenoksidi",
		size = 42,
		weight = 400,
		shadow = true
	})
	surface.CreateFont("HUDFontSmallAAFix", { 
		font = "typenoksidi",
		size = ScrW() * 0.02,
		weight = 400,
		shadow = true
	})
	surface.CreateFont("HUDFontAAFix", { 
		font = "typenoksidi",
		size = ScrW() * 0.03,
		weight = 400,
		shadow = true
	})
	surface.CreateFont("HUDFontBigAA", { 
		font = "typenoksidi",
		size = 72,
		weight = 400,
		shadow = true
	})
	surface.CreateFont("HUDFontTiny2", { 
		font = "AkbarPlain",
		size = 16,
		weight = 250,
		shadow = true
	})
	surface.CreateFont("HUDFontSmall2", { 
		font = "AkbarPlain",
		size = 28,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("HUDFont2", { 
		font = "AkbarPlain",
		size = 42,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("HUDFontBig2", { 
		font = "AkbarPlain",
		size = 72,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("noxnetbig", { 
		font = "Frosty",
		size = 32,
		weight = 200,
		antialias = false,
		shadow = true
	})
	surface.CreateFont("noxnetnormal", { 
		font = "AkbarPlain",
		size = 22,
		weight = 500,
		shadow = true
	})
	surface.CreateFont("DefaultBold", { 
		font = "typenoksidi",
		size = 20,
		weight = 400,
		shadow = true
	})

	if FORCE_NORMAL_GAMMA then
		RunConsoleCommand("mat_monitorgamma", "2.2")
		timer.Create("GammaChecker", 3, 0, function()
			RunConsoleCommand("mat_monitorgamma", "2.2")
		end)
	end
end

function GM:PlayerDeath(ply, attacker)
end

local function LoopLastHuman()
	if not ENDROUND then
		surface.PlaySound(LASTHUMANSOUND)
		timer.Simple(LASTHUMANSOUNDLENGTH, LoopLastHuman)
	end
end

function GM:LastHuman()
	if LASTHUMAN then return end

	LASTHUMAN = true
	RunConsoleCommand("stopsound")
	timer.Simple(0.5, LoopLastHuman)
	DrawingDanger = 1
	--timer.Simple(0.5, DelayedLH)
	GAMEMODE:SetLastHumanText()
	hook.Add("HUDPaint", "DrawLastHuman", DrawLastHuman)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker.Alive then
		return ply:Team() ~= attacker:Team() or ply == attacker
	end
	return true
end

function GM:HUDShouldDraw(name)
	return name ~= "CHudHealth" and name ~= "CHudBattery" and name ~= "CHudSecondaryAmmo" and name ~= "CHUDQuickInfo"
end

local function ReceiveTopTimes(index, toptimes)
	Top[index] = toptimes
	if Top[index] == "Downloading" or Top[index] == "[STRING NOT POOLED]" then
		Top[index] = nil
	else
		Top[index] = index..". "..Top[index]
	end
end
net.Receive("RcTopTimes", function() ReceiveTopTimes(net.ReadInt(16), net.ReadString()) end)

local function ReceiveTopZombies(index, topzombies)
	TopZ[index] = topzombies
	if TopZ[index] == "Downloading" or TopZ[index] == "[STRING NOT POOLED]" then
		TopZ[index] = nil
	else
		TopZ[index] = index..". "..TopZ[index]
	end
end
net.Receive("RcTopZombies", function() ReceiveTopZombies(net.ReadInt(16), net.ReadString()) end)

local function ReceiveTopHumanDamages(index, tophumandamage)
	TopHD[index] = tophumandamage
	if TopHD[index] == "Downloading" or TopHD[index] == "[STRING NOT POOLED]" then
		TopHD[index] = nil
	else
		TopHD[index] = index..". "..TopHD[index]
	end
end
net.Receive("RcTopHumanDamages", function() ReceiveTopHumanDamages(net.ReadInt(16), net.ReadString()) end)

local function ReceiveTopZombieDamages(index, topzombiedamage)
	TopZD[index] = topzombiedamage
	if TopZD[index] == "Downloading" or TopZD[index] == "[STRING NOT POOLED]" then
		TopZD[index] = nil
	else
		TopZD[index] = index..". "..TopZD[index]
	end
end
net.Receive("RcTopZombieDamages", function() ReceiveTopZombieDamages(net.ReadInt(16), net.ReadString()) end)

local function ReceiveHeadcrabScale(somePly)
	if somePly:IsValid() then
		--somePly:SetModelScale(Vector(2,2,2))
		if somePly == LocalPlayer() then
			HCView = true
			hook.Add("Think", "HCView", function()
				if somePly:Health() <= 0 then
					HCView = false
					hook.Remove("Think", "HCView")
				end
			end)
		end
	end
end
net.Receive("RcHCScale", function() ReceiveHeadcrabScale(net.ReadEntity()) end)

function GM:HUDPaintBackground()
end

local matHealthBar = surface.GetTextureID("zombiesurvival/healthbar_fill")
local matUIBottomLeft = surface.GetTextureID("zombiesurvival/zs_ui_bottomleft")
function GM:HUDPaint()
	local ply = LocalPlayer()

	if not ply:IsValid() then return end

	if not cvar_zs_roundtime then
		cvar_zs_roundtime = GetConVar("zs_roundtime")
	end

	if not cvar_zs_intermission_time then
		cvar_zs_intermission_time = GetConVar("zs_intermission_time")
	end

	-- Width, height
	h = ScrH()
	w = ScrW()

	surface.SetDrawColor(255, 255, 255, 180)
	surface.SetTexture(matUIBottomLeft)
	surface.DrawTexturedRect(0, h * 0.915, w * 0.2, h * 0.09)

	local myteam = ply:Team()

	-- TargetID
	self:HUDDrawTargetID(ply, myteam)

	-- Team Count
	local zombies = 0
	local humans = 0
	for _, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_ZOMBIE then
			zombies = zombies + 1
		else
			humans = humans + 1
		end
	end

	local hunit = h*0.11
	local windowwidth = hunit*3.1

	draw.RoundedBox(16, 0, 0, windowwidth, hunit, color_black_alpha180)
	local w05 = hunit/2.2
	local h05 = w05
	surface.SetDrawColor(235, 235, 235, 255)
	surface.SetTexture(matZomboHeadID)
	surface.DrawTexturedRect(0, 4, w05, h05)
	surface.SetTexture(matHumanHeadID)
	surface.DrawTexturedRect(0, h05 + 4, w05, h05)
	draw.DrawText(zombies, "HUDFontAAFix", w05, 0, COLOR_DARKGREEN, TEXT_ALIGN_LEFT)
	draw.DrawText(zombies, "HUDFontAAFix", w05, 0, COLOR_DARKGREEN, TEXT_ALIGN_LEFT)
	draw.DrawText(humans, "HUDFontAAFix", w05, h05, COLOR_DARKBLUE, TEXT_ALIGN_LEFT)
	draw.DrawText(humans, "HUDFontAAFix", w05, h05, COLOR_DARKBLUE, TEXT_ALIGN_LEFT)

	-- Death Notice
	self:DrawDeathNotice(0.8, 0.04)

	local actionposx = w05 * 2.4
	local actionposy = hunit/2 - draw.GetFontHeight("HUDFontSmallAAFix")
	local killedposx = actionposx
	local killedposy = hunit/2 

	if myteam == TEAM_UNDEAD then
		if self.ZombieHUD then
			self:ZombieHUD(ply, actionposx, actionposy, killedposx, killedposy)
		end
	else
		if self.HumanHUD then
			self:HumanHUD(ply, killedposx, killedposy)
		end
		
		draw.DrawText("Survive: "..ToMinutesSeconds(cvar_zs_roundtime:GetInt() - CurTime()), "HUDFontSmallAAFix", actionposx, actionposy, COLOR_CYAN, TEXT_ALIGN_LEFT)
	end

	-- Infliction
	draw.DrawText("Infliction: " .. math.floor(INFLICTION * 100) .. "%", "HUDFontSmallAAFix", 8, h * 0.85, COLOR_INFLICTION, TEXT_ALIGN_LEFT)
end

util.PrecacheSound("npc/stalker/breathing3.wav")
util.PrecacheSound("npc/zombie/zombie_pain6.wav")
function GM:PlayerButtonDown(ply, button)
	if button == KEY_F and ply:Team() == TEAM_UNDEAD then
		if DLV then
			ply:EmitSound("npc/zombie/zombie_pain6.wav", 100, 110)
			DoZomC()
		else
			ply:EmitSound("npc/stalker/breathing3.wav", 100, 230)
			DLVC()
		end
	end
end

function GM:CalcView(ply, pos, ang, _fov)
	local ply = LocalPlayer()

	if not ply:IsValid() then return end

	local ragdoll = ply:GetRagdollEntity()

	if IsValid(ragdoll) then
		local lookup = ragdoll:LookupAttachment("eyes")
		if lookup > 0 then
			local attach = ragdoll:GetAttachment(lookup)
			if attach then
				return {origin=attach.Pos + attach.Ang:Forward(), angles=attach.Ang}
			end
		end
	end

	if (ply:Health() <= 30 and ply:Team() == TEAM_HUMAN) or ply:WaterLevel() > 2 then
		ang.roll = ang.roll + math.sin(RealTime()) * 7
	end

	if HCView then
		if not ply:KeyDown(IN_DUCK) then
			pos = pos - Vector(0, 0, 30)
		end
	end

	return {origin = pos, angles = ang, fov = _fov}
end

function GM:CreateMove(cmd)
end

function GM:ShutDown()
end

function GM:GetTeamColor(ent)
	if ent and ent:IsValid() and ent:IsPlayer() then
		local teamnum = ent:Team() or TEAM_UNASSIGNED
		return team.GetColor(teamnum) or color_white
	end
	return color_white
end

function GM:GetTeamNumColor(num)
	return team.GetColor(num) or color_white
end

function GM:OnChatTab(str)
	local LastWord
	for word in string.gmatch(str, "%a+") do
	     LastWord = word
	end

	if LastWord == nil then return str end

	for k, v in ipairs(player.GetAll()) do
		local nickname = v:Nick()
		if string.len(LastWord) < string.len(nickname) and string.find(string.lower(nickname), string.lower(LastWord)) == 1 then
			str = string.sub(str, 1, (string.len(LastWord) * -1)-1)
			str = str .. nickname
			return str
		end
	end
	return str
end

function GM:GetSWEPMenu()
	return {}
end

function GM:GetSENTMenu()
	return {}
end

function GM:PostProcessPermitted(str)
	return false
end

function GM:PostRenderVGUI()
end

function GM:RenderScene()
end

function Intermission(nextmap, winner)
	ENDROUND = true
	hook.Remove("RenderScreenspaceEffects", "PostProcess")
	ENDTIME = CurTime()
	DrawingDanger = 0
	NearZombies = 0
	NextThump = 999999
	RunConsoleCommand("stopsound")
	LastLineY = h*0.4
	DoHumC()
	function GAMEMODE:HUDPaint()
		self:DrawDeathNotice(0.8, 0.04)
		draw.RoundedBox(16, 0, h*0.14, w, h*0.62, color_black)
		if math.Clamp(LastLineY, h*0.14, h*0.76) == LastLineY then
			surface.DrawLine(0, LastLineY, w, LastLineY)
		end
		LastLineY = LastLineY + h*0.1 * FrameTime()
		if LastLineY > h then
			LastLineY = h*0.14
		end
		if #Top > 0 then
			draw.DrawText("Survival Times", "HUDFontFix", w*0.1, h*0.15, COLOR_CYAN, TEXT_ALIGN_LEFT)
			for i=1, 5 do
				if Top[i] and CurTime() > ENDTIME + i * 0.7 then
					draw.DrawText(Top[i], "HUDFontSmallFix", w*0.13, h*0.15 + h*0.05*i, Color(285 - i*30, 0, i*65 - 65, 255), TEXT_ALIGN_LEFT)
				end
			end
		end
		if #TopHD > 0 then
			draw.DrawText("Damage to undead", "HUDFontFix", w*0.1, h*0.45, COLOR_CYAN, TEXT_ALIGN_LEFT)
			for i=1, 5 do
				if TopHD[i] and CurTime() > ENDTIME + i * 0.7 then
					draw.DrawText(TopHD[i], "HUDFontSmallFix", w*0.13, h*0.45 + h*0.05*i, Color(285 - i*30, 0, i*65 - 65, 255), TEXT_ALIGN_LEFT)
				end
			end
		end

		if #TopZ > 0 then
			draw.DrawText("Brains Eaten", "HUDFontFix", w*0.65, h*0.15, COLOR_GREEN, TEXT_ALIGN_LEFT)
			for i=1, 5 do
				if TopZ[i] and CurTime() > ENDTIME + i * 0.7 then
					draw.DrawText(TopZ[i], "HUDFontSmallFix", w*0.68, h*0.15 + h*0.05*i, Color(285 - i*30, 0, i*65 - 65, 255), TEXT_ALIGN_LEFT)
				end
			end
		end
		if #TopZD > 0 then
			draw.DrawText("Damage to humans", "HUDFontFix", w*0.65, h*0.45, COLOR_GREEN, TEXT_ALIGN_LEFT)
			for i=1, 5 do
				if TopZD[i] and CurTime() > ENDTIME + i * 0.7 then
					draw.DrawText(TopZD[i], "HUDFontSmallFix", w*0.68, h*0.45 + h*0.05*i, Color(285 - i*30, 0, i*65 - 65, 255), TEXT_ALIGN_LEFT)
				end
			end
		end

		local time = ENDTIME + cvar_zs_intermission_time:GetInt() - CurTime()
		draw.DrawText("Next: "..ToMinutesSeconds(time >= 0 and time or 0), "HUDFontSmallFix", w*0.5, h*0.7, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if winner == TEAM_UNDEAD then
		hook.Add("HUDPaint", "DrawLose", DrawLose)
		timer.Simple(0.5, function()
			surface.PlaySound(ALLLOSESOUND)
		end)
	else
		if TEAM_HUMAN == LocalPlayer():Team() then
			hook.Add("HUDPaint", "DrawWin", DrawWin)
		else
			hook.Add("HUDPaint", "DrawLose", DrawLose)
		end
		timer.Simple(0.5, function()
			surface.PlaySound(HUMANWINSOUND)
		end)
	end
end

/*function DrawUnlock()
	if ENDROUND then
		hook.Remove("HUDPaint", "DrawUnlock")
		DrawRewardTime = nil
		return
	end
	DrawUnlockTime = DrawUnlockTime or RealTime() + 3
	draw.RoundedBox(16, w * 0.375, h * 0.07, w * 0.25, h * 0.06, color_black_alpha180)
	draw.DrawText(UnlockedClass.." unlocked!", "HUDFontSmallFix", w*0.5 + XNameBlur2, h*0.085 + YNameBlur, Color(200, 0, 0, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(UnlockedClass.." unlocked!", "HUDFontSmallFix", w*0.5, h*0.085, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if RealTime() > DrawUnlockTime then
		hook.Remove("HUDPaint", "DrawUnlock")
		DrawUnlockTime = nil
		UnlockedClass = nil
		return
	end
end*/

local function LoopUnlife()
	if UNLIFE and not ENDROUND and not LASTHUMAN then
		surface.PlaySound(UNLIFESOUND)
		timer.Simple(UNLIFESOUNDLENGTH, LoopUnlife)
	end
end

local function LoopHalflife()
	if HALFLIFE and not ENDROUND and not LASTHUMAN and not UNLIFE then
		surface.PlaySound(HALFLIFESOUND)
		timer.Simple(HALFLIFESOUNDLENGTH, LoopHalflife)
	end
end

local function SetInf(infliction)
	INFLICTION = infliction

	local usesound = false
	local amount = 0
	local UnlockedClass
	for i in ipairs(ZombieClasses) do
		if ZombieClasses[i].Threshold <= INFLICTION and not ZombieClasses[i].Unlocked then
			ZombieClasses[i].Unlocked = true
			UnlockedClass = ZombieClasses[i].Name
			usesound = true
			amount = amount + 1
		end
	end

	if not LASTHUMAN then
		if INFLICTION >= 0.75 and not UNLIFE then
			UNLIFE = true
			HALFLIFE = true
			if not UNLIFEMUTE then 
				RunConsoleCommand("stopsound")
				timer.Simple(0.5, LoopUnlife)
			end
			GAMEMODE:SplitMessage(h * 0.725, "<color=ltred><font=HUDFontBigFix>Un-Life</font></color>", "<color=ltred><font=HUDFontSmallAAFix>Horde locked at 75%</font></color>")
			GAMEMODE:SetUnlifeText()
		elseif INFLICTION >= 0.5 and not HALFLIFE then
			HALFLIFE = true
			if not HALFLIFEMUTE then 
				RunConsoleCommand("stopsound")
				timer.Simple(0.5, LoopHalflife)
			end
			surface.PlaySound("ambient/creatures/town_zombie_call1.wav")
			GAMEMODE:SplitMessage(h * 0.725, "<color=ltred><font=HUDFontBigFix>Half-Life</font></color>", "<color=ltred><font=HUDFontSmallAAFix>Horde locked above 50%</font></color>")
			GAMEMODE:SetHalflifeText()
		elseif usesound then
			if INFLICTION < 0.75 then 
				surface.PlaySound("ambient/creatures/town_zombie_call1.wav")
			else
				surface.PlaySound("npc/zombie_poison/pz_alert2.wav")
			end
			/*if amount > 1 then
				UnlockedClass =  -- So you can have more than one class with the same infliction without getting spammed.
			end
			hook.Add("HUDPaint", "DrawUnlock", DrawUnlock)*/
			if amount == 1 then
				GAMEMODE:SplitMessage(h * 0.12, "<color=green><font=HUDFontAAFix>"..UnlockedClass.." unlocked!</font></color>")
			else
				GAMEMODE:SplitMessage(h * 0.12, "<color=green><font=HUDFontAAFix>"..amount.." classes unlocked!</font></color>")
			end
		end
	end
end
net.Receive("SetInf", function() SetInf(net.ReadFloat()) end)

local function SetInfInit(infliction)
	INFLICTION = infliction
	for i in ipairs(ZombieClasses) do
		if ZombieClasses[i].Threshold <= INFLICTION then
			ZombieClasses[i].Unlocked = true
		end
	end

	if INFLICTION >= 0.75 then
		UNLIFE = true
		HALFLIFE = true
		if not UNLIFEMUTE then 
			LoopUnlife()
		end
	elseif INFLICTION >= 0.5 then
		HALFLIFE = true
		if not HALFLIFEMUTE then 
			LoopHalflife()
		end
	end
end
net.Receive("SetInfInit", function() SetInf(net.ReadFloat()) end)

function DrawLastHuman()
	if ENDROUND then return end
	LASTHUMAN = true
	LastHumanY = LastHumanY or 0
	if LastHumanY > h*0.67 then
		LastHumanHoldTime = LastHumanHoldTime or RealTime()
		if RealTime() > LastHumanHoldTime + 3 then
			LastHumanY = nil
			LastHumanHoldTime = nil
			DrawLastHumanHoldSound = nil
			hook.Remove("HUDPaint", "DrawLastHuman")
			return
		end
	else
		for i=1, 5 do
			if LocalPlayer():Team() == TEAM_SURVIVORS then 
				draw.DrawText("Last Human", "HUDFontBigFix", w*0.5, LastHumanY - i*h*0.02, Color(255, 0, 0, 200 - i*25), TEXT_ALIGN_CENTER)
			else
				draw.DrawText("Kill The Last Human", "HUDFontBigFix", w*0.5, LastHumanY - i*h*0.02, Color(255, 0, 0, 200 - i*25), TEXT_ALIGN_CENTER)
			end
		end
		LastHumanY = LastHumanY + h*0.0075
	end
	if LastHumanHoldTime then
		if not DrawLastHumanHoldSound then
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			surface.PlaySound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
			DrawLastHumanHoldSound = true
		end
		if LocalPlayer():Team() == TEAM_SURVIVORS then 
			draw.DrawText("Last Human", "HUDFontBigFix", w*0.5 + XNameBlur2, YNameBlur + LastHumanY, Color(255, 0, 0, 90), TEXT_ALIGN_CENTER)
			draw.DrawText("Last Human", "HUDFontBigFix", w*0.5 + XNameBlur, YNameBlur + LastHumanY, Color(255, 0, 0, 180), TEXT_ALIGN_CENTER)
			draw.DrawText("Last Human", "HUDFontBigFix", w*0.5, LastHumanY, COLOR_RED, TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Kill The Last Human", "HUDFontBigFix", w*0.5 + XNameBlur2, YNameBlur + LastHumanY, Color(255, 0, 0, 90), TEXT_ALIGN_CENTER)
			draw.DrawText("Kill The Last Human", "HUDFontBigFix", w*0.5 + XNameBlur, YNameBlur + LastHumanY, Color(255, 0, 0, 180), TEXT_ALIGN_CENTER)
			draw.DrawText("Kill The Last Human", "HUDFontBigFix", w*0.5, LastHumanY, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	else
		if LocalPlayer():Team() == TEAM_SURVIVORS then 
			draw.DrawText("Last Human", "HUDFontBigFix", w*0.5, LastHumanY, COLOR_RED, TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Kill The Last Human", "HUDFontBigFix", w*0.5, LastHumanY, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	end
end

function Died()
	LASTDEATH = RealTime()
	hook.Add("HUDPaint", "DrawDeath", DrawDeath)
	surface.PlaySound(DEATHSOUND)
end

function GM:KeyPress(ply, key)
	local ply = LocalPlayer()
	if key == IN_USE and ply:Team() == TEAM_HUMAN then
		local ent = util.TraceLine({start = ply:EyePos(), endpos = ply:EyePos() + ply:GetAimVector() * 50, filter = ply}).Entity
		if ent and ent:IsValid() and ent:IsPlayer() then
			RunConsoleCommand("shove", ent:EntIndex())
		end
	end
end

function DrawDeath()
	if LastHumanY or ENDROUND then return end -- This kind of gives priority to things
	DrawDeathY = DrawDeathY or 0
	if DrawDeathY > h*0.67 then
		DrawDeathHoldTime = DrawDeathHoldTime or RealTime()
		if RealTime() > DrawDeathHoldTime + 3 then
			DrawDeathY = nil
			DrawDeathHoldTime = nil
			DrawDeathHoldSound = nil
			hook.Remove("HUDPaint", "DrawDeath")
			return
		end
	else
		for i=1, 5 do
			draw.SimpleText("You are dead", "HUDFontBigFix", w*0.5, DrawDeathY - i*h*0.02, Color(0, 255, 0, 200 - i*25), TEXT_ALIGN_CENTER)
		end
		DrawDeathY = DrawDeathY + h*0.0075
	end
	if DrawDeathHoldTime then
		if not DrawDeathHoldSound then
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			surface.PlaySound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
			DrawDeathHoldSound = true
		end
		draw.SimpleText("You are dead", "HUDFontBigFix", w*0.5 + XNameBlur2, YNameBlur + DrawDeathY, Color(0, 255, 0, 90), TEXT_ALIGN_CENTER)
		draw.SimpleText("You are dead", "HUDFontBigFix", w*0.5 + XNameBlur, YNameBlur + DrawDeathY, Color(0, 255, 0, 180), TEXT_ALIGN_CENTER)
		draw.SimpleText("You are dead", "HUDFontBigFix", w*0.5, DrawDeathY, COLOR_GREEN, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("You are dead", "HUDFontBigFix", w*0.5, DrawDeathY, COLOR_GREEN, TEXT_ALIGN_CENTER)
	end
end

function DrawLose()
	DrawLoseY = DrawLoseY or 0
	if DrawLoseY > h*0.8 then
		DrawLoseHoldTime = true
	else
		for i=1, 5 do
			draw.DrawText("You have lost.", "HUDFontBigFix", w*0.5, DrawLoseY - i*h*0.02, Color(255, 0, 0, 200 - i*25), TEXT_ALIGN_CENTER)
		end
		DrawLoseY = DrawLoseY + h * 0.495 * FrameTime()
	end
	if DrawLoseHoldTime then
		if not DrawLoseSound then
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			surface.PlaySound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
			DrawLoseSound = true
		end
		if not DISABLE_PP:GetBool() and 90 <= render.GetDXLevel() then
			ColorModify["$pp_colour_contrast"] = math.Approach(ColorModify["$pp_colour_contrast"], 0.4, FrameTime()*0.5)
			DrawColorModify(ColorModify)
		end
		draw.DrawText("You have lost.", "HUDFontBigFix", w*0.5 + XNameBlur2, YNameBlur + DrawLoseY, Color(255, 0, 0, 90), TEXT_ALIGN_CENTER)
		draw.DrawText("You have lost.", "HUDFontBigFix", w*0.5 + XNameBlur, YNameBlur + DrawLoseY, Color(255, 0, 0, 180), TEXT_ALIGN_CENTER)
		draw.DrawText("You have lost.", "HUDFontBigFix", w*0.5, DrawLoseY, COLOR_RED, TEXT_ALIGN_CENTER)
	else
		draw.DrawText("You have lost.", "HUDFontBigFix", w*0.5, DrawLoseY, COLOR_RED, TEXT_ALIGN_CENTER)
	end
end

function DrawWin()
	DrawWinY = DrawWinY or 0

	if DrawWinY > h*0.8 then
		DrawWinHoldTime = true
	else
		for i=1, 5 do
			draw.DrawText("You have survived!", "HUDFontBigFix", w*0.5, DrawWinY - i*h*0.02, Color(0, 0, 255, 200 - i*25), TEXT_ALIGN_CENTER)
		end
		DrawWinY = DrawWinY + h * 0.495 * FrameTime() 
	end

	if DrawWinHoldTime then
		if not DrawWinSound then
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			surface.PlaySound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
			DrawWinSound = true
		end

		if not DISABLE_PP:GetBool() then
			ColorModify["$pp_colour_contrast"] = math.Approach(ColorModify["$pp_colour_contrast"], 2, FrameTime() * 0.5)
			DrawColorModify(ColorModify)
		end

		draw.DrawText("You have survived!", "HUDFontBigFix", w*0.5 + XNameBlur2, YNameBlur + DrawWinY, Color(0, 0, 255, 90), TEXT_ALIGN_CENTER)
		draw.DrawText("You have survived!", "HUDFontBigFix", w*0.5 + XNameBlur, YNameBlur + DrawWinY, Color(0, 0, 255, 180), TEXT_ALIGN_CENTER)
		draw.DrawText("You have survived!", "HUDFontBigFix", w*0.5, DrawWinY, COLOR_BLUE, TEXT_ALIGN_CENTER)
	else
		draw.DrawText("You have survived!", "HUDFontBigFix", w*0.5, DrawWinY, COLOR_BLUE, TEXT_ALIGN_CENTER)
	end
end

function Rewarded()
	surface.PlaySound("weapons/physcannon/physcannon_charge.wav")
	GAMEMODE:SplitMessage(h * 0.725, "<color=ltred><font=HUDFontSmallAAFix>Arsenal Upgraded</font></color>", "<color=ltred><font=HL2MPTypeDeath>0</font></color>")
end
rW = Rewarded

hook.Add( "PlayerFootstep", "ZombieFootsteps", function( ply, pos, foot, sound, volume, rf )
	if ply:Team() == TEAM_HUMAN then 

		return false
	else
		if ply:GetZombieClass() == 1 and ply:GetColor() == Color(255, 255, 255, 255) or ply:GetZombieClass() == 9 then
			if math.random(1, 10) == 1 then  
				ply:EmitSound("npc/zombie/foot_slide"..math.random(1,3)..".wav")
			else
				ply:EmitSound("npc/zombie/foot"..math.random(1,3)..".wav")
			end
		elseif ply:GetZombieClass() == 2 then
			ply:EmitSound("npc/fast_zombie/foot"..math.random(1,4)..".wav")
		elseif ply:GetZombieClass() == 3 then
			if math.random(1, 5) == 1 then
				ply:EmitSound("npc/zombie_poison/pz_right_foot1.wav")
			else
				ply:EmitSound("npc/zombie_poison/pz_left_foot1.wav")
			end
		elseif ply:GetZombieClass() == 4 then
			ply:EmitSound("npc/combine_soldier/gear"..math.random(1,6)..".wav")
		elseif ply:GetZombieClass() == 5 and ply:GetVelocity():Length() > 120 then
			if math.random(1, 2) == 1 then 
				ply:EmitSound("npc/stalker/stalker_footstep_left"..math.random(1,2)..".wav")
			else
				ply:EmitSound("npc/stalker/stalker_footstep_right"..math.random(1,2)..".wav")
			end
		elseif ply:GetZombieClass() > 5 and ply:GetZombieClass() < 9 then
			ply:EmitSound("npc/headcrab_poison/ph_step"..math.random(1,4)..".wav")
		elseif ply:GetZombieClass() == 10 then
			ply:EmitSound("npc/zombine/gear"..math.random(1,3)..".wav")
		end

		return true
	end
end )