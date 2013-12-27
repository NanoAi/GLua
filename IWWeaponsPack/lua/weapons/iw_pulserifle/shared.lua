
if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Pulse Rifle"			
	SWEP.Slot = 2
	SWEP.SlotPos = 7
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.IconLetter = "2"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_pulserifle", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Instructions = "High-power energy based weapon. Consumes suit power!" 

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_IRifle.mdl"
SWEP.WorldModel			= "models/weapons/w_IRifle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_AR2.Single")
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Unrecoil		= 8
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1.5
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ConeMoving		= 0.1
SWEP.Primary.ConeCrouching	= 0.03

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.MuzzleEffect			= "rg_muzzle_rifle"

--SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
--SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

SWEP.Drain = 3

function SWEP:zapEffect(target)
	if !target or !IsValid(target) then return end
	local effectdata = EffectData()
	effectdata:SetStart(target:GetShootPos())
	effectdata:SetOrigin(target:GetShootPos())
	effectdata:SetScale(1)
	effectdata:SetMagnitude(1)
	effectdata:SetScale(3)
	effectdata:SetRadius(1)
	effectdata:SetColor(-65536)
	effectdata:SetEntity(target)
	for i = 1, 100 do timer.Simple(1/i, function() util.Effect("TeslaHitBoxes", effectdata, true, true) end) end
	local Zap = math.random(1,9)
	if Zap == 4 then Zap = 3 end
	target:EmitSound("ambient/energy/zap"..Zap..".wav")
end

function SWEP:BulletCallback( ply, target )
	if( self.Owner != ply ) then ply = self.Owner end
	if not IsValid(target) or not IsValid(ply) then return end
	if not target:IsPlayer() and not target:IsFrozen() then return end
	
	self:zapEffect(target)
	
	if( SERVER ) then
		if( IsValid(target) and target:IsPlayer() and !target:IsFrozen() ) then -- Paranoid.
			target:ViewPunch( Angle( -10, 0, 0 ) )
			target:ScreenFade( 1, Color(203,250,248), 0.3, 0.1)
			target:Freeze(true)
			timer.Simple(3, function() target:Freeze(false) end)
		end
		ply:SetHealth(ply:Health()-self.Drain)
	end
end

function SWEP:ShootBullet(dmg, numbul, cone)
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.Force = dmg * 0.5
	bullet.Damage = dmg
	bullet.TracerName = self.Tracer
	bullet.Callback = function ( ply, tr )
		self.Weapon:BulletCallback( ply, tr.Entity )
	end

	self.Owner:FireBullets(bullet)
	self:ShootEffects()
end

function SWEP:PrimaryAttack()

	local ply = self.Owner
	local target = self.Owner:GetEyeTrace().Entity

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if not self:CanPrimaryAttack() then return end
	if self.Owner:Health() < self.Drain*2 then return end

	self.Weapon:EmitSound(self.Primary.Sound)
	
	self:FireIWBullet()
	
	ply:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))

	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

SWEP.fired = false

function SWEP:Think()
	
	local ply = self.Owner

	-- Show reload animation when player stops firing. Looks cool.
	if ply:KeyDown(IN_ATTACK) then	
		self.fired = true
	elseif self.fired then 
		self.fired = false
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	end
end

function SWEP:CanPrimaryAttack()

	local ply = self.Owner
	if ply:Health() <= self.Drain then
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end
	return true
end

function SWEP:SecondaryAttack()
	if( !self.ZoomedIn ) then
		if SERVER then self.Owner:SetFOV( 45, 0.3 ) end
		self.ZoomedIn = true
	else
		if SERVER then self.Owner:SetFOV( 0, 0.3 ) end
		self.ZoomedIn = false
	end
end

function SWEP:CanSecondaryAttack()
	return true
end

