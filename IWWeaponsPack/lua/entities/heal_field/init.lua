include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetNotSolid(true)	
	self.Entity:DrawShadow( false )
	
	self.nextheal = 0
	
	timer.Simple(5,function(ent)
		if IsValid(ent) then
			ent:Remove()
		end
	end,self.Entity)
end	

function ENT:Think()
	if self.nextheal < CurTime() then

		local players = ents.FindInSphere(self.Entity:GetPos(), 150)
		for k, pl in pairs(players) do
			if pl:IsPlayer() and pl:Alive() then
				local hpplus = 10
				
				if hpplus > 0 then
					pl:SetHealth(math.min(150,pl:Health()+hpplus))
					
					local eff = EffectData()
					eff:SetOrigin(pl:GetPos())
					util.Effect( "demon_heal", eff )
				end
			end
		end
		self.nextheal = CurTime() + 2
	end
end

function ENT:OnRemove()
end
