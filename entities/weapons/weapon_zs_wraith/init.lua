AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Deploy()
	self.CloakFail = 0

	local owner = self:GetOwner()
	owner:DrawViewModel(true)
	owner:DrawWorldModel(false)
	owner:DrawShadow(false)
	owner:SetRenderMode(RENDERMODE_TRANSCOLOR)
	//owner:SetMaterial("models/props_combine/com_shield001a")

	local hookname = "WraithCloackFail" .. tostring(owner)
	local timername = "WraithCloackRecover" .. tostring(owner)
	local wep = self
	local recovercloack = function() if wep:IsValid() then self.CloakFail = 0 end end
	hook.Add("EntityTakeDamage", hookname, function(target, dmginfo)
		if target ~= owner then return end

		if not owner:IsValid() or not wep:IsValid() then
			hook.Remove("EntityTakeDamage", hookname)
			return
		end

		wep.CloakFail = 150
		timer.Create(timername, 0.2, 1, recovercloack)
		owner:SetColor(Color(20, 20, 20, 200))
	end)
end

function SWEP:Think()
	local owner = self:GetOwner()

	if self.NextHit then
		owner:SetColor(Color(20, 20, 20, 200))
	else
		local vel = owner:GetVelocity():Length()
		local min

		if vel > 0 then
			min = vel
		else
			min = math.random(1 + (self.CloakFail ~= 0 and 60 or 0), 22 + self.CloakFail)
		end

		owner:SetColor(Color(20, 20, 20, math.min(min, 200)))
		return
	end

	if self.NextSwingAnim and CurTime() > self.NextSwingAnim then
		if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
		self.SwapAnims = not self.SwapAnims
		self.NextSwingAnim = nil
	end

	if CurTime() < self.NextHit then return end

	self.NextHit = nil

	local trace, ent = owner:CalcMeleeHit(self.MeleeHitDetection)
	if not ent:IsValid() and self.PreHit and self.PreHit:IsValid() and self.PreHit:GetPos():Distance(owner:GetShootPos()) < 115 then
		ent = self.PreHit
		trace.Hit = true
	end

	local damage = 45 + 45 * math.min(GetZombieFocus(owner:GetPos(), 300, 0.001, 0) - 0.3, 1)

	if ent and ent:IsValid() then
		if ent:GetClass() == "func_breakable_surf" then
			ent:Fire("break", "", 0)
		else
			local phys = ent:GetPhysicsObject()
			if ent:IsPlayer() then
				if ent:Team() == TEAM_UNDEAD then
					local vel = owner:EyeAngles():Forward() * 500
					vel.z = 120
					ent:SetVelocity(vel)
				end
			elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
				local vel = damage * 650 * owner:EyeAngles():Forward()

				phys:ApplyForceOffset(vel, (ent:NearestPoint(owner:GetShootPos()) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(owner)
			end
			ent:TakeDamage(damage, owner)
		end
	end

	if trace.Hit then
		owner:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 90, 80)
		// util.Decal("Blood", trace.HitPos + trace.HitNormal*10, trace.HitPos - trace.HitNormal*10)
	end

	owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 90, 80)

	self.PreHit = nil

	if owner:HasGodMode() then
		GAMEMODE:SetPlayerSpeed(owner, ZombieClasses[owner:GetZombieClass()].Speed * 1.5)
		owner:SetMaxSpeed(ZombieClasses[owner:GetZombieClass()].Speed * 1.5)
	else
		GAMEMODE:SetPlayerSpeed(owner, ZombieClasses[owner:GetZombieClass()].Speed)
		owner:SetMaxSpeed(ZombieClasses[owner:GetZombieClass()].Speed)
	end
end

SWEP.NextSwing = 0
function SWEP:PrimaryAttack()
	if CurTime() < self.NextSwing then return end
	self.NextSwing = CurTime() + self.Primary.Delay
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:GetOwner():EmitSound("npc/antlion/distract1.wav")
	self.NextSwingAnim = 0
	self.NextHit = CurTime() + 0.75
	local trace, ent = self:GetOwner():CalcMeleeHit(self.MeleeHitDetection)
	if ent:IsValid() then
		self.PreHit = ent
	end
	GAMEMODE:SetPlayerSpeed(self:GetOwner(), 1)
	self:GetOwner():SetMaxSpeed(1)
end

SWEP.NextYell = 0
function SWEP:SecondaryAttack()
	if CurTime() < self.NextYell then return end
	self.NextYell = CurTime() + 6
	self:GetOwner():EmitSound("wraithdeath"..math.random(1, 4)..".wav")
end

function GAMEMODE:PlayerButtonDown(ply, button)
	if button == KEY_LSHIFT and not ply:HasGodMode() and ply:GetMaxSpeed() == ZombieClasses[ply:GetZombieClass()].Speed then
		GAMEMODE:SetPlayerSpeed(ply, 100)
		ply:SetMaxSpeed(100)
	end
end

function GAMEMODE:PlayerButtonUp(ply, button)
	if button == KEY_LSHIFT and not ply:HasGodMode() and ply:GetMaxSpeed() == 100 then
		GAMEMODE:SetPlayerSpeed(ply, ZombieClasses[ply:GetZombieClass()].Speed)
	end
end
