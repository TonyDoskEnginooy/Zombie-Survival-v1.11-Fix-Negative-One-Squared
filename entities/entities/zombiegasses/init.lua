AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Heal = self.Heal or 25
	self:DrawShadow(false)
	self:Fire("attack", "", 1.5)
	if self:GetRadius() == 0 then self:SetRadius(400) end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "radius" then
		self:SetRadius(tonumber(value))
	elseif key == "heal" then
		self.Heal = tonumber(value) or self.Heal
	end
end

local function TrueVisible(posa, posb)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("npc_*"))
	filt = table.Add(filt, ents.FindByClass("prop_*"))
	filt = table.Add(filt, player.GetAll())

	return not util.TraceLine({start = posa, endpos = posb, filter = filt}).Hit
end

local function GasProtection(ply, tim)
	GAMEMODE:SetPlayerSpeed(ply, ZombieClasses[ply:GetZombieClass()].Speed * 1.5)
	ply:SetMaterial("models/shiny")
	ply:GodEnable()
	timer.Create(ply:UserID().."SpawnProtection", tim, 1, function()
		if IsValid(ply) then
			DeSpawnProtection(ply)
		end
	end)
end

local function NoGasProtection(ply)
	if ply:IsValid() and ply:IsPlayer() then
		GAMEMODE:SetPlayerSpeed(ply, ZombieClasses[ply.Class].Speed)
		if ZombieClasses[ply.Class].Name == "Chem-Zombie" then
			ply:SetMaterial("models/props_combine/tprings_globe")
		else
			ply:SetMaterial("")
		end
		ply:GodDisable()
	end
end

function ENT:AcceptInput(name, activator, caller, arg)
	if name == "attack" then
		self:Fire("attack", "", 1.5)

		local cvar_zs_wave0 = GetConVar("zs_wave0")
		local spawnProtectionTime = ( team.NumPlayers(TEAM_SURVIVORS) / player.GetCount() ) * 5

		if cvar_zs_wave0:GetInt() <= CurTime() then
			local vPos = self:GetPos()
			for _, ent in pairs(ents.FindInSphere(vPos, self:GetRadius())) do
				if ent:IsPlayer() and ent:Alive() and TrueVisible(vPos, ent:EyePos()) then
					if ent:Team() == TEAM_ZOMBIE then
						SpawnProtection(ent, math.max( spawnProtectionTime, 0 ) )
					elseif 5 < ent:Health() then
						ent:ViewPunch(Angle(math.random(-10, 10), math.random(-10, 10), math.random(-20, 20)))
						ent:EmitSound("player/pl_pain"..math.random(5,7)..".wav")
						ent:SendLua("PoisEff()")
					end
				end
			end
		end

		return true
	end
end
