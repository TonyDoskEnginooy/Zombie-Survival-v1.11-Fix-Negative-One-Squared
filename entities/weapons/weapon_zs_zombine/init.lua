-- WIP

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- This is to get around that dumb thing where the view anims don't play right.
SWEP.SwapAnims = false

function SWEP:SetNextSwing(time)
	self:SetDTFloat(0, time)
end

function SWEP:Deploy()
	self:GetOwner():DrawViewModel(true)
	self:GetOwner():DrawWorldModel(false)
	self:GetOwner().ZomAnim = math.random(1, 3)
	self:SetNextSwing(0)
	self.GrenadeOut = 0
	GAMEMODE:SetPlayerSpeed(self:GetOwner(), ZombieClasses[self:GetOwner():GetZombieClass()].Speed)
	self:SendWeaponAnim(ACT_VM_DRAW)
	timer.Simple(1, function() 
		if self.Alive then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end

SWEP.Alive = true
SWEP.survHit = false

function SWEP:Think()
	if IsValid(self:GetOwner()) then 
		self.Alive = true
	else
		self.Alive = false
	end

	if self:GetOwner():Health() <= ZombieClasses[self:GetOwner():GetZombieClass()].Health / 2 and self.GrenadeOut == 0 then 
		GAMEMODE:SetPlayerSpeed(self:GetOwner(), 200)
	end

	if not self.NextHit then return end
	if CurTime() < self.NextHit then return end
	self.NextHit = nil
	self:GetOwner():GetViewModel():SetPlaybackRate(3)

	local ply = self:GetOwner()

	local trace, ent = ply:CalcMeleeHit(self.MeleeHitDetection)
	if not ent:IsValid() and self.PreHit and self.PreHit:IsValid() and self.PreHit:GetPos():Distance(ply:GetShootPos()) < 125 then
		ent = self.PreHit
		trace.Hit = true
	end

	local damage = 30 + 30 * math.min(GetZombieFocus(ply:GetPos(), 300, 0.001, 0) - 0.3, 1)

	if not ent:IsValid() and not trace.Hit then
		for _, fin in ipairs(ents.FindInSphere(ply:GetShootPos() + ply:GetAimVector() * 50, 20)) do
			if fin ~= ply then
				if fin:GetClass() == "func_breakable_surf" then
					fin:Fire("break", "", 0)
				else
					local phys = fin:GetPhysicsObject()
					if fin:IsPlayer() and fin:Team() == ply:Team() then
						local vel = ply:GetAimVector() * 300
						vel.z = 100
						fin:SetVelocity(vel)
					elseif phys:IsValid() and not fin:IsNPC() and phys:IsMoveable() then
						local vel = damage * 650 * ply:GetAimVector()

						phys:ApplyForceOffset(vel, (fin:NearestPoint(ply:GetShootPos()) + fin:GetPos() * 2) / 3)
						fin:SetPhysicsAttacker(ply)
					end
					fin:TakeDamage(damage, ply)
				end
				self.survHit = true
				if fin:IsPlayer() then
					break
				end
			end
		end
	end

	if ent and ent:IsValid() then
		if ent:GetClass() == "func_breakable_surf" then
			ent:Fire("break", "", 0)
		else
			local phys = ent:GetPhysicsObject()
			if ent:IsPlayer() and ent:Team() == ply:Team() then
				local vel = ply:GetAimVector() * 300
				vel.z = 100
				ent:SetVelocity(vel)
			elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
				local vel = damage * 650 * ply:GetAimVector()

				phys:ApplyForceOffset(vel, (ent:NearestPoint(ply:GetShootPos()) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(ply)
			end
			ent:TakeDamage(damage, ply)
		end
	end

	if trace.Hit or ent:IsValid() or self.survHit then
		ply:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav")
	end

	ply:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav")
	self.PreHit = nil
	self.survHit = false
end

function SWEP:PrimaryAttack()
	if CurTime() < self:GetNextSwing() or self.GrenadeOut == 1 then return end
	if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
	self.SwapAnims = not self.SwapAnims
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:GetOwner():EmitSound("npc/zombine/zombine_charge1.wav")
	self:SetNextSwing(CurTime() + self.Primary.Delay)
	self.NextHit = CurTime() + 0.1
	local trace, ent = self:GetOwner():CalcMeleeHit(self.MeleeHitDetection)
	if ent:IsValid() then
		self.PreHit = ent
	end
	timer.Simple(1.5, function() 
		if self:GetNextSwing() and CurTime() < self:GetNextSwing() then return end
		if self.Alive then  
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end

SWEP.NextYell = 0
function SWEP:SecondaryAttack()
	if CurTime() < self.NextYell or self.GrenadeOut == 1 then return end
	self:GetOwner():SetAnimation(PLAYER_SUPERJUMP)

	self:GetOwner():EmitSound("npc/zombine/zombine_idle"..math.random(1, 4)..".wav")
	self.NextYell = CurTime() + self.YellTime
end

SWEP.GrenadeOut = 0
function SWEP:Reload()
	if self:GetOwner():HasGodMode() or self.GrenadeOut == 1 then return end
	if self.GrenadeOut == 0 then 
		self.GrenadeOut = 1
		GAMEMODE:SetPlayerSpeed(self:GetOwner(), 1)
		self:GetOwner():EmitSound("npc/zombine/zombine_alert"..math.random(1, 7)..".wav")
		timer.Simple(1, function()
			if self.Alive then  
				GAMEMODE:SetPlayerSpeed(self:GetOwner(), 200)
				self:GetOwner():EmitSound("npc/zombine/zombine_charge2.wav")
				self:GetOwner():SetHealth(self:GetOwner():Health() / 2)
			end
			timer.Simple(3.99, function() 
				if self.Alive then
					self.GrenadeOut = 0
					GAMEMODE:SetPlayerSpeed(self:GetOwner(), 300)
				end
			end )
			timer.Simple(4, function() 
				if self.Alive then
					self:GetOwner():Kill()
				end
			end )
		end )
	end
end
