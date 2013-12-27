	
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	// HumanGibs is defined in gamemode shared 
	// (because we need to precache the models on the server before we can use the physics)
	local iCount = table.Count( HumanGibs )
	
	// Use a random model from the gibs collection
	self.Entity:SetModel( HumanGibs[ math.random( iCount ) ] )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMaterial( "models/flesh" )
	
	self.Entity.IsGib = true
	
	// Only collide with world/static
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )
	
	// Add Velocity
	local phys = self.Entity:GetPhysicsObject()
	if ( phys && phys:IsValid() ) then
	
		phys:Wake()
		phys:SetAngle( Angle( math.random(0,359), math.random(0,359), math.random(0,359) ) )
		phys:SetVelocity( (data:GetNormal() * 3/8 + VectorRand() * 1/4 + Vector(0,0,math.random(0,3)) * 3/8) *  math.random( 50, 200 ) )
	
	end
	
	// Gib life time
	self.LifeTime = CurTime() + math.Rand(5,15)

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	if not EFFECT_UBERGORE or self.LifeTime < CurTime() then
		return false
	end	
	return true
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
	
	self.Entity:DrawModel()

end



