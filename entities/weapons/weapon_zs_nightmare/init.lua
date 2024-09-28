AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- This is to get around that dumb thing where the view anims don't play right.
SWEP.SwapAnims = false

function SWEP:SetNextYell(time)
	self:SetDTFloat(0, time)
end

function SWEP:Deploy()
	self:GetOwner():DrawViewModel(true)
	self:GetOwner():DrawWorldModel(false)
	self:GetOwner().ZomAnim = math.random(1, 3)
	self:SetNextYell(0)
	self:SendWeaponAnim(ACT_VM_DRAW)
	timer.Simple(1, function() 
		if self.Alive then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end )
end

-- This is kind of unique. It does a trace on the pre swing to see if it hits anything
-- and then if the after-swing doesn't hit anything, it hits whatever it hit in
-- the pre-swing, as long as the distance is low enough.

SWEP.survHit = false

function SWEP:Think()
	if IsValid(self:GetOwner()) then 
		self.Alive = true
	else
		self.Alive = false
	end

	if not self.NextHit then return end
	if CurTime() < self.NextHit then return end
	self.NextHit = nil

	local ply = self:GetOwner()

	local trace, ent = ply:CalcMeleeHit(self.MeleeHitDetection)
	if (not ent:IsPlayer() or ent:IsPlayer() and ent:Team() ~= ply:Team()) and not ent:IsValid() and self.PreHit and self.PreHit:IsValid() and self.PreHit:GetPos():Distance(ply:GetShootPos()) < 125 then
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
					if fin:IsPlayer() and fin:Team() ~= ply:Team() then
						local vel 
						if fin:IsOnGround() then 
							vel = ply:GetAimVector() * 800
						else
							vel = ply:GetAimVector() * 300
						end
						vel.z = 100
						fin:SetVelocity(vel)
					elseif phys:IsValid() and not fin:IsNPC() and phys:IsMoveable() then
						local vel = damage * 650 * ply:GetAimVector()

						phys:ApplyForceOffset(vel, (fin:NearestPoint(ply:GetShootPos()) + fin:GetPos() * 2) / 3)
						fin:SetPhysicsAttacker(ply)
					end
					fin:TakeDamage(damage, ply)
				end
				if fin:IsPlayer() and fin:Team() ~= ply:Team() or not fin:IsPlayer() and not fin:IsNextBot() and not fin:IsWorld() and fin:GetClass() ~= "trigger_soundscape" and fin:GetClass() ~= "info_target" and fin:GetClass() ~= "zombiegasses" then
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
				if ent:IsOnGround() then 
					vel = ply:GetAimVector() * 800
				else
					vel = ply:GetAimVector() * 300
				end
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

SWEP.NextSwing = 0

function SWEP:PrimaryAttack()
		if CurTime() < self.NextSwing then return end
		if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
		self.SwapAnims = not self.SwapAnims
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:GetOwner():EmitSound("npc/barnacle/barnacle_bark"..math.random(1, 2)..".wav")
		self.NextSwing = CurTime() + self.Primary.Delay
		self.NextHit = CurTime() + 0.6
		local trace, ent = self:GetOwner():CalcMeleeHit(self.MeleeHitDetection)
		if ent:IsValid() then
			self.PreHit = ent
		end
		timer.Simple(1.5, function() 
			if self.NextSwing and CurTime() < self.NextSwing then return end
			if self.Alive then  
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end )
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextYell() then return end
	self:GetOwner():SetAnimation(PLAYER_SUPERJUMP)

	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(1, 3)..".wav")
	self:SetNextYell(CurTime() + self.YellTime)
end

function SWEP:Reload()
	
end
