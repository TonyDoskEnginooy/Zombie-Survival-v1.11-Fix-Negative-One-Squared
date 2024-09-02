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
	self:GetOwner():SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:GetOwner().ZomAnim = math.random(1, 3)
	self:SetNextYell(0)
	self.Invis = 0
	self.InvisAction = 0
	self:GetOwner():SetMaterial("")
	GAMEMODE:SetPlayerSpeed(self:GetOwner(), ZombieClasses[self:GetOwner():GetZombieClass()].Speed)
end

-- This is kind of unique. It does a trace on the pre swing to see if it hits anything
-- and then if the after-swing doesn't hit anything, it hits whatever it hit in
-- the pre-swing, as long as the distance is low enough.

SWEP.Alive = true
local Touching = Vector(50, 50, 50)

function SWEP:Think()
	for _,surv in pairs(ents.FindInBox(self:GetOwner():GetPos() + self:GetOwner():OBBMins() + Touching, self:GetOwner():GetPos() + self:GetOwner():OBBMaxs() - Touching)) do
		if self:GetOwner():GetColor() == Color(255, 255, 255, 50) then 
			if IsValid(surv) and surv ~= self:GetOwner() and surv:IsPlayer() and surv:Alive() then
				self:GetOwner():SetColor(Color(255, 255, 255, 255))
				timer.Simple(0.5, function() 
					self:GetOwner():SetColor(Color(255, 255, 255, 50))
				end )
			end
		end
	end
	if not self.NextHit then return end
	if CurTime() < self.NextHit then return end
	self.NextHit = nil

	if IsValid(self:GetOwner()) then 
		self.Alive = true
	else
		self.Alive = false
	end

	local ply = self:GetOwner()

	local trace, ent = ply:CalcMeleeHit(self.MeleeHitDetection)
	if not ent:IsValid() and self.PreHit and self.PreHit:IsValid() and self.PreHit:GetPos():Distance(ply:GetShootPos()) < 125 then
		ent = self.PreHit
		trace.Hit = true
	end

	local damage = 30 + 30 * math.min(GetZombieFocus(ply:GetPos(), 300, 0.001, 0) - 0.3, 1)

	if ent and ent:IsValid() then
		if ent:GetClass() == "func_breakable_surf" then
			ent:Fire("break", "", 0)
		else
			local phys = ent:GetPhysicsObject()
			if ent:IsPlayer() then
				if ent:Team() == TEAM_UNDEAD then
					local vel = ply:GetAimVector() * 400
					vel.z = 100
					ent:SetVelocity(vel)
				end
			elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
				local vel = damage * 650 * ply:GetAimVector()

				phys:ApplyForceOffset(vel, (ent:NearestPoint(ply:GetShootPos()) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(ply)
			end
			ent:TakeDamage(damage, ply)
		end
	end

	if trace.Hit then
		ply:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav")
	end

	ply:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav")
	self.PreHit = nil
end

SWEP.NextSwing = 0

function SWEP:PrimaryAttack()
	if self.InvisAction < CurTime() and self.Invis == 0 then 
		if CurTime() < self.NextSwing then return end
		if self.SwapAnims then self:SendWeaponAnim(ACT_VM_HITCENTER) else self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
		self.SwapAnims = not self.SwapAnims
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:GetOwner():EmitSound("npc/zombie/zo_attack"..math.random(1, 2)..".wav")
		self.NextSwing = CurTime() + self.Primary.Delay
		self.NextHit = CurTime() + 0.6
		local trace, ent = self:GetOwner():CalcMeleeHit(self.MeleeHitDetection)
		if ent:IsValid() then
			self.PreHit = ent
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextYell() then return end
	self:GetOwner():SetAnimation(PLAYER_SUPERJUMP)

	self:GetOwner():EmitSound("npc/zombie/zombie_voice_idle"..math.random(1, 14)..".wav")
	self:SetNextYell(CurTime() + self.YellTime)
end

SWEP.Invis = 0
SWEP.InvisAction = 0

function SWEP:Reload()
	if CurTime() < self.InvisAction or self:GetOwner():HasGodMode() then return end
	if self.Invis == 0 then 
		GAMEMODE:SetPlayerSpeed(self:GetOwner(), 100)
		self.InvisAction = CurTime() + 4
		timer.Simple(2, function() 
			if self.Alive then 
				self.Invis = 1
				self:GetOwner():SetColor(Color(255, 255, 255, 50))
				GAMEMODE:SetPlayerSpeed(self:GetOwner(), 300)
				self:GetOwner():EmitSound("ambient/voices/squeal1.wav")
			end
		end )
	else
		self:GetOwner():SetColor(Color(255, 255, 255, 255))
		GAMEMODE:SetPlayerSpeed(self:GetOwner(), 100)
		self.InvisAction = CurTime() + 2.1
		self:GetOwner():EmitSound("ambient/voices/f_scream1.wav")
		self.Invis = 0
		timer.Simple(2, function() 
			if self.Alive then 
				GAMEMODE:SetPlayerSpeed(self:GetOwner(), ZombieClasses[self:GetOwner():GetZombieClass()].Speed)
			end
		end )
	end
end

hook.Add("PlayerHurt", "ZombieHurt", function(victim, attacker) 
	if ( attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN and victim:IsPlayer() and victim:Team() == TEAM_UNDEAD and victim:GetColor() == Color(255, 255, 255, 50) ) then
        victim:SetColor(Color(255, 255, 255, 255))
        timer.Simple(0.5, function() 
        	victim:SetColor(Color(255, 255, 255, 50))
    	end )
    end
end )
