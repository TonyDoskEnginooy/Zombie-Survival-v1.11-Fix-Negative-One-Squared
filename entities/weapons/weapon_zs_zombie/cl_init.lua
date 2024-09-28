include("shared.lua")

SWEP.PrintName = "Zombie"

function SWEP:PreDrawViewModel(vm, weapon, ply)
	vm:SetColor(Color(255, 255, 255))
	if ply:IsValid() then
		if ply:GetColor() == Color(255, 255, 255, 50) then
			render.SetBlend(0.2)
		else
			render.SetBlend(1)
		end
	end
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	vm:SetColor(Color(255, 255, 255))
	if ply:IsValid() then
		if ply:GetColor() == Color(255, 255, 255, 50) then
			render.SetBlend(0.2)
		else
			render.SetBlend(1)
		end
	end
end