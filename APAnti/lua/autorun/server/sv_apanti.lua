/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon: APAnti
-- Author: LuaTenshi
-- Contact: luatenshi@gmail.com
----------------------------------------------------------------------------------------------------------------------------------------------------*/

APA = APA or {} -- Do not remove.
APA.Ghost = APA.Ghost or {} -- Do not remove.
APA.Settings = APA.Settings or {} -- Do not remove.
APA.Settings.FPP = APA.Settings.FPP or {} -- Do not remove.

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- WARNING: Do not edit any thing above this line unless you know what you are doing!
-- Below you will find the server settings!
----------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Setting this to 1 will enable Anti Prop Kill, setting it to 0 will disable it!
APA.Settings.AntiPK = 1
-- Setting this to 1 will stop vehicles from doing damage.
APA.Settings.VehiclesDontHurt = 1
-- Setting this to 1 will block explosions, setting it to 0 will disable it!
APA.Settings.BlockExplosions = 1
-- Setting this to 1 will make vehicles not collide with players.
APA.Settings.NoCollideVehicles = 1
-- Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!
APA.Settings.AntiPush = 0
-- Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: APA.Settings.AntiPush to be enabled!)
APA.Settings.APCollision = 1 --(Requires: APA.Settings.AntiPush to be enabled!)
-- Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!
APA.Settings.GhostOnSpawn = 1
-- Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally.
APA.Settings.Nerf = 0 -- Note: Setting physgun_maxSpeed to 400 (Default: 5000), will make this work better, and limmit how fast people can move props with their physgun.
-- Setting this to 1 will attempt to automatically block huge props, setting this to 0 will disable it! (Requires: Falco's Prop Protection!)
APA.Settings.FPP.AutoBlock = 1
APA.Settings.FPP.ABSize = 5.85 --How big a prop should be before it is blocked.
-- Set to 1 to enable the Blacklist, and to 0 to disable it!
APA.Settings.Blacklist = 1
-- Set to 1 to enable the Whitelist, and to 0 to disable it!
APA.Settings.Whitelist = 0

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- This Blacklist will allow the Anti Prop Kill to detect things that it would not normally detect.
-- Add things using their partial or full class names.
-- Make sure to never change this text " local ClassBlacklist = { ", and use the preset below as an example.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local ClassBlacklist = {
	"prop_physics",
	"money",
	"light",
	"playx",
	"lawboard",
	"prop",
	"wire"
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- This Whitelist will allow the Anti Prop Kill to ignore things that it would normally detect.
-- Add things using their partial or full class names.
-- Make sure to never change this text " local ClassWhitelist = { ", and use the preset below as an example.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local ClassWhitelist = {
	"",
	"",
	""
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Congradulations, you are now ready to start using this script on your server! If you get any errors please report them to me!
-- WARNING: Do not edit any thing below this line unless you know what you are doing!
----------------------------------------------------------------------------------------------------------------------------------------------------*/

--- Loading Console Vars ---

CreateConVar("apa_antipk", APA.Settings.AntiPK, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will enable Anti Prop Kill, setting it to 0 will disable it!")
CreateConVar("apa_vehiclesdonthurt", APA.Settings.VehiclesDontHurt, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will stop vehicles from doing damage.")
CreateConVar("apa_blockexplosions", APA.Settings.BlockExplosions, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will block explosions, setting it to 0 will disable it!")
CreateConVar("apa_nocollidevehicles", APA.Settings.NoCollideVehicles, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make vehicles not collide with players.")
CreateConVar("apa_antipush", APA.Settings.AntiPush, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!")
CreateConVar("apa_apcollision", APA.Settings.APCollision, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: apa_antipush to be set to 1!)")
CreateConVar("apa_ghostonspawn", APA.Settings.GhostOnSpawn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!")
CreateConVar("apa_nerf", APA.Settings.Nerf, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally. Note: Setting physgun_maxSpeed to 400 (Default: 5000), will make this work better, and limmit how fast people can move props with their physgun.")
CreateConVar("apa_fpp_autoblock", APA.Settings.FPP.AutoBlock, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to true will attempt to automatically block huge props, setting this to false will disable it! (Requires: Falco's Prop Protection!)")
CreateConVar("apa_fpp_absize", APA.Settings.FPP.ABSize, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How big a prop should be before it is blocked. (Requires: apa_fpp_autoblock to be set to 1!)")
CreateConVar("apa_blacklist", APA.Settings.Blacklist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Blacklist, and to 0 to disable it!")
CreateConVar("apa_whitelist", APA.Settings.Whitelist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Whitelist, and to 0 to disable it!")

--- DONE ---

local function APAntiLoad(APAReload)

	--- LOAD THE ALL IMPORTANT VARIABLES ----------------------------------------------
	APA.Settings.AntiPK = GetConVar("apa_antipk"):GetInt()
	APA.Settings.VehiclesDontHurt = GetConVar("apa_vehiclesdonthurt"):GetInt()
	APA.Settings.BlockExplosions = GetConVar("apa_blockexplosions"):GetInt()
	APA.Settings.NoCollideVehicles = GetConVar("apa_nocollidevehicles"):GetInt()
	APA.Settings.AntiPush = GetConVar("apa_antipush"):GetInt()
	APA.Settings.APCollision = GetConVar("apa_apcollision"):GetInt()
	APA.Settings.GhostOnSpawn = GetConVar("apa_ghostonspawn"):GetInt()
	APA.Settings.Nerf = GetConVar("apa_nerf"):GetInt()
	APA.Settings.FPP.AutoBlock = GetConVar("apa_fpp_autoblock"):GetInt()
	APA.Settings.FPP.ABSize = GetConVar("apa_fpp_absize"):GetInt()
	APA.Settings.Blacklist = GetConVar("apa_blacklist"):GetInt()
	APA.Settings.Whitelist = GetConVar("apa_whitelist"):GetInt()
	--- DONE -------------------------------------------------------------------------

	if not (CPPI and CPPI.GetVersion()) then MsgC( Color( 255, 0, 0 ), "ERROR: CPPI not found, Prop protection not installed?") return end
	-- This only works if we have CPPI, sorry.

	function APA.FindOwner( ent )
		local owner = owner or nil
		if (ent:CPPIGetOwner()) then local cppi,_ = ent:CPPIGetOwner() end
		owner = cppi or ent.FPPOwner or ent.Owner
		return owner
	end

	function APA.FindKiller( atker, inflictor )
		if( atker and !atker:IsPlayer() ) then --I dont know...
			atker = atker.Owner
		end
		---I completly derped on the line above feel free to check if it acctually does any thing.---
		if( atker and !atker:IsPlayer() ) then --If its not the attacker then its the inflictor right?
			atker = inflictor
		end
		---The Above Should Not Cause Any Problems---
		if( atker and !atker:IsPlayer() and IsValid(inflictor) ) then --This is what we need...
			atker = APA.FindOwner( inflictor )
		end
		---The Above Is The Real Function That We Need---                                                                               --Yes I know, I'm paranoid.
		return atker
	end

	function APA.antiPk( target, dmginfo )
		if( APA.Settings.AntiPK >= 1 ) then
			local entClass = dmginfo:GetInflictor():GetClass()
			local badEntity = false
			local goodEntity = false

			if( APA.Settings.Blacklist >= 1 ) then
				for _,v in pairs(ClassBlacklist) do
					if( string.find( string.lower(entClass), string.lower(v) ) ) then
						badEntity = true
					end
				end
			end

			if( APA.Settings.Whitelist >= 1 ) then
				for _,v in pairs(ClassWhitelist) do
					if( string.find( string.lower(entClass), string.lower(v) ) ) then
						goodEntity = true
					end
				end
			end

			local atker = dmginfo:GetAttacker()
			local inflictor = dmginfo:GetInflictor()
			local dmg = dmginfo:GetDamage()

			if APA.Settings.VehiclesDontHurt >= 1 then
				if atker:IsVehicle() or inflictor:IsVehicle() then -- Is a vehicle doing this?
					dmginfo:ScaleDamage( 0 )
					dmg = 0 -- Set the damage variable to 0 just incase.
				end
			end

			if dmginfo:IsExplosionDamage() then -- Is this explosion damage?
				if APA.Settings.BlockExplosions == 1 then -- Stop damage from exploding props.
					local ex = {} 
					ex.atker, ex.inf = (IsValid(atker) and atker or nil), (IsValid(inflictor) and inflictor or nil)
					
					atker = APA.FindKiller( atker, inflictor )
					if (atker and atker:IsPlayer()) or (ex.atker:GetClass() == "prop_physics" or ex.inf:GetClass() == "prop_physics") then
						dmginfo:ScaleDamage( 0 ) 
					end

				elseif APA.Settings.BlockExplosions >= 2 then -- Stop damage from explosions.
					dmginfo:ScaleDamage( 0 )
				end
			end

			if ( dmginfo:GetDamageType() == DMG_CRUSH or badEntity ) and !goodEntity then
				dmginfo:ScaleDamage( 0 )

				atker = APA.FindKiller( atker, inflictor )
				if( atker and IsValid(atker) and atker:IsPlayer() and target and IsValid(target) and target:IsPlayer() ) then
					if(atker != target) then
						if( !atker.APAWarned ) then
							MsgAll( atker:GetName() .. "[" .. atker:SteamID() .. "]" .. " hit " .. target:GetName() .. "[" .. target:SteamID() .. "]" .. " with a prop!\n" )
							atker.APAWarned = true
							timer.Simple(0.25, function() atker.APAWarned = false end) --Removing console spam.
						end
						atker:TakeDamage( dmg, atker, atker ) --I hope the return to sender works now.
					end
				end

				dmginfo:ScaleDamage( 0 )
			end
		end
	end
	hook.Add( "EntityTakeDamage", "APAntiPk", APA.antiPk )

	---Block-Explosions---

	if APA.Settings.BlockExplosions >= 1 then
		hook.Add( "PlayerSpawnedProp", "APAntiExplode", function( _, _, prop )
			if( prop and IsValid(prop) ) then
				prop:SetKeyValue("ExplodeDamage", "0") 
				prop:SetKeyValue("ExplodeRadius", "0")
			end
		end)
	end

	---Ghosting-Stuff---

	function APA.Ghost.Force( ent )
	-- Used for ghosting a prop when it spawns in theory we could have FPPs anti-spam take care of this but this lets people build without their console getting spammed with "your prop has been ghosted".
		if( ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld() ) then
			ent.APGhost = true
			ent.OldCollisionGroup = ent:GetCollisionGroup()
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:DrawShadow(false)
			ent.OldColor = ent.OldColor or ent:GetColor()
			ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70))

			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ent.CollisionGroup = COLLISION_GROUP_WORLD
			ent.APNoColided = true

			local PhysObj = ent:GetPhysicsObject()
			if( PhysObj ) then PhysObj:EnableMotion(false) end
		end
	end

	function APA.Ghost.On( picker, ent, spoof )
		if( ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld() ) then
			if( spoof or (picker and picker:IsValid() and picker:IsPlayer()) ) then
				if( spoof or ent:CPPICanPhysgun( picker ) ) then
--					|_ Used for the anti-trap makes it so the prop is ghosted. |_ Admins and SuperAdmins can pick up other peoples props so...
					ent.APGhost = true
					ent.OldCollisionGroup = ent:GetCollisionGroup()
					ent:SetRenderMode(RENDERMODE_TRANSALPHA)
					ent:DrawShadow(false)
					ent.OldColor = ent.OldColor or ent:GetColor()
					ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70)) -- Make the prop slightly faded to show that its ghosted.

					if( APA.Settings.APCollision <= 1 ) then
						ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
						ent.CollisionGroup = COLLISION_GROUP_WEAPON
					else
						ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
						ent.CollisionGroup = COLLISION_GROUP_WORLD
					end

					ent.APNoColided = true
				end
			end
		end
	end

	function APA.Ghost.CanOff( ent )
		local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
		local cube = ents.FindInBox( mins, maxs )
		local owner = APA.FindOwner( ent )
		for _,v in pairs(cube) do 
			if( ( IsValid(v) and v:GetModel() and v != ent ) and ( v:GetClass() != "physgun_beam" and !v:IsWorld() ) and (IsValid(APA.FindOwner( v )) or v:IsPlayer() or v:IsNPC()) ) then
				if not ent.APAIsObscured then
					owner:SendLua([[notification.AddLegacy( "Prop Obscured!", NOTIFY_ERROR, 2 )]])
					ent.APAIsObscured = true
				end

				local PhysObj = v:GetPhysicsObject()
				if( PhysObj and IsValid(PhysObj) ) then
					if( PhysObj:IsMotionEnabled() ) then
						return false
					end
				else
					return false
				end
			end 
		end
		ent.APAIsObscured = nil
		return true
	end

	function APA.Ghost.Off( picker, ent, spoof )
		if( APA.Ghost.CanOff( ent ) ) then
			if( ent.APGhost and (ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld()) ) then
				if( spoof or (picker and picker:IsValid() and picker:IsPlayer()) ) then
					if( spoof or ent:CPPICanPhysgun( picker ) ) then
						ent.APGhost = nil
						ent:DrawShadow(true)

						if ent.OldColor then
							ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a))
						end
						ent.OldColor = nil

						ent:SetCollisionGroup(COLLISION_GROUP_NONE)
						ent.CollisionGroup = COLLISION_GROUP_NONE
						ent.APNoColided = false
					end
				end
			end
		end
	end

	--ANTI-TRAP--
	timer.Create( "APAntiPropPush-EntityScanner", 1.3, 0, function()
		for _,ent in pairs(ents.GetAll()) do
			if ent:IsVehicle() then
				if APA.Settings.NoCollideVehicles >= 1 and not ent.APNoColided then
					ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					ent.CollisionGroup = COLLISION_GROUP_WEAPON
					ent:SetCustomCollisionCheck( true )
					ent.APNoColided = true
				end
			else	--------------------
				if ent.APGhostOff or APA.Settings.AntiPush >= 1 then
					if ent.APGhostOff then
						local MotionEnabled, PhysObj = false, ent:GetPhysicsObject(); if( IsValid(PhysObj) ) then MotionEnabled = PhysObj:IsMotionEnabled() end
						if APA.Settings.AntiPush >= 1 then
							if (ent:GetVelocity():Distance( Vector( 0.1, 0.1, 0.1 ) ) > 0.2 and MotionEnabled) then
								APA.Ghost.On( nil, ent, true )
							end
						end
						if ( ( ent:GetVelocity():Distance( Vector( 0.1, 0.1, 0.1 ) ) <= 0.2 or !MotionEnabled ) and ent.APGhost ~= nil ) then
							if APA.Ghost.CanOff( ent ) then
								APA.Ghost.Off( nil, ent, true )
							end
						end
					end
				end
			end
		end
	end)

	--Check Vehicle Spawn--
	hook.Add("PlayerSpawnedVehicle", "APA.VehicleSpawnCheck", function(ent) 
		if APA.Settings.NoCollideVehicles >= 1 then
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ent.CollisionGroup = COLLISION_GROUP_WEAPON
			ent:SetCustomCollisionCheck( true )
			ent.APNoColided = true
		end
	end)

	--Should We Collide?--
	hook.Add("ShouldCollide", "APA.ShouldCollide-ExtraCheck", function( enta, entb )
		if APA.Settings.NoCollideVehicles >= 1 then
			if enta:IsVehicle() and entb:IsPlayer() then
				return false
			end
		end

		if APA.Settings.AntiPush >= 1 then
			if enta.APGhost and entb:IsPlayer() then
				return false
			end
		end
	end)

	--Property-Setting-Fix--
	hook.Add("CanProperty", "APA.CanPropertyFix", function( _, property, ent )
		if( tostring(property) == "collision" and ent.APNoColided ) then return false end
	end)

	---Physgun-Stuff---

	--PHYSGUN-DROP--

	hook.Add( "PhysgunDrop", "APAntiPropPush-Drop", function( picker, ent ) -- We always want to unghost props if they are ghosted.
		if( ( !ent:IsPlayer() and !ent:IsNPC() and !ent:IsVehicle() ) and picker != ent ) then
			-- APA.Ghost.Off( picker, ent, false )
			ent.APGhostOff = true
		end
	end)

	--PHYSGUN-PICKUP--
	hook.Add( "PhysgunPickup", "APAntiPropPush-Pickup", function( picker, ent )
		if( APA.Settings.AntiPush >= 1 ) then
			if( ( !ent:IsPlayer() and !ent:IsNPC() and !ent:IsVehicle() ) and picker != ent ) then
				APA.Ghost.On( picker, ent, true )
				ent.APGhostOff = false
			end
		end
	end)

	--PHYSGUN-THROW-NERF--
	hook.Add( "PhysgunDrop", "APAntiPropPush-Nerf", function( _, ent )
		if APA.Settings.Nerf >= 1 then
			if( ent and (ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld()) and ent:GetPhysicsObject() ) then 
				ent:SetVelocity(Vector(0,0,0))
				ent:SetAbsVelocity(Vector(0,0,0))
				---------
				local phys = ent:GetPhysicsObject()
				if( phys and IsValid(phys) ) then
					phys:AddAngleVelocity( phys:GetAngleVelocity() * -1 )
					phys:SetVelocityInstantaneous( Vector(0,0,0) )
				end
			end
		end
	end)


	--Ghost Props On Spawn:
	hook.Add("PlayerSpawnedProp", "_APA.AntiSpam.PropSafeSpawn", function(_, _, ent)
		if IsValid(ent) and APA.Settings.GhostOnSpawn >= 1 then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				APA.Ghost.Force( ent )
				ent.APGhostOff = false
			end
		end
	end)

	---I dont like huge props | Default big props math.pow(10, 5.85) or 707945.784384 & math.pow(3.23, 5.85) or 952.433704327---
	if APA.Settings.FPP.AutoBlock >= 1 then
		hook.Add("PlayerSpawnedProp", "APA.Settings.FPP.AutoBlock", function(ply,mdl,ent)
			if APA.Settings.FPP.AutoBlock then
				if ( ent:GetPhysicsObject() and ent:GetPhysicsObject():GetVolume() ) then
					local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
					if ( ent:GetPhysicsObject():GetVolume() > math.pow(10,APA.Settings.FPP.ABSize) ) or ( mins:Distance(maxs) > math.pow(3.23,APA.Settings.FPP.ABSize) ) then
						if( mdl and ( type(FPP) == "table" ) ) then --This will only work if you have Falco's Prop Protection!
							mdl = string.Replace(string.Replace(string.Replace( mdl, "\\", "/" ), "\"", ""), ";", "") --Just in case.
							RunConsoleCommand( "FPP_AddBlockedModel", mdl ) 
						end
						if( ply:IsValid() ) then 
							ply:ChatPrint("That prop is now blocked, thanks. ;)") 
							ply:SendLua([[notification.AddLegacy( "That prop is now blocked, thanks!", NOTIFY_ERROR, 10 )]])
							ply:SendLua([[surface.PlaySound("ambient/alarms/klaxon1.wav")]])
						end
						if( ent:IsValid() ) then ent:Remove() end
					end
				end
			end
		end)
	end

	---Now lets fix a long forgotten exploit...
	hook.Add("PlayerSpawnObject", function(ply, model)
		model = string.lower(model or "")
		model = string.Replace(model, "\\", "/")
		model = string.gsub(model, "[\\/]+", "/")
		model = string.Replace(string.Replace(string.Replace( mdl, "\\", "/" ), "\"", ""), ";", "")
		
		if string.find(model, "../", 1, true) or string.find(model, "/..", 1, true) then
			ply:SendLua([[notification.AddLegacy( "The model path goes up in the folder tree., NOTIFY_ERROR, 10 )]])
			ply:SendLua([[surface.PlaySound("ambient/alarms/klaxon1.wav")]])
			return false
		end
	end)

	if APAReload == true then
		MsgAll("\n<|||APAnti Has Been Reloaded!|||>\n")
		for _,v in pairs(player.GetAll()) do v:ChatPrint("\n<|||APAnti Has Been Reloaded!|||>\n") end
	else
		MsgAll("\n<|||APAnti Is Now Running!|||>\n")
		hook.Remove("PlayerConnect", "APAnti-Execution-Hook")
	end
end

hook.Add("PlayerConnect", "APAnti-Execution-Hook", function() MsgAll("\n<|||APAnti Is Loading...|||>\n") timer.Simple( 0.5, function() APAntiLoad(false) end ) end)
concommand.Add("apa_reload", function() APAntiLoad(true) end, nil, nil, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE})