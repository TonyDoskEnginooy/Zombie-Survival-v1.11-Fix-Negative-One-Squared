-- WIP

function CLASS.CalcMainActivity(ply, velocity)
	local wep = ply:GetActiveWeapon()
	--[[if wep.GetNextSwing and CurTime() < wep:GetNextSwing() - 0.1 then
		return 1, ply:LookupSequence("FastAttack")
	end]]

	if ply:HasGodMode() then 
		if velocity:Length2DSqr() <= 1 then
			return ACT_IDLE, -1
		else
			if velocity:Length2DSqr() <= 30625 then
				return ACT_WALK, -1
			else
				return ACT_RUN, -1
			end
		end
	end

	if ply:GetMaxSpeed() == 1 then
		return 1, ply:LookupSequence("pullGrenade")
	end

	if ply:GetMaxSpeed() == 150 or wep:GetGrenading() == false then 
		if velocity:Length2DSqr() <= 1 then
			return ACT_IDLE, -1
		else
			if velocity:Length2DSqr() <= 30625 then
				return ACT_WALK, -1
			else
				return ACT_RUN, -1
			end
		end
	elseif ply:GetMaxSpeed() == 200 or wep:GetGrenading() == true then 
		if velocity:Length2DSqr() <= 1 then
			return 1, ply:LookupSequence("Idle_Grenade")
		else
			if velocity:Length2DSqr() <= 30625 then
				return 1, ply:LookupSequence("walk_All_grenade")
			else
				return 1, ply:LookupSequence("Run_All_grenade")
			end
		end
	end
end

function CLASS.UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
	local wep = ply:GetActiveWeapon()
	if len2d > 1 then
		ply:SetPlaybackRate(math.min(len2d / maxseqgroundspeed, 1.5))
	else
		ply:SetPlaybackRate(1)
	end

	return true
end

function CLASS.DoAnimationEvent(ply, event, data)
    if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK2, true)
		return ACT_INVALID
	end
end