
include('shared.lua')

local matBeam		 		= Material( "egon/egon_middlebeam" )
local matLight 				= Material( "egon/muzzlelight" )
local matRefraction			= Material( "egon/egon_ringbeam" )
local matRefractRing			= Material( "refract_ring" )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()		

	self.Size = 0

end

function ENT:Think()

	self.Entity:SetRenderBoundsWS( self:GetEndPos(), self.Entity:GetPos(), Vector()*8 )
	
	self.Size = math.Approach( self.Size, 1, 3*FrameTime() )
	
end


function ENT:DrawMainBeam( StartPos, EndPos )

	local TexOffset = CurTime() * -2.0
	
	// Cool Beam
	render.SetMaterial( matBeam )
	render.DrawBeam( StartPos, EndPos, 
					8, 
					TexOffset*-0.4, TexOffset*-0.4 + StartPos:Distance(EndPos) / 256, 
					Color(0,255,0) )
					
	// Refraction Beam
	render.SetMaterial( matRefraction )
	render.UpdateRefractTexture()
	render.DrawBeam( StartPos, EndPos, 
					8, 
					TexOffset*0.5, TexOffset*0.5 + StartPos:Distance(EndPos) / 1024, 
					Color(0,255,0) )	


end

function ENT:DrawCurlyBeam( StartPos, EndPos, Angle )
	return
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()

	local Owner = self.Entity:GetOwner()
	if (!Owner || Owner == NULL) then return end

	local StartPos 		= self.Entity:GetPos()
	local EndPos 		= self:GetEndPos()
	local ViewModel 	= Owner == LocalPlayer()
	
	local trace = {}
	
	local Angle = Owner:EyeAngles()
	
	// If it's the local player we start at the viewmodel
	if ( ViewModel ) then
	
		local vm = Owner:GetViewModel()
		if (!vm || vm == NULL) then return end
		local attachment = vm:GetAttachment( 1 )
		StartPos = attachment.Pos
		
		trace.start = Owner:EyePos()
	
	else
	// If we're viewing another player we start at their weapon
	
		local vm = Owner:GetActiveWeapon()
		if (!vm || vm == NULL) then return end
		local attachment = vm:GetAttachment( 1 )
		StartPos = attachment.Pos
		
		trace.start = StartPos
	
	end
	
	// Predict the endpoint, smoother, faster, harder, stronger
	
		trace.endpos = trace.start + (Owner:EyeAngles():Forward() * 4096)
		trace.filter = { Owner, Owner:GetActiveWeapon() }
			
		local tr = util.TraceLine( trace )
		
		EndPos = tr.HitPos
		
	
	// offset the texture coords so it looks like it's scrolling
	local TexOffset = CurTime() * -2
	
	// Make the texture coords relative to distance so they're always a nice size
	local Distance = EndPos:Distance( StartPos ) * self.Size
	
	
	Angle = (EndPos - StartPos):Angle()
	local Normal 	= Angle:Forward()
	
	render.SetMaterial( matLight )
	render.DrawQuadEasy( EndPos + tr.HitNormal, tr.HitNormal, 8 * self.Size, 16 * self.Size, Color(255, 255, 0) )
	render.DrawQuadEasy( EndPos + tr.HitNormal, tr.HitNormal, math.Rand(8, 32) * self.Size, math.Rand(8, 32) * self.Size, Color(255, 255, 0) )
	render.DrawSprite( EndPos + tr.HitNormal, 8, 16, Color( 150, 255, 150, self.Size * 255 ) )
	
	// Draw the beam
	self:DrawMainBeam( StartPos, StartPos + Normal * Distance )

	 
end

/*---------------------------------------------------------
   Name: IsTranslucent
---------------------------------------------------------*/
function ENT:IsTranslucent()
	return true
end
