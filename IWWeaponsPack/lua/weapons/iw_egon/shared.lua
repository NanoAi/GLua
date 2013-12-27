SWEP.Author			= "" -- Dark Moule/Team Garry
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "High-power energy based weapon. Consumes life force!"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false	
SWEP.PrintName			= "Egon beamcannon"			
SWEP.Slot				= 2
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_superphyscannon.mdl"
SWEP.WorldModel			= "models/weapons/w_physics.mdl"

SWEP.Primary.Automatic = false
SWEP.Primary.Recoil			= 1
SWEP.Primary.Unrecoil		= 1
SWEP.Primary.Damage			= 7
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0
SWEP.Primary.ConeMoving		= 0
SWEP.Primary.ConeCrouching	= 0

local sndPowerUp		= Sound("Airboat.FireGunHeavy")
local sndAttackLoop 	= Sound("Airboat_fan_idle")
local sndPowerDown		= Sound("Town.d1_town_02a_spindown")

SWEP.Drain = 8
SWEP.DrainDelta = 0.25
SWEP.DrainTimer = 0
SWEP.CanAttack = true
SWEP.PrimFireDelay = 0.5
SWEP.NextPrimFire = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( "shotgun" )
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW) 
	if SERVER then
		self.Owner:DrawWorldModel(true)
		self.Owner:DrawViewModel(true)
	end

	local vm = self.Owner:GetViewModel()
	if vm and vm:IsValid() then
		-- vm:SetColor(255, 255, 255, 255)
		vm:SetMaterial("")	
	end
	
	return true
end

function SWEP:Think()

	if (!self.Owner || self.Owner == NULL) then return end
	
	if self.NextPrimFire < CurTime() then
	
		if ( self.Owner:KeyDown( IN_ATTACK ) and self.Owner:Health() >= self.Drain ) then

			if self.CanAttack then
				self:UpdateAttack()
			end
			
		elseif ( self.Owner:KeyReleased( IN_ATTACK ) or self.Owner:Health() < self.Drain ) then

			if self.CanAttack then
				self.CanAttack = false
				self.NextPrimFire = CurTime()+self.PrimFireDelay
				self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self:EndAttack( true )
			end

		end
		
	end

end



function SWEP:StartAttack()

	self.Weapon:EmitSound( sndPowerUp )
	self.Weapon:EmitSound( sndAttackLoop )
	
	if (SERVER) then
		
		if (!self.Beam) then
			self.Beam = ents.Create( "egon_beam" )
			if IsValid(self.Beam) then
				self.Beam:SetPos( self.Owner:GetShootPos() )
				self.Beam:Spawn()
			end
		end
		
		self.Beam:SetParent( self.Owner )
		self.Beam:SetOwner( self.Owner )
	
	end

	self:UpdateAttack()

end

function SWEP:UpdateAttack()
	
	if ( self.Timer && self.Timer > CurTime() ) then return end
	
	self.Timer = CurTime() + 0.05
	
	if SERVER and self.DrainTimer < CurTime() then
		self.Owner:SetHealth(self.Owner:Health()-self.Drain)
		self.DrainTimer = CurTime()+self.DrainDelta			
	end
	
	if self.Owner:Health() < self.Drain then return end
	
	// We lag compensate here. This moves all the players back to the spots where they were
	// when this player fired the gun (a ping time ago).
	self.Owner:LagCompensation( true )
	
	local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = trace.start + (self.Owner:GetAimVector() * 4096)
		trace.filter = { self.Owner, self.Weapon }
		
	local tr = util.TraceLine( trace )
	
	if (SERVER && self.Beam) then
		self.Beam:GetTable():SetEndPos( tr.HitPos )
	end

    if( SERVER ) then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage( self.Primary.Damage )
        dmginfo:SetDamageType( DMG_DISSOLVE )
        dmginfo:SetInflictor( self.Weapon )
        dmginfo:SetAttacker( self.Owner )
        for _,dmgent in pairs(ents.FindInSphere(tr.HitPos, 40)) do
            if( dmgent and dmgent:IsValid() ) then
                dmgent:TakeDamageInfo( dmginfo )
            end
        end
    end
    
    local eyetrace = self.Owner:GetEyeTrace()
    local EffectFire = EffectData()
    EffectFire:SetOrigin( eyetrace.HitPos )
    EffectFire:SetStart( eyetrace.HitPos )
    EffectFire:SetMagnitude(575)
    EffectFire:SetScale(0.5)
    util.Effect("cball_explode", EffectFire)
    
	if ( tr.Entity && tr.Entity:IsPlayer() ) then
        
        if( tr.Entity:IsPlayer() ) then
            local effectdata = EffectData()
                effectdata:SetEntity( tr.Entity )
                effectdata:SetOrigin( tr.HitPos )
                effectdata:SetNormal( tr.HitNormal )
            util.Effect( "bodyshot", effectdata )
        end
	
	end
	
	self.Owner:LagCompensation( false )
	
end

function SWEP:EndAttack( shutdownsound )
	
	self.Weapon:StopSound( sndAttackLoop )
	self.Weapon:StopSound( sndPowerUp )
	
	if ( shutdownsound ) then
		self.Weapon:EmitSound( sndPowerDown )
	end
	
	if ( CLIENT ) then return end
	if ( !IsValid(self.Beam) ) then return end
	
	self.Beam:Remove()
	self.Beam = nil
	
end

function SWEP:Holster()
	self:EndAttack( false )
	return true
end

function SWEP:OnRemove()
	self:EndAttack( false )
	return true
end


function SWEP:PrimaryAttack()
	if self.Owner:Health() >= self.Drain*2 and self.NextPrimFire < CurTime() then
		self.CanAttack = true
		self:StartAttack()
	end
end

function SWEP:SecondaryAttack()
end

