
if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Vaporizer Rifle"			
	SWEP.Slot = 2
	SWEP.SlotPos = 7
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.IconLetter = "8"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_vaporizer", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Instructions = "Extreme power, dissolves enemies. Consumes suit power quick!" 

SWEP.Base				= "iw_rifle_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_IRifle.mdl"
SWEP.WorldModel			= "models/weapons/w_IRifle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/gauss/fire1.wav")
SWEP.Primary.Recoil			= 16
SWEP.Primary.Unrecoil		= 6
SWEP.Primary.Damage			= 1 -- The damage is under a var called TrueDamage
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 5
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0.022
SWEP.Primary.ConeMoving		= 0.08
SWEP.Primary.ConeCrouching	= 0.014

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.MuzzleEffect			= "rg_muzzle_rifle"

-- SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
-- SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

SWEP.Drain = 40
SWEP.Primary.TrueDamage = 40 -- The Base Damage Of The Gun.

function SWEP:ShootBullet(dmg, numbul, cone)
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.Force = 0
	bullet.Damage = dmg
	bullet.TracerName = "AR2Tracer"
    
	-- Dissolve entity
	bullet.Callback = function ( attacker, tr, dmginfo ) 
		local ent = tr.Entity
        local eyetrace = self.Owner:GetEyeTrace()
        if( ent:IsValid() and not( ent:IsPlayer() or ent:IsNPC() ) ) then
            local EffectFire = EffectData()
            EffectFire:SetOrigin( eyetrace.HitPos )
            EffectFire:SetStart( eyetrace.HitPos )
            EffectFire:SetMagnitude(575)
            EffectFire:SetScale(0.5)
            util.Effect("cball_explode", EffectFire)
        end
        if( ent:IsValid() and SERVER ) then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage( self.Primary.TrueDamage + math.random(5,100) ) -- Min Damage: 45 | Max Damage: 140
            dmginfo:SetDamageType( DMG_DISSOLVE )
            dmginfo:SetInflictor( self.Weapon )
            dmginfo:SetAttacker( self.Owner )
            ent:TakeDamageInfo( dmginfo )
		end
	end
	
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end


