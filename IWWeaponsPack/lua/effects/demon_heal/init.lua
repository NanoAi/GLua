

function EFFECT:Init(data)
	
	local emitter = ParticleEmitter( data:GetOrigin() )
	
	for k = 1, 10 do
		if data:GetOrigin() then
			local spawnPos = data:GetOrigin() -- +((math.random(0,25)/math.random(1,2))*(Vector(math.Rand(-1,1),math.Rand(-1,1),0):Normalize()))
			if emitter then -- make sure that the emitter was created
				local particle = emitter:Add( "particle/fire", spawnPos )
				particle:SetVelocity( Vector(0,0,15+math.random(0,10)) )
				particle:SetDieTime( 0.7 + math.Rand(0,0.5) )
				particle:SetStartAlpha( math.Rand( 100, 150 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 5, 10 ) )
				particle:SetEndSize( math.Rand( 5, 10 ) )
				particle:SetRoll( math.Rand( -0.2, 0.2 ) )
				local ran = math.random(0,20)
				particle:SetColor( 255, 20+ran, 20+ran )
			end
		end
	end
	
	emitter:Finish()
end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()

	
end



