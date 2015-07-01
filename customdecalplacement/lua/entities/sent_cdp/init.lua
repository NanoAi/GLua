AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("cdpSend")
util.AddNetworkString("cdpRecive")

function ENT:Initialize()
	self:SetModel( "models/hunter/plates/plate1x1.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(255,0,0))
	self:SetMaterial("models/wireframe")
	self.phys = self:GetPhysicsObject()
	self.Pickedup = false
	
	self.phys:Wake()
end

function ENT:Think()
	if self.phys and self.phys:IsValid() then
		self.phys:EnableMotion( self:IsPlayerHolding() )
	end
end

function ENT:Use(activator,caller)
	if !self:IsPlayerHolding() then
		net.Start("cdpSend")
		net.WriteEntity(self)
		net.Send(activator)
	end
end

net.Receive("cdpRecive", function()
	local refrence = net.ReadEntity()
	local dimg = net.ReadTable()	dimg.map = game.GetMap()
	local json = util.TableToJSON( dimg )
	if file.Exists( "cdp_PaintLocations.txt", "DATA" ) then
		file.Append( "cdp_PaintLocations.txt", json .. "\n" )
	else
		file.Write( "cdp_PaintLocations.txt", json  .. "\n" )
	end
	refrence:Remove()
end)