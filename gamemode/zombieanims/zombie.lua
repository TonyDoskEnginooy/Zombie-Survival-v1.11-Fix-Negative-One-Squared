function CLASS.CalcMainActivity(ply, velocity)
	local wep = ply:GetActiveWeapon()
	if wep.GetNextYell and CurTime() < wep:GetNextYell() and not ply:Crouching() then
		return ACT_HL2MP_RUN_ZOMBIE, -1
	end

	if ply:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	if ply:Crouching() then
		if velocity:Length2DSqr() <= 1 then
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		else
			return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01, -1
		end
	end

	if velocity:Length2DSqr() <= 1 then
		return ACT_HL2MP_IDLE_ZOMBIE, -1
	end

	if ply:Crouching() and ply:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math.ceil((CurTime() / 4 + ply:EntIndex()) % 3), -1
	end

	return ACT_HL2MP_WALK_ZOMBIE_01 - 1 + math.ceil((CurTime() / 3 + ply:EntIndex()) % 3), -1
end

function CLASS.UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
	if len2d > 1 then
		ply:SetPlaybackRate(math.min(len2d / maxseqgroundspeed * 0.666, 1.5))
	else
		ply:SetPlaybackRate(1)
	end

	return true
end

function CLASS.DoAnimationEvent(ply, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		ply:DoZombieAttackAnim(data)
		return ACT_INVALID
	end
end