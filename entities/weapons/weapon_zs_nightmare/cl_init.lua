include("shared.lua")

SWEP.PrintName = "Nightmare"

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
	vm:SetColor(Color(0, 0, 0))
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	vm:SetColor(Color(0, 0, 0))
end