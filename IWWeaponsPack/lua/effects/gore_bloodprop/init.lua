
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	self.Velocity = (data:GetNormal() * 3/6 + VectorRand() * 1/3 + Vector(0,0,math.random(0,3)) * 1/6) *  math.random( 500, 700 )
	self.Gravity = 700

	// Gib life time
	self.LifeTime = CurTime() + math.Rand(3,5)

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	if not EFFECT_UBERGORE or self.LifeTime < CurTime() then
		return false
	end	
	
	self.Entity:SetPos(self.Entity:GetPos()+self.Velocity*FrameTime())
	self.Velocity.z = self.Velocity.z-self.Gravity*FrameTime()
	
	local trace = {}
	trace.start 	= self.Entity:GetPos()
	trace.endpos 	= self.Entity:GetPos()+self.Velocity*FrameTime()
	trace.mask 		= MASK_NPCWORLDSTATIC
	local tr = util.TraceLine( trace )

	if (tr.Hit) then
		tr.HitPos:Add( tr.HitNormal * 2 )
		
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal )
		util.Effect( "bloodsplash", effectdata )
		
		return false
	end

	return true
end

EFFECT.NextParticle = 0
/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	if not self.Emitter then
		self.Emitter = ParticleEmitter(self.Entity:GetPos())
	end

	if (self.NextParticle < CurTime()) then
		self.NextParticle = CurTime()+0.008+0.01*math.Rand(0,1)
		local particle = self.Emitter:Add("effects/blood_core", self.Entity:GetPos()+VectorRand()*2)
		particle:SetVelocity(self.Velocity:GetNormal()*math.Rand(2,4)+VectorRand()*0.3)
		particle:SetDieTime(math.Rand(0.8,1.1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.random(18,30))
		particle:SetEndSize(math.random(12,16))
		particle:SetRoll(math.Rand(0,3))
		particle:SetRollDelta(math.Rand(0,0.5))
		particle:SetColor(math.random(200,255), 0, 0)
		particle:SetLighting(true)
	end
	
end



