AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- This is to get around that dumb thing where the view anims don't play right.
SWEP.SwapAnims = false

function SWEP:SetNextYell(time)
	self:SetDTFloat(0, time)
end

local Cloaked = Color(255, 255, 255, 50)
local DeCloaked = Color(255, 255, 255, 255)

function SWEP:Deploy()
	self:GetOwner():DrawViewModel(true)
	self:GetOwner():DrawWorldModel(false)
	self:GetOwner():SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:GetOwner().ZomAnim = math.random(1, 3)
	self:SetNextYell(0)
	self.Invis = 0
	self.InvisAction = 0
	self:GetOwner():SetColor(DeCloaked)
	GAMEMODE:SetPlayerSpeed(self:GetOwner(), ZombieClasses[self:GetOwner():GetZombieClass()].Speed)
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

SWEP.Alive = true
local Touching = Vector(50, 50, 50)
SWEP.survHit = false

function SWEP:Think()
	if IsValid(self:GetOwner()) then 
		self.Alive = true
	else
		self.Alive = false
	end
	
	if self:GetOwner():GetColor() == Cloaked then 
		for _,surv in pairs(ents.FindInBox(self:GetOwner():GetPos() + self:GetOwner():OBBMins() + Touching, self:GetOwner():GetPos() + self:GetOwner():OBBMaxs() - Touching)) do
			if IsValid(surv) and surv ~= self:GetOwner() and surv:IsPlayer() and surv:Alive() and surv:Team() ~= self:GetOwner():Team() then
				self:GetOwner():SetColor(DeCloaked)
				timer.Simple(0.5, function() 
					if self.Alive and self.Invis == 1 then 
						self:GetOwner():SetColor(Cloaked)
					end
				end )
			end
		end
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

	local damage = 20 + 20 * math.min(GetZombieFocus(ply:GetPos(), 300, 0.001, 0) - 0.3, 1)

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
				if fin:IsPlayer() and fin:Team() ~= ply:Team() or not fin:IsPlayer() and not fin:IsNextBot() then
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
		timer.Simple(1.5, function() 
			if self.NextSwing and CurTime() < self.NextSwing then return end
			if self.Alive then  
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end )
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextYell() or CurTime() < self.InvisAction then return end
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
				self:GetOwner():SetColor(Cloaked)
				GAMEMODE:SetPlayerSpeed(self:GetOwner(), 300)
				self:GetOwner():EmitSound("ambient/creatures/town_scared_sob2.wav")
			end
		end )
	else
		self:SetNextYell(CurTime() + self.YellTime)
		self:GetOwner():SetAnimation(PLAYER_SUPERJUMP)
		self:GetOwner():SetColor(DeCloaked)
		GAMEMODE:SetPlayerSpeed(self:GetOwner(), 100)
		self.InvisAction = CurTime() + 2.1
		self:GetOwner():EmitSound("npc/zombie/zombie_alert"..math.random(1, 3)..".wav")
		self.Invis = 0
		timer.Simple(2, function() 
			if self.Alive then 
				GAMEMODE:SetPlayerSpeed(self:GetOwner(), ZombieClasses[self:GetOwner():GetZombieClass()].Speed)
				self.Invis = 0
				self:GetOwner():SetColor(DeCloaked)
			end
		end )
		timer.Simple(2.6, function() 
			if self.Alive then
				self.Invis = 0
				self:GetOwner():SetColor(DeCloaked)
			end
		end )
	end
end

hook.Add("PlayerHurt", "ZombieHurt", function(victim, attacker) 
	if ( attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN and victim:IsPlayer() and victim:Team() == TEAM_UNDEAD and victim:GetZombieClass() == 1 ) then
		if victim:GetColor() == Cloaked then 
	        victim:SetColor(DeCloaked)
	        timer.Simple(0.5, function() 
	        	victim:SetColor(Cloaked)
	    	end )
	    end
	    if victim:GetMaxSpeed() == ZombieClasses[victim:GetZombieClass()].Speed then 
		    GAMEMODE:SetPlayerSpeed(victim, 150)
		    timer.Simple(2, function() 
		        GAMEMODE:SetPlayerSpeed(victim, ZombieClasses[victim:GetZombieClass()].Speed)
		    end )
		end
    end
end )
