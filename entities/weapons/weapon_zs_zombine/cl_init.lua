include("shared.lua")

SWEP.PrintName = "Zombine"
SWEP.ViewModelFOV = 50

hook.Add("PlayerBindPress", "DisableJump", function(ply, bind, pressed)
    if ply:GetZombieClass() == 10 and ply:GetMaxSpeed() == 1 and bind == "+jump" then
        return true
    end
end)