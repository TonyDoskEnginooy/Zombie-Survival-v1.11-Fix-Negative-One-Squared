AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.SwapAnims = false

function SWEP:SetClimbing(climbing)
	self:SetDTBool(0, climbing)
end

function SWEP:SetSwinging(swinging)
	self:SetDTBool(1, swinging)
end

function SWEP:SetPounceTime(leaping)
	self:SetDTFloat(0, leaping)
end

function SWEP:SetNextSwing(time)
	self:SetDTFloat(1, time)
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	owner:DrawViewModel(true)
	owner:DrawWorldModel(false)
	owner:StopLoopingSound(owner:StartLoopingSound("npc/fast_zombie/gurgle_loop1.wav"))
	self:SetPounceTime(0)
	self:SetNextSwing(0)
	self:SendWeaponAnim(ACT_VM_DRAW)
	timer.Simple(0.5, function()
		if self.Alive then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end 
	end )
end

SWEP.Alive = true
SWEP.Scream = false
SWEP.ScreamDuration = CurTime() + SoundDuration("npc/fast_zombie/fz_frenzy1.wav")

function SWEP:Think()
	local owner = self:GetOwner()

	if self:GetClimbing() and CurTime() >= self.NextClimb then
		self:SetClimbing(false)
	end

	if self:GetPounceTime() > 0 and CurTime() >= self:GetPounceTime() then
		self:SetPounceTime(0)
	end

	if IsValid(owner) then 
		self.Alive = true
	else
		self.Alive = false
	end

	if not self.Alive then 
		owner:StopSound("npc/fast_zombie/gurgle_loop1.wav")
	end

	if self:GetSwinging() then
		self.Scream = true
		owner:StartLoopingSound("npc/fast_zombie/gurgle_loop1.wav")
	else
		owner:StopSound("npc/fast_zombie/gurgle_loop1.wav")
		if self.Scream then
			if self.ScreamDuration <= CurTime() then
				owner:EmitSound("npc/fast_zombie/fz_frenzy1.wav")
				self.ScreamDuration = CurTime() + SoundDuration("npc/fast_zombie/fz_frenzy1.wav")
			end
			self.Scream = false
		end
	end

	if self.Leaping then
		if owner:OnGround() or owner:WaterLevel() > 0 then
			self.Leaping = false
			self:SetPounceTime(CurTime() + 1)
			--owner:SetViewOffset(self.OriginalViewOffset)
		else
			local trace, ent = owner:CalcMeleeHit(self.MeleeHitDetection)

			if ent:IsValid() then
				if ent:GetClass() == "func_breakable_surf" then
					ent:Fire("break", "", 0)
				else
					local phys = ent:GetPhysicsObject()
					if ent:IsPlayer() then
						local vel = owner:EyeAngles():Forward() * 650
						vel.z = 150
						ent:SetVelocity(vel)
						ent:ViewPunch(Angle(math.random(0, 80), math.random(0, 80), math.random(0, 80)))
					elseif phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
						local vel = owner:GetAimVector() * 1000

						phys:ApplyForceOffset(vel, (owner:TraceLine(65).HitPos + ent:GetPos()) / 2)
						ent:SetPhysicsAttacker(owner)
					end
				end
				self.Leaping = false
				self:SetPounceTime(CurTime() + 1.5)
				--owner:SetViewOffset(self.OriginalViewOffset)
				owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
				owner:ViewPunch(Angle(math.random(0, 70), math.random(0, 70), math.random(0, 70)))
			elseif trace.HitWorld then
				owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
				self.Leaping = false
				self:SetPounceTime(CurTime() + 1.5)
				--owner:SetViewOffset(self.OriginalViewOffset)
			end
		end
	end

	if not self:GetSwinging() then return end
	if CurTime() < self:GetNextSwing() then return end
	self:SendWeaponAnim(ACT_VM_IDLE)
	if not owner:KeyDown(IN_ATTACK) then
		self:SetSwinging(false)
		GAMEMODE:SetPlayerSpeed(owner, ZombieClasses[owner:GetZombieClass()].Speed)
		return
	end

	local trace, ent = owner:CalcMeleeHit(self.MeleeHitDetection)

	local damage = 5 + 5 * math.min(GetZombieFocus(owner:GetPos(), 300, 0.001, 0) - 0.3, 1)

	if ent:IsValid() then
		if ent:GetClass() == "func_breakable_surf" then
			ent:Fire("break", "", 0)
		else
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
				local vel = damage * 600 * owner:EyeAngles():Forward()

				phys:ApplyForceOffset(vel, (ent:NearestPoint(owner:GetShootPos()) + ent:GetPos() * 2) / 3)
				ent:SetPhysicsAttacker(owner)
			end
			owner:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 80, math.random(105, 145))
			ent:TakeDamage(damage, owner)
		end
	end

 	if trace.HitWorld or ent:IsValid() then
		owner:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 80, math.random(105, 145))
	else
		owner:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 80, math.random(105, 145))
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	if self.SwapAnims then 
		self:SendWeaponAnim(ACT_VM_HITLEFT) 
	else 
		self:SendWeaponAnim(ACT_VM_HITRIGHT) 
	end
	self.SwapAnims = not self.SwapAnims
	self:SetNextSwing(CurTime() + self.Primary.Delay)
	owner:Fire("IgnoreFallDamage", "", 0)
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if self:GetSwinging() and not owner:HasGodMode() then
		GAMEMODE:SetPlayerSpeed(owner, ZombieClasses[owner:GetZombieClass()].Speed * 0.5)
	end
	if self:GetSwinging() or self.Leaping then return end
	self:SetNextSwing(CurTime())
	self:SetSwinging(true)
end

SWEP.NextClimb = 0
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if self.Leaping or self:GetSwinging() then return end
	local onground = owner:OnGround()
	if onground and not self:GetClimbing() and CurTime() >= self:GetPounceTime() then 
		self:SendWeaponAnim(ACT_VM_THROW)
		timer.Simple(0.5, function()
			if self.Alive then 
				self:SendWeaponAnim(ACT_VM_IDLE)
			end 
		end )
	end
	if CurTime() >= self.NextClimb and not onground then
		local vStart = owner:GetShootPos()
		local aimvec = owner:GetAimVector() aimvec.z = 0
		local tr = {}
		tr.start = vStart
		tr.endpos = vStart + (aimvec * 35)
		tr.filter = owner
		local Hit = util.TraceLine(tr).Hit
		tr.start = tr.endpos
		tr.endpos = tr.endpos + Vector(0,0,-52)
		local Hit2 = util.TraceLine(tr).Hit
		if Hit or Hit2 then
			owner:SetLocalVelocity(Vector(0,0,200))
			owner:SetAnimation(PLAYER_SUPERJUMP)
			self.NextClimb = CurTime() + self.Secondary.Delay
			self:SetClimbing(true)
			owner:EmitSound("player/footsteps/metalgrate"..math.random(1,4)..".wav")
			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			timer.Simple(0.5, function() 
				if self.Alive and self:GetClimbing() then return end
				if self.Alive then 
					self:SendWeaponAnim(ACT_VM_IDLE)
				end 
			end )
			return
		end
	end

	if CurTime() < self:GetPounceTime() then return end
	if not onground then return end

	local vel = owner:GetAngles():Forward() * 800

	if vel.z < 200 then vel.z = 200 end

	local eyeangles = owner:GetAngles():Forward()
	eyeangles.pitch = -0.15
	eyeangles.z = -0.1

	local ang = owner:GetAimVector() ang.z = 0

	--self.OriginalViewOffset = owner:GetViewOffset()

	--owner:SetViewOffset(ang * 85)
	owner:SetAngles(Angle(0,0,7))
	owner:SetGroundEntity(NULL)
	owner:SetLocalVelocity(vel)
	self.Leaping = true
	owner:EmitSound("npc/fast_zombie/fz_scream1.wav")
	owner:Fire("IgnoreFallDamage", "", 0)
end
