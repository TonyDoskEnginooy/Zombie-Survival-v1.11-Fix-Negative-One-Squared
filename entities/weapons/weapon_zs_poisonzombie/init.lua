AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Headcrabs = 2

function SWEP:SetThrowAnimTime(time)
	self:SetDTFloat(0, time)
end

function SWEP:Deploy()
	self:GetOwner():DrawViewModel(true)
	self:GetOwner():DrawWorldModel(false)
	self:SendWeaponAnim(ACT_VM_DRAW)
	timer.Simple(1, function() 
		if self.Alive then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end

SWEP.survHit = false
SWEP.Alive = true

function SWEP:Think()
	if IsValid(self:GetOwner()) then 
		self.Alive = true
	else
		self.Alive = false
	end

	if not self.NextHit then return end

	if self.NextSwingAnim and CurTime() > self.NextSwingAnim then
		if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
		self.SwapAnims = not self.SwapAnims
		self.NextSwingAnim = nil
	end

	if CurTime() < self.NextHit then return end

	local owner = self:GetOwner()

	self.NextHit = nil

	local trace, ent = owner:CalcMeleeHit(self.MeleeHitDetection)
	if (not ent:IsPlayer() or ent:IsPlayer() and ent:Team() ~= owner:Team()) and not ent:IsValid() and self.PreHit and self.PreHit:IsValid() and self.PreHit:GetPos():Distance(owner:GetShootPos()) < 125 then
		ent = self.PreHit
		trace.Hit = true
	end

	local damage = 45 + 45 * math.min(GetZombieFocus(owner:GetPos(), 300, 0.001, 0) - 0.3, 1)

	if not ent:IsValid() and not trace.Hit then
		for _, fin in ipairs(ents.FindInSphere(owner:GetShootPos() + owner:GetAimVector() * 50, 20)) do
			if fin ~= owner then
				if fin:GetClass() == "func_breakable_surf" then
					fin:Fire("break", "", 0)
				else
					local phys = fin:GetPhysicsObject()
					if fin:IsPlayer() and fin:Team() ~= owner:Team() then
						if fin:Team() == TEAM_UNDEAD then
							local vel = owner:GetAimVector() * 400
							vel.z = 100
							fin:SetVelocity(vel)
						end
					elseif phys:IsValid() and not fin:IsNPC() and phys:IsMoveable() then
						local vel = damage * 650 * owner:GetAimVector()

						phys:ApplyForceOffset(vel, (fin:NearestPoint(owner:GetShootPos()) + fin:GetPos() * 2) / 3)
						fin:SetPhysicsAttacker(owner)
					end
					fin:TakeDamage(damage, owner)
				end
				if fin:IsPlayer() and fin:Team() ~= owner:Team() or not fin:IsPlayer() and not fin:IsNextBot() and not fin:IsWorld() and fin:GetClass() ~= "trigger_soundscape" and fin:GetClass() ~= "info_target" and fin:GetClass() ~= "zombiegasses" then
					self.survHit = true
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
			if ent:IsPlayer() then
				if ent:Team() == TEAM_UNDEAD then
					local vel = owner:EyeAngles():Forward() * 500
					vel.z = 120
					ent:SetVelocity(vel)
				end
			elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
				local vel = damage * 600 * owner:EyeAngles():Forward()

				phys:ApplyForceOffset(vel, (ent:NearestPoint(owner:GetShootPos()) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(owner)
			end
			ent:TakeDamage(damage, owner)
		end
	end

 	if trace.Hit or ent:IsValid() or self.survHit then
		owner:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 90, 80)
	end

	owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 90, 80)
	self.PreHit = nil
	self.survHit = false
end

SWEP.NextSwing = 0
function SWEP:PrimaryAttack()
	if CurTime() < self.NextSwing then return end
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:GetOwner():EmitSound("npc/zombie_poison/pz_warn"..math.random(1, 2)..".wav")
	self.NextSwing = CurTime() + self.Primary.Delay
	self.NextSwingAnim = CurTime() + 0.6
	self.NextHit = CurTime() + 1
	local trace, ent = self:GetOwner():CalcMeleeHit(self.MeleeHitDetection)
	if ent:IsValid() then
		self.PreHit = ent
	end
	timer.Simple(2, function() 
		if self.NextSwing and CurTime() < self.NextSwing then return end
		if self.Alive then  
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end

SWEP.NextYell = 0
function SWEP:SecondaryAttack()
	if CurTime() < self.NextYell then return end
	if self.Headcrabs <= 0 then
		self:GetOwner():EmitSound("npc/zombie_poison/pz_idle"..math.random(2,4)..".wav")
		self.NextYell = CurTime() + 2
		return
	end
	self:SetThrowAnimTime(CurTime() + self.ThrowAnimBaseTime)
	self:GetOwner():SetAnimation(PLAYER_SUPERJUMP)
	self:GetOwner():EmitSound("npc/zombie_poison/pz_throw"..math.random(2,3)..".wav")
	GAMEMODE:SetPlayerSpeed(self:GetOwner(), 1)
	self.NextYell = CurTime() + 4
	timer.Simple(1, function()
		if IsValid(self) and IsValid(self:GetOwner()) then
			ThrowHeadcrab(self:GetOwner(), self)
		end
	end)
	timer.Simple(4, function() 
		if self.NextYell and CurTime() < self.NextYell then return end
		if self.Alive then  
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end
