ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.Spawnable 		= true
ENT.AdminOnly		= true

ENT.PrintName 		= "Custom Decal Placement"
ENT.Author 			= "LuaTenshi"
ENT.Information		= "Display images on your server!"
ENT.Category 		= "Editors"

function ENT:SetupDataTables()
	self:NetworkVar("Entity",1,"owning_ent")
end