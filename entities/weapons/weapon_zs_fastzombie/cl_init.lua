include("shared.lua")

SWEP.PrintName = "Fast Zombie"

function SWEP:PreDrawViewModel(vm, weapon, ply)
	vm:SetRenderMode(RENDERMODE_NORMAL)
	vm:SetColor(Color(255, 255, 255))
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	vm:SetRenderMode(RENDERMODE_NORMAL)
	vm:SetColor(Color(255, 255, 255))
end