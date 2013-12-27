

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local Normal = data:GetNormal()
	
	if not EFFECT_UBERGORE then return end
	
	for i= 0, 20 do
	
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos + i * Vector(0,0,3) + VectorRand() * 5 )
			effectdata:SetNormal( Normal )
		util.Effect( "gore_bloodprop", effectdata )
		
	end
	
	// Spawn Gibs
	for i = 0, 18 do
	
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos + i * Vector(0,0,6) + VectorRand() * 8 )
			effectdata:SetNormal( Normal )
		util.Effect( "gib", effectdata )
		
	end
	
	self.Emitter = ParticleEmitter(self.Entity:GetPos())

	for i=1, 30 do
		local particle = self.Emitter:Add("effects/blood_core", Pos-Vector(0,0,20)+Vector(0,0,4)*i+VectorRand()*6)
		particle:SetVelocity(VectorRand()+Vector(0,0,-10)*math.Rand(0.1,1))
		particle:SetDieTime(math.Rand(4,6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.random(40,60))
		particle:SetEndSize(math.random(30,50))
		particle:SetRoll(math.Rand(0,3))
		particle:SetRollDelta(math.Rand(0,0.5))
		particle:SetColor(math.random(200,255), 0, 0)
		particle:SetLighting(true)
	end
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	// Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



