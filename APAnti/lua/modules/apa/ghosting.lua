if not APA.hasCPPI then return false end -- Must Have CPPI

local table = table
local isPlayer = APA.isPlayer
local has = APA.Settings

local function IsTrap(ent)
	local mins, maxs, check = ent:OBBMins(), ent:OBBMaxs(), false
	
	local tr = {
		start = ent:LocalToWorld(mins), 
		endpos = ent:LocalToWorld(maxs), 
		filter = ent
	}

	local trace = util.TraceLine(tr)
	check = isPlayer(trace.Entity) and trace.Entity or false

	if check then return check end

	local pos = ent and ent:GetPos()
	tr = {
		start = pos, 
		endpos = pos, 
		filter = ent, 
		mins = ent:OBBMins(), 
		maxs = ent:OBBMaxs()
	}

	trace = util.TraceHull(tr)
	check = isPlayer(trace.Entity) and trace.Entity or false

	if check then return check end

	local cube = ents.FindInBox( ent:LocalToWorld(mins), ent:LocalToWorld(maxs) )

	for _,v in pairs(cube) do
		if isPlayer(v) or (v.IsNPC and v:IsNPC()) or (v.IsBot and v:IsBot()) then
			if not ent.APAIsObscured then
				ent.APAIsObscured = v
				break
			end
		end
	end

	ent.APAIsObscured = ent.APAIsObscured or check or false
	return ent.APAIsObscured
end

function APA.CheckGhost( ent )
	local owner = APA.FindOwner(ent)
	if ent.GetVelocity and ent:GetVelocity():Distance( Vector( 0.01, 0.01, 0.01 ) ) > 0.15 then 
		if has.AntiPush:GetBool() and not has.UnGhostPassive:GetBool() then APA.Notify(owner, "Cannot UnGhost: Prop still moving!", NOTIFY_ERROR, 0.5, 0) end
		return false 
	end
	local trap = IsTrap(ent)
	if trap then
		if has.AntiPush:GetBool() then APA.Notify(owner, "Cannot UnGhost: Prop Obstructed! (See Console)", NOTIFY_ERROR, 4, 0, {ent:GetModel(),tostring(trap).."("..trap:GetModel()..")"}) end
		return false 
	end
	return IsValid(ent)
end

function APA.InitGhost( ent, ghostoff, nofreeze, collision )
	if( IsValid(ent) and not APA.IsWorld( ent ) ) then
		local collision = collision and COLLISION_GROUP_WORLD or COLLISION_GROUP_WEAPON
		local unghost = ghostoff and APA.CheckGhost(ent) or false
		local ghostspawn, antipush = has.GhostSpawn:GetBool(), has.AntiPush:GetBool()

		ent.APGhost = has.AntiPush:GetBool() or nil
		ent:DrawShadow(unghost)

		if unghost or (ghostoff and ghostspawn and not antipush) then
			ent:SetRenderMode(RENDERMODE_NORMAL)

			if ent.OldColor then ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a)) end
			ent.OldColor = nil

			if ent.OldCollisionGroup then
				ent:SetCollisionGroup(ent.OldCollisionGroup)
				ent.CollisionGroup = ent.OldCollisionGroup
			end

			if ent.OldMaterial and ent.GetClass and string.find( string.lower(ent:GetClass()), "gmod_" ) or string.find( string.lower(ent:GetClass()), "wire_" ) then
				ent:SetMaterial(ent.OldMaterial[0] or '')
			end
			ent.OldMaterial = nil

			ent.OldCollisionGroup = nil
			ent.APGhost = nil
		elseif antipush or ghostspawn then
			DropEntityIfHeld(ent)

			local oColGroup = ent:GetCollisionGroup()
			ent.OldCollisionGroup = ent.OldCollisionGroup or oColGroup or 0

			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent.OldColor = ent.OldColor or ent:GetColor()
			ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70))

			if ent.GetClass and string.find( string.lower(ent:GetClass()), "gmod_" ) or string.find( string.lower(ent:GetClass()), "wire_" ) then
				ent.OldMaterial = ent.OldMaterial or {ent:GetMaterial()}
				ent:SetMaterial("models/wireframe")
			end

			if not ( oColGroup == COLLISION_GROUP_WEAPON or oColGroup == COLLISION_GROUP_WORLD ) then
				ent:SetCollisionGroup(collision)
				ent.CollisionGroup = collision
			end
		end

		if antipush then
			for _,x in next, constraint.GetAllConstrainedEntities(ent) do
				for _,v in next, x.__APAPhysgunHeld do 
					if v then nofreeze = true break end 
				end
			end

			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local subphys = ent:GetPhysicsObjectNum( i )
				if ( IsValid( subphys ) ) then
					if not nofreeze then subphys:EnableMotion(unghost and subphys:IsMotionEnabled()) end
					subphys:SetVelocity( vector_origin )
					subphys:AddAngleVelocity( subphys:GetAngleVelocity() * -1 )
				end
			end
		end

		ent.APAIsObscured = nil
	end
end

hook.Add( "PhysgunPickup", "APAntiPickup", function(ply,ent)
	if has.AntiPush:GetBool() then
		local puid = tostring(ply:UniqueID())
		for _,v in next, constraint.GetAllConstrainedEntities(ent) do APA.InitGhost(v, false, true) end

		ent.__APAPhysgunHeld = ent.__APAPhysgunHeld or {}
		ent.__APAPhysgunHeld[puid] = true
	end
end)

hook.Add( "PhysgunDrop", "APAntiDrop", function(ply,ent)
	if IsValid(ent) and ent.__APAPhysgunHeld then
		local puid = tostring(ply:UniqueID())
		timer.Simple(1.1, function()
			if IsValid(ent) and ent.__APAPhysgunHeld then
				if table.Count(ent.__APAPhysgunHeld) <= 0 then
					for _,v in next, constraint.GetAllConstrainedEntities(ent) do APA.InitGhost(v, true, false) end
				end
			end
		end)
		ent.__APAPhysgunHeld[puid] = nil
	end
end)

timer.Create("APAUnGhostPassive", 6.5, 0, function()
	if not has.UnGhostPassive:GetBool() then return end
	for _,v in next, table.Add(ents.FindByClass("prop_physics"),ents.FindByClass("gmod_*")) do
		if IsValid(v) then
			for _,v in next, constraint.GetAllConstrainedEntities(v) do
				if table.Count(v.__APAPhysgunHeld or {}) == 0 then
					APA.InitGhost(v, true, false)
				end
			end
		end
	end
end)

APA.initPlugin('ghosting') -- Init Plugin (Must match filename.)