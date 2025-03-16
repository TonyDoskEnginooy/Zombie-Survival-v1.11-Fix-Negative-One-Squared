function CLASS.CalcMainActivity(ply, velocity)
	local wep = ply:GetActiveWeapon()
    if ply:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end

		return 1, 1
	end

	if ply:WaterLevel() >= 3 then
		return 1, 9
	end

	if wep:GetLeaping() then 
		return 1, 3
	else
		return 1, 9
	end
end

function CLASS.UpdateAnimation(ply, velocity, maxseqgroundspeed)
    local seq = ply:GetSequence()
	if seq == 3 then
		if not ply.m_PrevFrameCycle then
			ply.m_PrevFrameCycle = true
			ply:SetCycle(0)
		end

		ply:SetPlaybackRate(1)

		return true
	elseif ply.m_PrevFrameCycle then
		ply.m_PrevFrameCycle = nil
	end
end
