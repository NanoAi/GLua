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
-- Setting this to 1 will enable returning damage setting it to 0 will disable it!
APA.Settings.DamageReturn = 1
-- Setting this to 1 will alert admins when some one attempts to prop kill. (Currently broken but will be available soon.)
APA.Settings.AlertAdmins = 0
APA.Settings.AlertAdminsThreshold = 80 -- The amount of damage the prop must do before the admins are alerted. (Requires: APA.Settings.AlertAdmins to be enabled.)
-- Setting this to 1 will stop vehicles from doing damage.
APA.Settings.VehiclesDontHurt = 1
-- Setting this to 1 will block explosions, setting it to 0 will disable it!
APA.Settings.BlockExplosions = 1
-- Setting this to 1 will make vehicles not collide with players.
APA.Settings.NoCollideVehicles = 1
-- Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!
APA.Settings.AntiPush = 1
-- Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: APA.Settings.AntiPush to be enabled!)
APA.Settings.APCollision = 1 --(Requires: APA.Settings.AntiPush to be enabled!)
-- Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!
APA.Settings.GhostOnSpawn = 1
-- Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally.
APA.Settings.Nerf = 1 -- Note: Setting physgun_maxSpeed to 400 (Default: 5000), will make this work better, and limmit how fast people can move props with their physgun.
-- Setting this to 1 will attempt to automatically block huge props, setting this to 0 will disable it!
APA.Settings.FPP.AutoBlock = 1 -- (Requires: Falco's Prop Protection!)
APA.Settings.FPP.ABSize = 5.85 --How big a prop should be before it is blocked. (Requires: RemoveBig to be set to 1!)
APA.Settings.FPP.Sounds = 0 --Setting this to 1 will make an error sound, when a prop is autoblocked. (Requires: RemoveBig to be set to 1!)
-- Set to 1 to enable the Blacklist, and to 0 to disable it!
APA.Settings.Blacklist = 1
-- Set to 1 to enable the Whitelist, and to 0 to disable it!
APA.Settings.Whitelist = 0
-- Set to 1 to make weapons not collide with any thing except the world, and set to 0 to make weapons collide like normal.
APA.Settings.NoCollideWeapons = 1
-- Set to 1 to automatically freeze props over time, and set to 0 to disable. (Requires: Map restart.)
APA.Settings.AutoFreeze = 0
-- How long to wait before freezing all props. (Default: 300) (Requires: apa_autofreeze to be set to 1!)
APA.Settings.AutoFreezeTime = 300

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Things that should get frozen when they hit a player.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local ClassFreezelist = {
	"prop_physics"
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- This Blacklist will allow the Anti Prop Kill to detect things that it would not normally detect.
-- Add things using their partial or full class names.
-- Make sure to never change this text " local ClassBlacklist = { ", and use the preset below as an example.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local ClassBlacklist = {
	"prop_physics",
	"money",
	"cheque",
	"light",
	"playx",
	"lawboard",
	"fadmin_motd",
	"fadmin_jail",
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
-- CreateConVar("apa_alertadmins", APA.Settings.AlertAdmins, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will alert admins when a player hits another player with a prop. Setting it to 0 will disable it.")
-- CreateConVar("apa_alertadmins_threshold", APA.Settings.AlertAdminsThreshold, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How much damage should the prop do for admins to be notified. (Default: 80) (Requires: APA.Settings.AlertAdmins to be enabled.)")
CreateConVar("apa_antipk_punish", APA.Settings.DamageReturn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will hurt the person who through the prop!")
CreateConVar("apa_vehiclesdonthurt", APA.Settings.VehiclesDontHurt, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will stop vehicles from doing damage.")
CreateConVar("apa_blockexplosions", APA.Settings.BlockExplosions, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will block explosions, setting it to 0 will disable it!")
CreateConVar("apa_nocollidevehicles", APA.Settings.NoCollideVehicles, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make vehicles not collide with players.")
CreateConVar("apa_antipush", APA.Settings.AntiPush, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!")
CreateConVar("apa_apcollision", APA.Settings.APCollision, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: apa_antipush to be set to 1!)")
CreateConVar("apa_ghostonspawn", APA.Settings.GhostOnSpawn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!")
CreateConVar("apa_nerf", APA.Settings.Nerf, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally. Note: Setting physgun_maxSpeed to 400 (Default: 5000), will make this work better, and limmit how fast people can move props with their physgun.")
CreateConVar("apa_fpp_autoblock", APA.Settings.FPP.AutoBlock, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to true will attempt to automatically block huge props, setting this to false will disable it! (Requires: Falco's Prop Protection!)")
CreateConVar("apa_fpp_absize", APA.Settings.FPP.ABSize, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How big a prop should be before it is blocked. (Requires: apa_fpp_autoblock to be set to 1!)")
CreateConVar("apa_fpp_sounds", APA.Settings.FPP.Sounds, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make an error sound, when a prop is autoblocked.")
CreateConVar("apa_blacklist", APA.Settings.Blacklist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Blacklist, and to 0 to disable it!")
CreateConVar("apa_whitelist", APA.Settings.Whitelist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Whitelist, and to 0 to disable it!")
CreateConVar("apa_nocollideweapons", APA.Settings.NoCollideWeapons, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to make weapons not collide with any thing except the world, and set to 0 to make weapons collide like normal.")
CreateConVar("apa_autofreeze", APA.Settings.AutoFreeze, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to automatically freeze props over time, and set to 0 to disable. (Requires: Map restart.)")
CreateConVar("apa_autofreeze_time", APA.Settings.AutoFreezeTime, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How long to wait before freezing all props. (Default: 300) (Requires: apa_autofreeze to be set to 1!)")

--- DONE ---

/*
local ConvarList = {
	"apa_antipk",
	"apa_alertadmins",
	"apa_alertadmins_threshold",
	"apa_antipk_punish",
	"apa_vehiclesdonthurt",
	"apa_blockexplosions",
	"apa_nocollidevehicles",
	"apa_antipush",
	"apa_apcollision",
	"apa_ghostonspawn",
	"apa_nerf",
	"apa_fpp_autoblock",
	"apa_fpp_absize",
	"apa_fpp_sounds",
	"apa_blacklist",
	"apa_whitelist",
	"apa_nocollideweapons",
	"apa_autofreeze",
	"apa_autofreeze_time"
}
*/ -- May be we will use this in the future?

local function APAReloadVars()
	--- LOAD THE ALL IMPORTANT VARIABLES ----------------------------------------------
	APA.Settings.AntiPK = GetConVar("apa_antipk"):GetInt()
	-- APA.Settings.AlertAdmins = GetConVar("apa_alertadmins"):GetInt() -- Currently broken but will be available soon.
	-- APA.Settings.AlertAdminsThreshold = GetConVar("apa_alertadmins_threshold"):GetInt() -- Currently broken but will be available soon.
	APA.Settings.DamageReturn = GetConVar("apa_antipk_punish"):GetInt()
	APA.Settings.VehiclesDontHurt = GetConVar("apa_vehiclesdonthurt"):GetInt()
	APA.Settings.BlockExplosions = GetConVar("apa_blockexplosions"):GetInt()
	APA.Settings.NoCollideVehicles = GetConVar("apa_nocollidevehicles"):GetInt()
	APA.Settings.AntiPush = GetConVar("apa_antipush"):GetInt()
	APA.Settings.APCollision = GetConVar("apa_apcollision"):GetInt()
	APA.Settings.GhostOnSpawn = GetConVar("apa_ghostonspawn"):GetInt()
	APA.Settings.Nerf = GetConVar("apa_nerf"):GetInt()
	APA.Settings.FPP.AutoBlock = GetConVar("apa_fpp_autoblock"):GetInt()
	APA.Settings.FPP.ABSize = GetConVar("apa_fpp_absize"):GetInt()
	APA.Settings.FPP.Sounds = GetConVar("apa_fpp_sounds"):GetInt()
	APA.Settings.Blacklist = GetConVar("apa_blacklist"):GetInt()
	APA.Settings.Whitelist = GetConVar("apa_whitelist"):GetInt()
	APA.Settings.NoCollideWeapons = GetConVar("apa_nocollideweapons"):GetInt()
	APA.Settings.AutoFreeze = GetConVar("apa_autofreeze"):GetInt()
	APA.Settings.AutoFreezeTime = GetConVar("apa_autofreeze_time"):GetInt()
	--- DONE -------------------------------------------------------------------------
	/*
	for k,v in pairs(APA.Settings) do
		if type(v) != "table" then
			v = GetConVar(ConvarList[k]):GetInt()
		else
			v.FPP = GetConVar(ConvarList[k]):GetInt()
		end
	end
	*/ -- May be we will use this in the future?
end

hook.Add("Initialize", "_APALoadVariables", function() 
	APAReloadVars()
	timer.Create( "__APAUpdateVars", 1.50, 0, function() APAReloadVars() end) -- Refresh the variables over time.
end)

local APAWorldEnts = {}
hook.Add( "InitPostEntity", "_APAGetWorldEnts", function()
	table.Empty( APAWorldEnts )
	APAWorldEnts = {} -- Make sure that the table is empty.
	-----------
	timer.Simple( 1.5, function()
		for _,v in pairs(ents.GetAll()) do
			table.insert( APAWorldEnts, v )
		end
	end )
end )

local function APAntiLoad()

	APAReloadVars() -- Make sure the variables get loaded.

	if not (CPPI and CPPI.GetVersion()) then MsgC( Color( 255, 0, 0 ), "ERROR: CPPI not found, Prop protection not installed?") return end
	-- This only works if we have CPPI, sorry.

	function APA.CMsg( str, dmg )
		MsgAll(str) -- Notify all clients in console.
		ServerLog(str) -- Log to server.

		/* -- Admin alerts below this line.
		if dmg >= APA.Settings.AlertAdminsThreshold then
			if APA.Settings.AlertAdmins >= 2 then
				for _,v in pairs(player.GetAll()) do
					if v and v:IsSuperAdmin() then
						v:SendLua([[chat.AddText(Color(255,170,0), "[A2PK] ", Color(255,0,0), "]] .. str .. "\")")
					end
				end
			elseif APA.Settings.AlertAdmins == 1 then
				for _,v in pairs(player.GetAll()) do
					if v and ( v:IsSuperAdmin() or v:IsAdmin() ) then
						v:SendLua([[chat.AddText(Color(255,170,0), "[A2PK] ", Color(255,0,0), "]] .. str .. "\")")
					end
				end
			end
		end
		*/ -- Currently broken but will be available soon.
	end

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

	function APA.EntityCheck( entClass )
		local badEntity, goodEntity = false, false

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

		return badEntity, goodEntity
	end

	function APA.antiPk( target, dmginfo )
		if( APA.Settings.AntiPK >= 1 ) then
			local entClass = dmginfo:GetInflictor():GetClass()
			local badEntity, goodEntity = APA.EntityCheck( entClass )

			local atker, inflictor, dmg = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()

			if APA.Settings.VehiclesDontHurt >= 1 and not badEntity then
				if atker:IsVehicle() or inflictor:IsVehicle() then -- Is a vehicle doing this?
					dmginfo:SetDamage(0)	dmginfo:ScaleDamage( 0 )
				end
			end

			if APA.Settings.BlockExplosions == 2 and not badEntity then -- Stop damage from explosives.
				if dmginfo:IsExplosionDamage() then -- Is this explosion damage?
					dmginfo:SetDamage(0)	dmginfo:ScaleDamage( 0 )
				end
			end

			if ( dmginfo:GetDamageType() == DMG_CRUSH or badEntity ) and !goodEntity then

				local str = ""
				atker, inflictor, dmg = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()
				-- Reconfirm...

				dmginfo:SetDamage(0)	dmginfo:ScaleDamage( 0 )

				atker = APA.FindKiller( atker, inflictor )
				if( atker and IsValid(atker) and atker:IsPlayer() and target and IsValid(target) and target:IsPlayer() ) then
					if(atker != target) then
						if( !atker.APAWarned ) then
							str = atker:GetName() .. "[" .. atker:SteamID() .. "]" .. " hit " .. target:GetName() .. "[" .. target:SteamID() .. "]" .. " with a prop!\n"
							APA.CMsg( str, dmg  )
							atker.APAWarned = true
							timer.Simple(0.25, function() atker.APAWarned = false end) --Removing console spam.
						end
						if APA.Settings.DamageReturn >= 1 then
							timer.Create( "__APADamageReturn", 0.25, 1, function() atker:TakeDamage( dmg, atker, atker ) end) --I hope the return to sender works now.
							--									|_ We delay by a quarter of a second to stop the script from doing double damage or hurting the wrong player.
						end
					end
				end

				dmginfo:SetDamage(0)	dmginfo:ScaleDamage( 0 ) -- For some reason this needs to be called again here or else the prop still does damage.
			end
		end
	end
	hook.Add( "EntityTakeDamage", "APAntiPk", APA.antiPk )

	---Block-Explosions---

	hook.Add( "PlayerSpawnedProp", "APAntiExplode", function( _, _, prop )
		if( prop and IsValid(prop) and APA.Settings.BlockExplosions >= 1 ) then
			prop:SetKeyValue("ExplodeDamage", "0") 
			prop:SetKeyValue("ExplodeRadius", "0")
		end
	end)

	---Ghosting-Stuff---

	function APA.IsWorld( ent ) -- Intensive is world check.
		local ec, iw, gw, ip, ipc, iv, ipr = ent:GetClass(), ent:IsWorld(), game.GetWorld(), ent:IsPlayer(), ent:IsNPC(), ent:IsVehicle(), ent:GetPersistent()
		
		if ent == gw then return true end
		if iw then return true end
		if ip then return true end
		if ipc then return true end
		if iv then return true end
		if ipr then return true end
		if ec == gw:GetClass() then return true end
		if ec == "prop_door_rotating" then return true end
		if table.HasValue(APAWorldEnts, ent) then return true end

		local blacklist = {"func_", "env_", "light_", "info_"}
		ec = string.lower(ec)
		for _,v in pairs(blacklist) do 
			if string.find( ec, string.lower(v) ) then
				return true
			end
		end

		return false
	end

	function APA.CanPickup( picker, ent )
		if not ( picker and picker:IsPlayer() and IsValid(picker) ) then return false end -- If the picker is not a player then return false.

		local cp,_ = ent:CPPICanPhysgun( picker )
		local iw, gw, ip, o = APA.IsWorld( ent ), game.GetWorld(), ent:IsPlayer(), APA.FindOwner( ent )
		
		if ent == gw then return false end
		if iw then return false end
		if ip then return false end

		if not ( o and IsValid(o) ) then return false end
		
		if o:IsPlayer() then if ( o == picker or cp ) then return true end end
	end

	function APA.Ghost.Force( ent )
	-- Used for ghosting a prop when it spawns in theory we could have FPPs anti-spam take care of this but this lets people build without their console getting spammed with "your prop has been ghosted".
		if( ent:IsValid() and !ent:IsPlayer() and not APA.IsWorld( ent ) ) then
			ent.APGhost = true
			ent.OldCollisionGroup = ent:GetCollisionGroup()
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:DrawShadow(false)
			ent.OldColor = ent.OldColor or ent:GetColor()
			ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70))


			if( APA.Settings.APCollision >= 1 ) then
				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				ent.CollisionGroup = COLLISION_GROUP_WEAPON
			else
				ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
				ent.CollisionGroup = COLLISION_GROUP_WORLD
			end

			ent.APNoColided = true

			local PhysObj = ent:GetPhysicsObject()
			if( PhysObj ) then PhysObj:EnableMotion(false) end
		end
	end

	function APA.Ghost.On( picker, ent, spoof )
		if( ent:IsValid() and !ent:IsPlayer() and not APA.IsWorld( ent ) ) then
			if( spoof or (picker and picker:IsValid() and picker:IsPlayer()) ) then
				if ( spoof or ( APA.CanPickup( picker, ent ) ) ) then
--					|_ Used for the anti-trap makes it so the prop is ghosted. |_ Admins and SuperAdmins can pick up other peoples props so...
					ent.APGhost = true
					ent.OldCollisionGroup = ent:GetCollisionGroup()
					ent:SetRenderMode(RENDERMODE_TRANSALPHA)
					ent:DrawShadow(false)
					ent.OldColor = ent.OldColor or ent:GetColor()
					ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70)) -- Make the prop slightly faded to show that its ghosted.

					if( APA.Settings.APCollision >= 1 ) then
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
		local owner = nil

		if APA.Settings.AntiPush >= 1 then owner = APA.FindOwner( ent ) end

		for _,v in pairs(cube) do
			local PhysObj = v:GetPhysicsObject()
			if( ( IsValid(v) and v:GetModel() and v != ent ) and ( PhysObj and PhysObj:IsValid() and PhysObj:IsMotionEnabled() ) and ( IsValid(APA.FindOwner( v )) ) or v:IsPlayer() or v:IsNPC() ) then
				if not ent.APAIsObscured then
					if APA.Settings.AntiPush >= 1 then owner:SendLua([[notification.AddLegacy( "Prop Obscured!", NOTIFY_ERROR, 2 )]]) end
					ent.APAIsObscured = true
				end
				return false
			end 
		end
		ent.APAIsObscured = nil

		if ent:GetVelocity():Distance( Vector( 0.1, 0.1, 0.1 ) ) > 0.2 then return false end -- If the prop is still moving then we can not unghost.
		return true
	end

	function APA.Ghost.Off( picker, ent, spoof )
		local canoff = APA.Ghost.CanOff( ent )
		if not canoff then return false end
		if( ent.APGhost and (ent:IsValid() and !ent:IsPlayer() and not APA.IsWorld( ent )) ) then
			if( spoof or ( APA.CanPickup( picker, ent ) ) ) then
				ent.APGhost = nil
				ent:DrawShadow(true)

				if ent.OldColor then ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a)) end
				ent.OldColor = nil

				ent:SetCollisionGroup(COLLISION_GROUP_NONE)
				ent.CollisionGroup = COLLISION_GROUP_NONE
				ent.APNoColided = false
			end
		end
	end

	--ANTI-TRAP--
	timer.Create( "APAntiPropPush-EntityScanner", 1.3, 0, function()
		for _,ent in pairs(ents.GetAll()) do
			if (ent:IsWeapon() or ent:GetClass() == "spawned_weapon") and APA.Settings.NoCollideWeapons >= 1 then
				ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
				ent.CollisionGroup = COLLISION_GROUP_WORLD
			end
			--------------
			if ent:IsVehicle() then
				if APA.Settings.NoCollideVehicles >= 1 and not ent.APNoColided then
					ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					ent.CollisionGroup = COLLISION_GROUP_WEAPON
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
							APA.Ghost.Off( nil, ent, true )
						end
					end
				end
			end
		end
	end)
	
	if APA.Settings.AutoFreeze >= 1 then -- The only command that needs map restart.
		if APA.Settings.AutoFreezeTime < 60 then APA.Settings.AutoFreezeTime = 300 end
		timer.Create( "APAntiAutoFreezeTimer", APA.Settings.AutoFreezeTime, 0, function() 
			if PA.Settings.AutoFreeze >= 1 then
				for _,ent in pairs(ents.FindByClass("prop_physics")) do
					if ent and IsValid(ent) then
						local phys = ent:GetPhysicsObject()
						if phys:IsValid() then
							phys:EnableMotion(false)
						end
					end
				end
			end
		end)
	end

	--Check Vehicle Spawn--
	hook.Add("PlayerSpawnedVehicle", "APA.VehicleSpawnCheck", function(ent) 
		if APA.Settings.NoCollideVehicles >= 1 then
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ent.CollisionGroup = COLLISION_GROUP_WEAPON
			ent.APNoColided = true
		end
	end)

	--Property-Setting-Fix--
	hook.Add("CanProperty", "APA.CanPropertyFix", function( _, property, ent )
		if( tostring(property) == "collision" and ent.APNoColided ) then return false end
	end)

	---Physgun-Stuff---

	--PHYSGUN-DROP--

	hook.Add( "PhysgunDrop", "APAntiPropPush-Drop", function( picker, ent ) -- We always want to unghost props if they are ghosted.
		if( !APA.IsWorld( ent ) and picker != ent ) then
			if APA.Settings.AntiPush <= 0 then APA.Ghost.Off( picker, ent, true ) end -- Unghost props a little faster.
			ent.APGhostOff = true
		end
	end)

	--PHYSGUN-PICKUP--
	hook.Add( "PhysgunPickup", "APAntiPropPush-Pickup", function( picker, ent )
		if( APA.Settings.AntiPush >= 1 ) then
			if( !APA.IsWorld( ent ) and picker != ent ) then
				APA.Ghost.On( picker, ent, true )
				ent.APGhostOff = false
			end
		end
	end)

	--PHYSGUN-THROW-NERF--
	hook.Add( "PhysgunDrop", "APAntiPropPush-Nerf", function( _, ent )
		if APA.Settings.Nerf >= 1 then
			if( ent and (ent:IsValid() and !ent:IsPlayer() and not APA.IsWorld( ent )) and ent:GetPhysicsObject() ) then 
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

	function APA.ModelNameFix( model )
		model = string.lower(model or "")
		model = string.Replace(model, "\\", "/") -- Thoes backwards slashes always trying to confuse the situation.
		model = string.Replace(model, " ", "_") -- Model names do not have spaces, stop asking.
		model = string.Replace(model, ";", "") -- ; may be used to escape so we are removing it.
		model = string.gsub(model, "[\\/]+", "/")
		return model
	end

	--- I dont like huge props | Default big props math.pow(10, 5.85) or 707945.784384 ---
	hook.Add("PlayerSpawnedProp", "APA.Settings.FPP.AutoBlock", function(ply,mdl,ent)
		if APA.Settings.FPP.AutoBlock then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:GetVolume() ) then
				local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
				if ( phys:GetVolume() > math.pow(10,APA.Settings.FPP.ABSize) ) then
					if( mdl and ( type(FPP) == "table" ) ) then --This will only work if you have Falco's Prop Protection!
						mdl = APA.ModelNameFix( mdl ) --Just in case.
						RunConsoleCommand( "FPP_AddBlockedModel", mdl )
					end
					if( ply:IsValid() ) then 
						ply:ChatPrint("That prop is now blocked, thanks!") 
						ply:SendLua([[notification.AddLegacy( "That prop is now blocked, thanks!", NOTIFY_ERROR, 10 )]])
						if APA.Settings.FPP.Sounds >= 1 then ply:SendLua([[surface.PlaySound("ambient/alarms/klaxon1.wav")]]) end
					end
					if( ent:IsValid() ) then ent:Remove() end
				end
			end
		end
	end)

	---Now lets fix a long forgotten exploit...
	function APA.ModelBypassFix( ply, model )
		model = APA.ModelNameFix( model )

		if string.find(model, "../", 1, true) then
			ply:SendLua([[notification.AddLegacy( "The model path goes up in the folder tree.", NOTIFY_ERROR, 10 )]])
			ply:SendLua([[surface.PlaySound("ambient/alarms/klaxon1.wav")]])
			return true
		end

		return false
	end

	hook.Add("PlayerSpawnObject", "APAModelBypassFix", function(ply, model)
		if APA.ModelBypassFix( ply, model ) then
			return false
		end
	end)
	---------------
	hook.Add("PlayerSpawnProp", "APAModelBypassFix_", function(ply, model)
		if APA.ModelBypassFix( ply, model ) then
			return false
		end
	end)

	hook.Add("PlayerInitialSpawn", function( ply ) timer.Simple(3.5, function() ply:ChatPrint("This server is running APAnti by LuaTenshi.") end) end)
	-- Is it bad if I want to let people know that the server is running my addon?

	MsgAll("\n<|||APAnti Is Now Running!|||>\n")
	hook.Remove("PlayerConnect", "APAnti-Execution-Hook")
end

hook.Add("PlayerConnect", "APAnti-Execution-Hook", function() MsgAll("\n<|||APAnti Is Loading...|||>\n") timer.Simple( 0.5, function() APAntiLoad() end ) end)


--- Manual ---

if SERVER then
	concommand.Add( "apa_help", function()
		print("\n\n-----[A2PK Help]-----\n")
		
print([[apa_antipk :: Setting this to 1 will enable Anti Prop Kill, setting it to 0 will disable it!)

[COMING SOON] apa_alertadmins :: Setting this to 1 will alert admins when a player hits another player with a prop. Setting it to 0 will disable it.) - COMING SOON

[COMING SOON] apa_alertadmins_threshold :: How much damage should the prop do for admins to be notified. (Default: 80) (Requires: APA.Settings.AlertAdmins to be enabled.)) - COMING SOON

apa_antipk_punish :: Setting this to 1 will hurt the person who through the prop!)

apa_vehiclesdonthurt :: Setting this to 1 will stop vehicles from doing damage.)

apa_blockexplosions :: Setting this to 1 will block explosions, setting it to 0 will disable it!)

apa_nocollidevehicles :: Setting this to 1 will make vehicles not collide with players.)

apa_antipush :: Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!)

apa_apcollision :: Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: apa_antipush to be set to 1!))

apa_ghostonspawn :: Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!)

apa_nerf :: Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally. Note: Setting physgun_maxSpeed to 400 (Default: 5000), will make this work better, and limmit how fast people can move props with their physgun.)

apa_fpp_autoblock :: Setting this to true will attempt to automatically block huge props, setting this to false will disable it! (Requires: Falco's Prop Protection!))

apa_fpp_absize :: How big a prop should be before it is blocked. (Requires: apa_fpp_autoblock to be set to 1!))

apa_fpp_sounds :: Setting this to 1 will make an error sound, when a prop is autoblocked.)

apa_blacklist :: Set to 1 to enable the Blacklist, and to 0 to disable it!)

apa_whitelist :: Set to 1 to enable the Whitelist, and to 0 to disable it!)

apa_nocollideweapons :: Set to 1 to make weapons not collide with any thing except the world, and set to 0 to make weapons collide like normal.)

apa_autofreeze :: Set to 1 to automatically freeze props over time, and set to 0 to disable. (Requires: Map restart.))

apa_autofreeze_time :: How long to wait before freezing all props. (Default: 300) (Requires: apa_autofreeze to be set to 1!))]])

		print("---[A2PK Help End]---\n\n")
	end )
end

-- hook.Add("EntityTakeDamage","__ap",function(t,d) if( d:GetAttacker():GetClass() == "prop_physics" or d:GetInflictor():GetClass() == "prop_physics" ) then d:SetDamage(0) end end)
-- hook.Add( "PlayerSpawnedProp", "__ex", function( _, _, p ) if( p and IsValid(p) ) then p:SetKeyValue("ExplodeDamage", "0") p:SetKeyValue("ExplodeRadius", "0") end end)
-- If you want a simple anti prop kill to run in "ulx luarun" use the code above.