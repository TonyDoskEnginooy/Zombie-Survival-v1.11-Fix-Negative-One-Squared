SWEP.Base = "weapon_zs_base_enemy"

SWEP.ViewModel = "models/Weapons/v_zombiearms.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Delay = 1.5

SWEP.YellTime = 8

SWEP.MeleeHitDetection = {
	traceStartGet = "GetShootPos",
	traceEndGetNormal = "GetAimVector",
	traceEndDistance = 85,
	traceEndExtraHeight = 0,
	traceMask = MASK_SHOT,
	hitScanHeight = 55,
	hitScanRadius = 5,
	upZThreshold = 0.8,
	upZHeight = 20,
	upZaimDistance = 5,
	downZThreshold = -0.85,
	downZHeight = 45,
	downZaimDistance = 5,
	midZHeight = 0,
	midZaimDistance = 13
}

function SWEP:Precache()
	util.PrecacheSound("npc/zombine/zombine_idle1.wav")
	util.PrecacheSound("npc/zombine/zombine_idle2.wav")
	util.PrecacheSound("npc/zombine/zombine_idle3.wav")
	util.PrecacheSound("npc/zombine/zombine_idle4.wav")
	util.PrecacheSound("npc/zombie/claw_strike1.wav")
	util.PrecacheSound("npc/zombie/claw_strike2.wav")
	util.PrecacheSound("npc/zombie/claw_strike3.wav")
	util.PrecacheSound("npc/zombie/claw_miss1.wav")
	util.PrecacheSound("npc/zombie/claw_miss2.wav")
	util.PrecacheSound("npc/zombine/zombine_charge1.wav")
	util.PrecacheSound("npc/zombine/zombine_die1.wav")
	util.PrecacheSound("npc/zombine/zombine_die2.wav")
	util.PrecacheSound("npc/zombine/zombine_alert1.wav")
	util.PrecacheSound("npc/zombine/zombine_alert2.wav")
	util.PrecacheSound("npc/zombine/zombine_alert3.wav")
	util.PrecacheSound("npc/zombine/zombine_alert4.wav")
	util.PrecacheSound("npc/zombine/zombine_alert5.wav")
	util.PrecacheSound("npc/zombine/zombine_alert6.wav")
	util.PrecacheSound("npc/zombine/zombine_alert7.wav")
end

function SWEP:GetNextSwing()
	return self:GetDTFloat(0)
end

function SWEP:GetGrenading()
	return self:GetDTBool(1)
end