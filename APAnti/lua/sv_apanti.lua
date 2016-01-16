local APAWorldEnts = APAWorldEnts or {}
local hook, table = hook, table
local has = APA.Settings

if #APAWorldEnts <= 0 then timer.Simple(0, function() for _,v in next, ents.GetAll() do table.insert( APAWorldEnts, v ) end end) end

function APA.EntityCheck( entClass )
	local good, bad = false, false

	for _,v in pairs(has.L.Black) do
		if( string.find( string.lower(entClass), string.lower(v) ) ) then
			bad = true
			break -- No need to go through the rest of the loop.
		end
	end

	for _,v in pairs(has.L.White) do
		if( string.find( string.lower(entClass), string.lower(v) ) ) then
			good = true
			break
		end
	end

	return good, bad, entClass
end

function APA.FindProp(attacker, inflictor)
	if( attacker:IsPlayer() ) then attacker = inflictor end
	return IsValid(attacker) and attacker.GetClass and attacker
end

local function DamageFilter( target, d ) -- d for damage info.
	local attacker, inflictor, damage, type = d:GetAttacker(), d:GetInflictor(), d:GetDamage(), d:GetDamageType()
	local dents = {attacker, inflictor}

	for _,v in next, dents do 
		local good, bad, ugly = APA.EntityCheck( v:GetClass() )
		local isvehicle = (attacker:IsVehicle() or inflictor:IsVehicle())
		local isexplosion = d:IsExplosionDamage()

		if has.UnbreakableProps:GetBool() then
			local x = IsValid(target) and target.GetClass and target:GetClass() or nil
			if x == "prop_physics" then return true end
		end

		if ( table.HasValue(has.L.Damage, type) or bad ) and not good then
			if has.BlockVehicleDamage:GetBool() and isvehicle then return true end
			if has.BlockExplosionDamage:GetBool() and isexplosion then return true end
			if has.AntiPK:GetBool() and not isvehicle and not isexplosion then 
				d:SetDamage(0) d:ScaleDamage(0) d:SetDamageForce(Vector(0,0,0))

				if has.FreezeOnHit:GetBool() then
					if damage >= 15 then
						if not v:IsPlayer() then
							local phys = IsValid(v) and v:GetPhysicsObject()
							if phys then phys:EnableMotion(false) end
						end
						if target:IsPlayer() then target:SetVelocity(target:GetVelocity()*-1) end
					end
				end

				return true
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "APAntiPk", DamageFilter )

hook.Add( "PlayerSpawnedProp", "APAntiExplode", function( _, _, prop )
	if( IsValid(prop) and has.BlockExplosionDamage:GetInt() >= 1 ) then
		if not string.find( string.lower(prop:GetClass()), "wire" ) then -- Wiremod causes problems.
			prop:SetKeyValue("ExplodeDamage", "0") 
			prop:SetKeyValue("ExplodeRadius", "0")
		end
	end
end)

if not APA.hasCPPI then error('[APA] CPPI not found, APAnti will be heavily limited.') return end

function APA.FindOwner( ent )
	local owner, _ = ent:CPPIGetOwner()
	return owner or ent.FPPOwner or nil -- Fallback to FPP variable if CPPI fails.
end

function APA.ModelNameFix( model )
	return tostring(string.gsub(model, "[\\/ %;]+", "/"):gsub("%.%..", "")) or nil
end

local function ModelFilter(mdl) -- Return true to block model.
	local mdl = APA.ModelNameFix(tostring(mdl)) or nil
	if not mdl then return true end
	-- Model Blocking Code Here --
end

function APA.isPlayer(ent) return IsValid(ent) and (ent.GetClass and ent:GetClass() == "player") or (ent.IsPlayer and ent:IsPlayer()) or false end
local isPlayer = APA.isPlayer

function APA.IsWorld( ent )
	local iw = ent.IsWorld and ent:IsWorld()
	if (not APA.FindOwner(ent)) or (not (IsValid(ent) or iw)) or (not ent.GetClass) or ent.NoDeleting or ent.jailWall or isPlayer(ent) or
		(ent.IsNPC and ent:IsNPC()) or (ent.IsBot and ent:IsBot()) or ent.PhysgunDisabled or ( ent.CreatedByMap and ent:CreatedByMap() ) or
		(ent.GetPersistent and ent:GetPersistent()) or table.HasValue(APAWorldEnts, ent) then return true end

	local blacklist = {"func_", "env_", "info_", "predicted_", "chatindicator", "prop_door_"}
	local ec = string.lower(ent:GetClass())
	for _,v in pairs(blacklist) do
		if string.find( ec, string.lower(v) ) then
			return true
		end
	end

	return false
end

local function SpawnFilter(ply, model)
	timer.Simple(0, function()
		local ent = not ply:IsPlayer() and ply or nil
		local model = model and APA.ModelNameFix( model )

		if IsValid(ent) then
			if has.M.Ghosting then ent.__APAPhysgunHeld = {} end
			if has.NoCollideVehicles:GetBool() and ent:IsVehicle() then ent:SetCollisionGroup(COLLISION_GROUP_WEAPON) return end
			if has.M.Ghosting and has.GhostSpawn:GetBool() and APA.FindOwner( ent ) then APA.InitGhost(ent, false, false, true) return end
		end
	end)
end
hook.Add( "OnEntityCreated", "APAntiSpawns", SpawnFilter)

hook.Add( "PlayerSpawnObject", "APAntiSpawns", function(ply,mdl) if mdl and ModelFilter(mdl) then return false end end)
hook.Add( "AllowPlayerPickup", "APAntiPickup", function(ply,ent) 
	local good, bad, ugly = ent.GetClass and APA.EntityCheck(ent:GetClass())
	if bad or not good then return false end
end)

timer.Create("APAFreezePassive", 120, 0, function()
	if not has.FreezePassive:GetBool() then return end
	for _,v in next, table.Add(ents.FindByClass("prop_*"),ents.FindByClass("gmod_*")) do
		if IsValid(v) then
			for _,v in next, constraint.GetAllConstrainedEntities(v) do
				local v = v:GetPhysicsObject()
				if IsValid(v) then v:EnableMotion(false) end
				for _,v in next, player.GetAll() do
					if IsValid(v) then APA.Notify(v, "Entities have been frozen.", 4, 3.5, 0) end
				end
			end
		end
	end
end)