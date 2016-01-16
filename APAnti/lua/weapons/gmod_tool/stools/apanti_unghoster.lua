if CLIENT then
	language.Add( "tool.apanti_unghoster.name", "APAnti UnGhoster")
	language.Add( "tool.apanti_unghoster.desc", "Unghosts Objects Ghosted by APAnti" )
	language.Add( "tool.apanti_unghoster.0", "Primary: UnGhost Single Object | Secondary: UnGhost Contraption | Reload: UnGhost in View" )
end

TOOL.Category = "Construction"
TOOL.Name = "APAnti UnGhoster"
TOOL.Description = "Unghosts Objects Ghosted by APAnti"

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	if not IsValid( trace.Entity ) then return false end
	
	if APA and APA.InitGhost then
		APA.InitGhost( trace.Entity, true, false )
	end
	
	return true
end

function TOOL:RightClick( trace )
	if CLIENT then return true end

	if not IsValid( trace.Entity ) then return false end

	local i = 0
	for _,v in next, constraint.GetAllConstrainedEntities(trace.Entity) do
		i = i + 1
		timer.Simple(i/100, function()
			if IsValid(v) and v.APGhost and APA and APA.InitGhost then
				APA.InitGhost( v, true, false )
			end
		end)
	end

	return true
end

function TOOL:Reload( trace )
	if CLIENT then return true end

	local o = self:GetOwner()
	if APA and APA.InitGhost and APA.FindOwner then
		local i = 0
		for _,v in next, ents.FindInCone(o:GetPos(),o:EyeAngles():Forward(),1000,0) do
			i = i + 1
			if IsValid(v) and v.APGhost then
				if v.GetClass and v:GetClass() == "prop_physics" then
					timer.Simple(i/50, function()
						if APA.FindOwner(v) == o then
							APA.InitGhost( v, true, true )
						end
					end)
				end
			end
		end
		return true
	end
end