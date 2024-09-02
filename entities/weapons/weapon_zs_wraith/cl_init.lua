include("shared.lua")

SWEP.PrintName = "Wraith"
SWEP.ViewModelFOV = 40

function SWEP:Holster()
	local vm = LocalPlayer():GetViewModel()

	timer.Simple(0.1, function() -- This avoids the last Think() overriding reder mode and colors here
		if vm and vm:IsValid() then
			vm:SetRenderMode(RENDERMODE_NORMAL)
			vm:SetColor(Color(255, 255, 255, 255))
		end		
	end)
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
	vm:SetRenderMode(RENDERMODE_TRANSCOLOR)
	vm:SetColor(Color(20, 20, 20))
	if IsValid(ply) and not ply:HasGodMode() then
		if ply:GetMaxSpeed() ~= 1 then 
			render.SetBlend( ( ( math.max(15, math.min(ply:GetVelocity():Length(), 200)) ) * 0.01 ) / 2 )
		else
			render.SetBlend(1)
		end
	end
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	vm:SetRenderMode(RENDERMODE_TRANSCOLOR)
	vm:SetColor(Color(20, 20, 20))
	if IsValid(ply) and not ply:HasGodMode() then
		if ply:GetMaxSpeed() ~= 1 then 
			render.SetBlend( ( ( math.max(15, math.min(ply:GetVelocity():Length(), 200)) ) * 0.01 ) / 2 )
		else
			render.SetBlend(1)
		end
	end
end
