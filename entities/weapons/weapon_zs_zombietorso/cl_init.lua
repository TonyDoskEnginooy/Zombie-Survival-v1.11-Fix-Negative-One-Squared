include("shared.lua")

SWEP.PrintName = "Zombie Torso"
SWEP.ViewModelFOV = 90

-- Custom view model position - Xala
function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)
    local newPos = pos + Vector(0, 0, -35)
    local newAng = ang

    return newPos, newAng
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    vm:SetRenderMode(RENDERMODE_NORMAL)
    vm:SetColor(Color(255, 255, 255))
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    vm:SetRenderMode(RENDERMODE_NORMAL)
    vm:SetColor(Color(255, 255, 255))
end