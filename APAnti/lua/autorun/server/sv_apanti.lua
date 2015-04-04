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
APA.Settings.DamageReturn = 0
APA.Settings.DamageReturnThreshold = 15 -- The amount of damage the prop must do before the owner of that prop starts getting hurt. (Requires: APA.Settings.DamageReturn to be enabled.)
-- Setting this to 1 will alert admins when some one attempts to prop kill. (Currently broken but will be available soon.)
APA.Settings.AlertAdmins = 0
APA.Settings.AlertAdminsThreshold = 80 -- The amount of damage the prop must do before the admins are alerted. (Requires: APA.Settings.AlertAdmins to be enabled.)
-- Setting this to 1 will stop vehicles from doing damage.
APA.Settings.VehiclesDontHurt = 1
-- Setting this to 1 will block explosions, setting it to 0 will disable it!
APA.Settings.BlockExplosions = 1
-- Setting this to 1 will make vehicles not collide with players.
APA.Settings.NoCollideVehicles = 1
-- Setting this to 1 will enable Anti Prop Push, setting it to 2 will nocolide props passively, while setting it to 0 will disable it!
APA.Settings.AntiPush = 2
-- Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: APA.Settings.AntiPush to be enabled!)
APA.Settings.APCollision = 1 --(Requires: APA.Settings.AntiPush to be enabled!)
-- Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!
APA.Settings.GhostOnSpawn = 1
-- Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally.
APA.Settings.Nerf = 3 -- Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally. 
-- Setting this to 2 will also set physgun_maxSpeed to 415 (Default: 5000).
APA.Settings.FPP.AutoBlock = 1 -- (Requires: Falco's Prop Protection!)
APA.Settings.FPP.ABSize = 7.35 --How big a prop should be before it is blocked. (Requires: RemoveBig to be set to 1!)
APA.Settings.FPP.Sounds = 0 --Setting this to 1 will make an error sound, when a prop is autoblocked. (Requires: AutoBlock to be set to 1!)
-- Set to 1 to enable the Blacklist, and to 0 to disable it!
APA.Settings.Blacklist = 1
-- Set to 1 to enable the Whitelist, and to 0 to disable it!
APA.Settings.Whitelist = 1
-- Set to 1 to make weapons not collide with any thing except the world, and set to 0 to make weapons collide like normal.
APA.Settings.NoCollideWeapons = 0
-- Set to 1 to automatically freeze props when they are dropped, and set to 0 to disable.
APA.Settings.ForceFreeze = 0
-- Set to 1 to automatically freeze props over time, and set to 0 to disable. (Requires: Map restart.)
APA.Settings.AutoFreeze = 0
-- How long to wait before freezing all props. (Default: 300) (Requires: apa_autofreeze to be set to 1!)
APA.Settings.AutoFreezeTime = 300
-- Should a prop that hits a player be frozen?
APA.Settings.DamageFreeze = 1
-- Should we allow gm_spawn (using keybinds)?
APA.Settings.AllowGMSpawn = 0

--------------------------
APA.AddonLoaded = false -- Do not change this.
--------------------------

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add props that you do not want to be auto removed, below.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local AllowedHBigProps = {}

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
	"lamp",
	"playx",
	"lawboard",
	"fadmin",
	"jail",
	"prop",
	"wire"
}

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- This Whitelist will allow the Anti Prop Kill to ignore things that it would normally detect.
-- Add things using their partial or full class names.
-- Make sure to never change this text " local ClassWhitelist = { ", and use the preset below as an example.
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local ClassWhitelist = {
	"knife", -- This should allow throwing knives to do damage.
	"prop_combine_ball", -- Should avoid problems with combine balls.
	"npc_tripmine", -- Should not be detected but added just incase.
	"npc_satchel" -- Ditto.
}


/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Added a damage black list, to cancle out the damage of entities that happen to return invalid or for some reason don't have a class.
----------------------------------------------------------------------------------------------------------------------------------------------------*/
local DamageBlackList = { DMG_CRUSH, DMG_SLASH, DMG_CLUB, DMG_DIRECT, DMG_PHYSGUN, DMG_VEHICLE }

/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Congradulations, you are now ready to start using this script on your server! If you get any errors please report them to me!
-- WARNING: Do not edit any thing below this line unless you know what you are doing!
----------------------------------------------------------------------------------------------------------------------------------------------------*/

--- Loading Console Vars ---

APA.Settings.AntiPK = CreateConVar("apa_antipk", APA.Settings.AntiPK, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will enable Anti Prop Kill, setting it to 0 will disable it!")
APA.Settings.AlertAdmins = CreateConVar("apa_alertadmins", APA.Settings.AlertAdmins, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will alert admins when a player hits another player with a prop. Setting it to 0 will disable it.")
APA.Settings.AlertAdminsThreshold = CreateConVar("apa_alertadmins_threshold", APA.Settings.AlertAdminsThreshold, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How much damage should the prop do for admins to be notified. (Default: 80) (Requires: APA.Settings.AlertAdmins to be enabled.)")
APA.Settings.DamageReturn = CreateConVar("apa_antipk_punish", APA.Settings.DamageReturn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will hurt the owner of the prop that did damage! (WARNING: This may be abused. Players may launch other peoples props at them selves thus killing innocents.)")
APA.Settings.DamageReturnThreshold = CreateConVar("apa_antipk_punish_threshold", APA.Settings.DamageReturnThreshold, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "The amount of damage the prop must do before the owner of that prop starts getting hurt. (Requires: APA.Settings.DamageReturn to be enabled.)")
APA.Settings.DamageFreeze = CreateConVar("apa_antipk_freeze", APA.Settings.DamageFreeze, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will freeze props when they hit a player, setting it to 0 will disable it!")
APA.Settings.AllowGMSpawn = CreateConVar("apa_gmspawn", APA.Settings.AllowGMSpawn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 0 will stop people from using gm_spawn binds, setting it to 1 will allow them to use gm_spawn binds.")
APA.Settings.VehiclesDontHurt = CreateConVar("apa_vehiclesdonthurt", APA.Settings.VehiclesDontHurt, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will stop vehicles from doing damage.")
APA.Settings.BlockExplosions = CreateConVar("apa_blockexplosions", APA.Settings.BlockExplosions, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will block explosions, setting it to 0 will disable it!")
APA.Settings.NoCollideVehicles = CreateConVar("apa_nocollidevehicles", APA.Settings.NoCollideVehicles, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make vehicles not collide with players.")
APA.Settings.AntiPush = CreateConVar("apa_antipush", APA.Settings.AntiPush, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will enable Anti Prop Push, setting it to 2 will nocolide props passively, while setting it to 0 will disable it!")
APA.Settings.APCollision = CreateConVar("apa_apcollision", APA.Settings.APCollision, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make props phase through players only, setting it to 0 will make props phase through every thing! (Requires: apa_antipush to be set to 1!)")
APA.Settings.GhostOnSpawn = CreateConVar("apa_ghostonspawn", APA.Settings.GhostOnSpawn, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it so that props are ghosted when they spawn, while setting it to 0 will disable it!")
APA.Settings.Nerf = CreateConVar("apa_nerf", APA.Settings.Nerf, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally. Setting this to 2 will also set physgun_maxSpeed to 415 (Default: 5000).")
APA.Settings.FPP.AutoBlock = CreateConVar("apa_fpp_autoblock", APA.Settings.FPP.AutoBlock, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to true will attempt to automatically block huge props, setting this to false will disable it! (Requires: Falco's Prop Protection!)")
APA.Settings.FPP.ABSize = CreateConVar("apa_fpp_absize", APA.Settings.FPP.ABSize, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How big a prop should be before it is blocked. (Requires: apa_fpp_autoblock to be set to 1!)")
APA.Settings.FPP.Sounds = CreateConVar("apa_fpp_sounds", APA.Settings.FPP.Sounds, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Setting this to 1 will make an error sound, when a prop is autoblocked.")
APA.Settings.Blacklist = CreateConVar("apa_blacklist", APA.Settings.Blacklist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Blacklist, and to 0 to disable it!")
APA.Settings.Whitelist = CreateConVar("apa_whitelist", APA.Settings.Whitelist, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to enable the Whitelist, and to 0 to disable it!")
APA.Settings.NoCollideWeapons = CreateConVar("apa_nocollideweapons", APA.Settings.NoCollideWeapons, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to make weapons not collide with any thing except the world, and set to 0 to make weapons collide like normal.")
APA.Settings.ForceFreeze = CreateConVar("apa_forcefreeze", APA.Settings.ForceFreeze, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to automatically freeze props when they are dropped, and set to 0 to disable.")
APA.Settings.AutoFreeze = CreateConVar("apa_autofreeze", APA.Settings.AutoFreeze, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Set to 1 to automatically freeze props over time, and set to 0 to disable. (Requires: Map restart.)")
APA.Settings.AutoFreezeTime = CreateConVar("apa_autofreeze_time", APA.Settings.AutoFreezeTime, {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "How long to wait before freezing all props. (Default: 300) (Requires: apa_autofreeze to be set to 1!)")

--- DONE ---

util.AddNetworkString("sMsgAdmins")
util.AddNetworkString("sNotifyHit")
util.AddNetworkString("sAlertNotice")
util.AddNetworkString("sMsgStandard")
util.AddNetworkString("sBlockGMSpawn")

local APAWorldEnts = {}
hook.Add( "InitPostEntity", "_APAGetWorldEnts", function()
	table.Empty( APAWorldEnts )
	APAWorldEnts = {} -- Make sure that the table is empty.
	-----------
	timer.Simple( 1.5, function()
		APA.AddonLoaded = false;
		for _,v in pairs(ents.GetAll()) do
			table.insert( APAWorldEnts, v )
		end
	end )
end )

local function APAntiLoad()

	APA.AddonLoaded = true -- This should now reload the script if the map changes.
	if not (CPPI and CPPI.GetVersion and CPPI.GetVersion()) then 
		MsgC( Color( 255, 0, 0 ), "ERROR: CPPI not found, Prop protection not installed?") 
		return 
	end
	-- This only works if we have CPPI, sorry.

	function APA.Notify(ply, str, ctype, time, alert)
		if alert >= 1 or tobool(alert) then alert = 1 end
		---------------------------------
		if not ply then return end
		if not ply:IsPlayer() then return end
		if not str then return end
		if not ctype then ctype = 1 end
		---------------------------------
		str = tostring(str) -- Make sure that its a string.
		ctype = tonumber(ctype) -- Make sure that its a number.
		time = tonumber(time)  -- Make sure that its a number.
		alert = tonumber(alert) -- Make sure that its a number.
		-----------------------
		if type(str) != "string" then return end -- Must have a string.
		if type(ctype) != "number" then ctype = 1 end -- Must be a number
		if type(time) != "number" then time = 1 end -- Must be a number
		if type(alert) != "number" then alert = 0 end -- Must be a number
		----------------
		net.Start("sAlertNotice")
			net.WriteString(str)
			net.WriteFloat(ctype)
			net.WriteFloat(time)
			net.WriteFloat(alert)
		net.Send(ply)
	end

	function APA.CMsg( str, color, plys )
		local plys = plys
		local color = color

		if not str then return end
		str = tostring(str) -- Must be a string.

		if type(plys) == "string" then 
			if plys == "all" then 
				plys = player.GetAll()
			elseif plys == "admins" then
				plys = {}
				for _,v in pairs(player.GetAll()) do
					if v:IsAdmin() or v:IsSuperAdmin() then
						table.insert(plys,v)
					end
				end
			elseif plys == "super" then
				plys = {}
				for _,v in pairs(player.GetAll()) do
					if v:IsSuperAdmin() then
						table.insert(plys,v)
					end
				end
			end
		end

		if type(plys) != "table" then return end
		if type(color) != "table" then return end
		for _,ply in pairs(plys) do
			net.Start("sMsgStandard")
				net.WriteString(str)
				net.WriteTable(color)
			net.Send(ply)
		end
	end

	function APA.AMsg( tb, ply )
		if not tb then return end
		if not type(tb) == "table" then return end

		if not tb.aname then return end
		if not tb.asteam then return end
		if not tb.tname then return end
		if not tb.tsteam then return end

		local an,as,tn,ts = tostring(tb.aname), tostring(tb.asteam), tostring(tb.tname), tostring(tb.tsteam)

		net.Start("sMsgAdmins")
			net.WriteString(an)
			net.WriteString(as)
			net.WriteString(tn)
			net.WriteString(ts)
		net.Send(ply)
	end

	function APA.DMsg( strt, dmg )
		local t = strt
		if not t then return end
		if not type(t) == "table" then return end

		if not t.aname then return end
		if not t.asteam then return end
		if not t.tname then return end
		if not t.tsteam then return end

		local an,as,tn,ts = tostring(t.aname), tostring(t.asteam), tostring(t.tname), tostring(t.tsteam)

		net.Start("sNotifyHit")
			net.WriteString(an)
			net.WriteString(as)
			net.WriteString(tn)
			net.WriteString(ts)
		net.Broadcast()
		
		local strs = string.format("A prop belonging to %s[%s] has hit %s[%s]!", an, as, tn, ts)
		strs = string.format(strs:gsub( "%%", "<p>" ))
		ServerLog(strs) -- Log to server.

		-- Admin alerts below this line.
		if dmg >= APA.Settings.AlertAdminsThreshold:GetInt() then
			if APA.Settings.AlertAdmins:GetInt() >= 2 then
				for _,v in pairs(player.GetAll()) do
					if v and v:IsSuperAdmin() then
						APA.AMsg( t, ply )
					end
				end
			elseif APA.Settings.AlertAdmins:GetInt() == 1 then
				for _,v in pairs(player.GetAll()) do
					if v and ( v:IsSuperAdmin() or v:IsAdmin() ) then
						APA.AMsg( t, ply )
					end
				end
			end
		end
	end

	-- WARNINGS --
	cvars.AddChangeCallback( "apa_antipk", function( _, _, val )
		if tonumber(val) <= 0 then
			APA.CMsg( "APAnti has been disabled!", Color(255,0,0), "admins" )
		else
			APA.CMsg( "APAnti has been enabled!", Color(0,255,0), "admins" )
		end
	end )

	cvars.AddChangeCallback( "apa_antipk_punish", function( _, _, val )
		if tonumber(val) >= 1 then
			APA.CMsg( "APA-DMG-WARN", Color(255,0,0), "admins" )
		end
	end )
	---- DONE ----

	function APA.FindOwner( ent )
		local owner = owner or nil
		local cppi = cppi or nil
		if ent.CPPIGetOwner and ent:CPPIGetOwner() then 
			cppi,_ = ent:CPPIGetOwner() 
		end
		owner = cppi or ent.FPPOwner or ent.Owner
		return owner
	end

	function APA.FindProp( atker, inflictor )
		if( atker:IsPlayer() ) then atker = inflictor end
		if( atker:IsPlayer() ) then return nil end
		return atker
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

		if( APA.Settings.Blacklist:GetInt() >= 1 ) then
			for _,v in pairs(ClassBlacklist) do
				if( string.find( string.lower(entClass), string.lower(v) ) ) then
					badEntity = true
				end
			end
		end

		if( APA.Settings.Whitelist:GetInt() >= 1 ) then
			for _,v in pairs(ClassWhitelist) do
				if( string.find( string.lower(entClass), string.lower(v) ) ) then
					goodEntity = true
				end
			end
		end

		return badEntity, goodEntity
	end

	local function APADamageFilter( dmginfo, atker, inflictor, badEntity, exeption )
		if APA.Settings.VehiclesDontHurt:GetInt() >= 1 and badEntity then
			if ( dmginfo:GetDamageType() == DMG_CRUSH or dmginfo:GetDamageType() == DMG_VEHICLE ) or atker:IsVehicle() or inflictor:IsVehicle() then -- Is a vehicle doing this?
				dmginfo:SetDamage(0)
				dmginfo:ScaleDamage(0)
				dmginfo:SetDamageForce(Vector(0,0,0))
				return dmginfo,true
			end
		end

		if APA.Settings.BlockExplosions:GetInt() == 2 and badEntity then -- Stop damage from explosives.
			if dmginfo:IsExplosionDamage() then -- Is this explosion damage?
				dmginfo:SetDamage(0)
				dmginfo:ScaleDamage(0)
				dmginfo:SetDamageForce(Vector(0,0,0))
				return dmginfo,true
			end
		end

		if ( exeption ) then
			dmginfo:SetDamage(0)
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamageForce(Vector(0,0,0))
			return dmginfo,true
		end

		return dmginfo,false
	end

	function APA.antiPk( target, dmginfo )
		if( APA.Settings.AntiPK:GetInt() >= 1 ) then

			local atker, inflictor, dmg = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()
			local daEnt = ( inflictor and IsValid(inflictor) and inflictor.GetClass ) and inflictor or ( atker and IsValid(atker) and atker.GetClass ) and atker or nil

			if ( daEnt and IsValid(daEnt) ) then

				local entClass = daEnt:GetClass()
				local badEntity, goodEntity = APA.EntityCheck( entClass )

				dmginfo,shouldexit = APADamageFilter( dmginfo, atker, inflictor, badEntity, false );
				if shouldexit then return true end

				if ( dmginfo:GetDamageType() == DMG_CRUSH or badEntity ) and !( atker:IsVehicle() or inflictor:IsVehicle() ) and !goodEntity then

					local strt = {}; strt.aname = "<N/A>"; strt.asteam = "<N/A>"; strt.tname = "<N/A>"; strt.tsteam ="<N/A>";
					atker, inflictor, dmg = dmginfo:GetAttacker(), dmginfo:GetInflictor(), dmginfo:GetDamage()
					-- Reconfirm...

					dmginfo:SetDamage(0)
					dmginfo:ScaleDamage(0)
					dmginfo:SetDamageForce(Vector(0,0,0))

					atker = APA.FindKiller( atker, inflictor )
					if( atker and IsValid(atker) and atker:IsPlayer() and target and IsValid(target) and target:IsPlayer() ) then
						if(atker != target) then
							if( !atker.APAWarned ) then
								strt.aname = atker:GetName(); strt.asteam = atker:SteamID(); strt.tname = target:GetName(); strt.tsteam = target:SteamID();
								-------------------------------
								APA.DMsg( strt, dmg  )
								atker.APAWarned = true
								timer.Simple(0.25, function() atker.APAWarned = false end) --Removing console spam.
							end

							if APA.Settings.DamageFreeze:GetInt() >= 1 then
								if dmg >= APA.Settings.DamageReturnThreshold:GetInt() then
									ent = APA.FindProp( atker, inflictor )
									if( ent and IsValid(ent) ) then
										local phys = ent:GetPhysicsObject()
										if phys then phys:EnableMotion(false) end
									end
								end
							end

							if APA.Settings.DamageReturn:GetInt() >= 1 then
								if dmg >= APA.Settings.DamageReturnThreshold:GetInt() then
									timer.Create( "__APADamageReturn", 0.25, 1, function() atker:TakeDamage( dmg, atker, atker ) end) --I hope the return to sender works now.
									--									|_ We delay by a quarter of a second to stop the script from doing double damage or hurting the wrong player.
								end
							end
						end
					end

					return true
				end
			elseif ( table.HasValue( DamageBlackList, dmginfo:GetDamageType() ) ) then
				dmginfo,shouldexit = APADamageFilter( dmginfo, atker, inflictor, nil, true )
				if shouldexit then return true end
			end
		end
	end
	hook.Add( "EntityTakeDamage", "APAntiPk", APA.antiPk )

	---Block-Explosions---

	hook.Add( "PlayerSpawnedProp", "APAntiExplode", function( _, _, prop )
		if( prop and IsValid(prop) and APA.Settings.BlockExplosions:GetInt() >= 1 ) then
			if not string.find( string.lower(prop:GetClass()), "wire" ) then -- Quick fix for wiremod.
				prop:SetKeyValue("ExplodeDamage", "0") 
				prop:SetKeyValue("ExplodeRadius", "0")
			end
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
		if ent:CreatedByMap() then return true end
		if table.HasValue(APAWorldEnts, ent) then return true end

		local blacklist = {"func_", "env_", "info_"}
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

		if APA.Settings.Nerf:GetInt() >= 3 and ( ent and ent.GetPhysicsObject and ent.GetClass ) then
			if ent:GetClass() == "prop_physics" then
				local phys = ent:GetPhysicsObject();
				if phys and IsValid(phys) then phys:SetMass(0.5); end
			end
		end
		
		if o:IsPlayer() then if ( o == picker or cp ) then return true end end
	end

	function APA.Ghost.Force( ent )
	-- Used for ghosting a prop when it spawns in theory we could have FPPs anti-spam take care of this but this lets people build without their console getting spammed with "your prop has been ghosted".
		if( ent:IsValid() and !ent:IsPlayer() and not APA.IsWorld( ent ) ) then
			ent.APGhost = true
			
			local oColGroup = ent:GetCollisionGroup()
			ent.OldCollisionGroup = ent.OldCollisionGroup or oColGroup or 0

			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:DrawShadow(false)
			ent.OldColor = ent.OldColor or ent:GetColor()
			ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70))

			if not ( oColGroup == COLLISION_GROUP_WEAPON or oColGroup == COLLISION_GROUP_WORLD ) then
				if( APA.Settings.APCollision:GetInt() >= 1 ) then
					ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					ent.CollisionGroup = COLLISION_GROUP_WEAPON
				else
					ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
					ent.CollisionGroup = COLLISION_GROUP_WORLD
				end
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
					
					local oColGroup = ent:GetCollisionGroup()
					ent.OldCollisionGroup = ent.OldCollisionGroup or oColGroup or 0

					ent:SetRenderMode(RENDERMODE_TRANSALPHA)
					ent:DrawShadow(false)
					ent.OldColor = ent.OldColor or ent:GetColor()
					ent:SetColor(Color(255, 255, 255, ent.OldColor.a - 70)) -- Make the prop slightly faded to show that its ghosted.

					if not ( oColGroup == COLLISION_GROUP_WEAPON or oColGroup == COLLISION_GROUP_WORLD ) then
						if( APA.Settings.APCollision:GetInt() >= 1 ) then
							ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
							ent.CollisionGroup = COLLISION_GROUP_WEAPON
						else
							ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
							ent.CollisionGroup = COLLISION_GROUP_WORLD
						end
					end

					ent.APNoColided = true
				end
			end
		end
	end

	function APA.Ghost.CanOff( ent )
		local mins, maxs = ent:LocalToWorld(ent:OBBMins()), ent:LocalToWorld(ent:OBBMaxs())
		local cube = ents.FindInBox( mins+Vector(-25,-25,-25), maxs+Vector(25,25,25) )
		local owner = false, nil

		if APA.Settings.AntiPush:GetInt() >= 1 then owner = APA.FindOwner( ent ) end

		for _,v in pairs(cube) do
			local PhysObj = v:GetPhysicsObject()
			local canGetModel = false; if v:GetModel() ~= nil then canGetModel = true end
			local vV, mV = false, (IsValid(v) and canGetModel and v ~= ent), (PhysObj and PhysObj:IsValid() and PhysObj:IsMotionEnabled())
			if( (vV and mV) and IsValid(APA.FindOwner(v)) or v:IsPlayer() or v:IsNPC() ) then
				if v:GetClass() == "prop_physics" and (APA.FindOwner(v) == APA.FindOwner(ent)) then return true end
				if not ent.APAIsObscured then
					if APA.Settings.AntiPush:GetInt() >= 1 then APA.Notify(owner, "Prop Obscured!", NOTIFY_ERROR, 2, 0) end
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

				if ent.GetPhysicsObject then
					local phys = ent:GetPhysicsObject()
					if( phys and IsValid(phys) ) then
						phys:AddAngleVelocity( phys:GetAngleVelocity() * -1 )
						phys:SetVelocityInstantaneous( Vector(0,0,0) )
						if APA.Settings.ForceFreeze:GetInt() >= 1 then phys:EnableMotion(false) end
					end
				end

				if ent.OldColor then ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a)) end
				ent.OldColor = nil

				if ent.OldCollisionGroup then
					ent:SetCollisionGroup(ent.OldCollisionGroup)
					ent.CollisionGroup = ent.OldCollisionGroup
				end; ent.OldCollisionGroup = nil

				ent.APNoColided = false
			end
		end
	end

	--ANTI-TRAP--
	timer.Create( "APAntiPropPush-EntityScanner", 0.3, 0, function()
		for _,ent in pairs(ents.GetAll()) do
			if (ent:IsWeapon() or ent:GetClass() == "spawned_weapon") and APA.Settings.NoCollideWeapons:GetInt() >= 1 then
				ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
				ent.CollisionGroup = COLLISION_GROUP_WORLD
			end
			--------------
			if ent:IsVehicle() then
				if APA.Settings.NoCollideVehicles:GetInt() >= 1 and not ent.APNoColided then
					ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					ent.CollisionGroup = COLLISION_GROUP_WEAPON
					ent.APNoColided = true
				end
			else	--------------------
				if ent.APGhostOff or APA.Settings.AntiPush:GetInt() >= 1 then
					if ent.APGhostOff then
						local MotionEnabled, PhysObj = false, ent:GetPhysicsObject(); if( IsValid(PhysObj) ) then MotionEnabled = PhysObj:IsMotionEnabled() end
						if APA.Settings.AntiPush:GetInt() >= 2 then
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
	
	if APA.Settings.AutoFreezeTime:GetInt() < 60 then APA.Settings.AutoFreezeTime = 60 end
	timer.Create( "APAntiAutoFreezeTimer", APA.Settings.AutoFreezeTime:GetInt(), 0, function() 
		if APA.Settings.AutoFreeze:GetInt() >= 1 then
			for _,ent in pairs(ents.FindByClass("prop_physics")) do
				if ent and IsValid(ent) and ent.GetPhysicsObject then
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:EnableMotion(false)
					end
				end
			end
		end
	end)

	--Check Vehicle Spawn--
	hook.Add("PlayerSpawnedVehicle", "APA.VehicleSpawnCheck", function( _, ent ) 
		if APA.Settings.NoCollideVehicles:GetInt() >= 1 and ( ent.IsVehicle and ent:IsVehicle() ) then
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
		if( APA.CanPickup( picker, ent ) and picker != ent ) then
			if APA.Settings.AntiPush:GetInt() <= 0 then APA.Ghost.Off( picker, ent, true ) end -- Unghost props a little faster.
			ent.APGhostOff = true
			-----------
			if APA.Settings.ForceFreeze:GetInt() >= 1 and IsValid(ent) and not ( ent:IsPlayer() or ent:IsNPC() ) then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then phys:EnableMotion(false) end
			end
		end
	end)

	--PHYSGUN-PICKUP--
	hook.Add( "PhysgunPickup", "APAntiPropPush-Pickup", function( picker, ent )
		if( APA.Settings.AntiPush:GetInt() >= 1 ) then
			if( APA.CanPickup( picker, ent ) and picker != ent ) then
				APA.Ghost.On( picker, ent, true )
				ent.APGhostOff = false
			end
		end
	end)

	--PHYSGUN-THROW-NERF--
	if APA.Settings.Nerf:GetInt() >= 2 and APA.Settings.Nerf:GetInt() < 4 then RunConsoleCommand( "physgun_maxSpeed", 415 ) end

	cvars.AddChangeCallback( "apa_nerf", function( _, _, val )
		if tonumber(val) >= 2 then RunConsoleCommand( "physgun_maxSpeed", 415 ) end
	end )

	hook.Add( "PhysgunDrop", "APAntiPropPush-Nerf", function( _, ent )
		if APA.Settings.Nerf:GetInt() >= 1 then
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
		if IsValid(ent) and APA.Settings.GhostOnSpawn:GetInt() >= 1 then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				APA.Ghost.Force( ent )
				ent.APGhostOff = false
			end
		end
	end)

	--Block GMSpawn
	hook.Add("Move", "_APA.Settings.AllowGMSpawn", function( ply )
		if APA.Settings.AllowGMSpawn:GetInt() >= 1 then
			net.Start("sBlockGMSpawn")
				net.WriteFloat(tonumber(APA.Settings.AllowGMSpawn:GetInt()))
			net.Send(ply)
		end
	end)

	hook.Add("PlayerSpawnObject", "_APA.Settings.AllowGMSpawn", function( ply )
		if APA.Settings.AllowGMSpawn:GetInt() >= 1 then
			net.Start("sBlockGMSpawn")
				net.WriteFloat(tonumber(APA.Settings.AllowGMSpawn:GetInt()))
			net.Send(ply)
		end
	end)

	-- Change DarkRP prop handeling.

	function APA.ModelNameFix( model )
		local model = model or ""
		model = tostring(model) -- Maybe redundent but we want to make sure that this is a string.
		model = string.lower(model)
		model = string.Replace(model, "\\", "/") -- Thoes backwards slashes always trying to confuse the situation.
		model = string.Replace(model, " ", "_") -- Model names do not have spaces, stop asking.
		model = string.Replace(model, ";", "") -- ; may be used to escape so we are removing it.
		----------
		model = string.gsub(model, "[\\/]+", "/")
		----------
		return model
	end

	--- I dont like huge props | Default big props math.pow(10, 5.85) or 707945.784384 ---
	hook.Add("PlayerSpawnedProp", "_APA.Settings.FPP.AutoBlock", function(ply,mdl,ent)
		if APA.Settings.FPP.AutoBlock:GetInt() >= 1 then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:GetVolume() ) then
				local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
				if ( phys:GetVolume() > math.pow(10,APA.Settings.FPP.ABSize:GetInt()) ) then
					mdl = APA.ModelNameFix( mdl ) --Just in case.
					if not table.HasValue(AllowedHBigProps, mdl) then
						if( mdl and ( type(FPP) == "table" ) ) then --This will only work if you have Falco's Prop Protection!
							RunConsoleCommand( "FPP_AddBlockedModel", mdl )
						end
						if( ply:IsValid() ) then 
							ply:ChatPrint("That prop is now blocked, thanks!")
							APA.Notify(owner, "That prop is now blocked, thanks!", NOTIFY_ERROR, 10, tonumber(APA.Settings.FPP.Sounds:GetInt()))
						end
						if( ent:IsValid() ) then ent:Remove() end
					end
				end
			end
		end
	end)

	local function isBlocked(model)
		if FPP && type(FPP) == "table" && FPP.Settings && type(FPP.Settings) == "table" then
			local found = FPP.BlockedModels[model]
			if tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and not found then
				-- Prop is not in the white list
				return true
			elseif not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and found then
				-- prop is in the black list
				return true
			end
		end

		return false
	end

	local function APAPropSpawnEvent(ply, model)
		local model = APA.ModelNameFix( model );
		local arrested, APAblocked = false, isBlocked(model);

		if ply.isArrested && type(ply.isArrested) == "function" then arrested = ply:isArrested() end

		if ply.jail or ply.frozen or ply:IsFrozen() or arrested then
			APA.Notify(ply, "Sorry, you can't do that right now.", NOTIFY_ERROR, 10, 1)
			model = ""; return false
		end

		if APAblocked then
			APA.Notify(ply, "That model seems to be blocked, sorry.", NOTIFY_ERROR, 10, 1)
			model = ""; return false
		end
	end

	hook.Add("PlayerSpawnObject", "_APAModelBypassFix_", APAPropSpawnEvent)
	hook.Add("PlayerSpawnProp", "_APAModelBypassFix_", APAPropSpawnEvent)
	hook.Add("PlayerSpawnedEffect", "_APAModelBypassFix_", APAPropSpawnEvent)
	hook.Add("PlayerSpawnedRagdoll", "_APAModelBypassFix_", APAPropSpawnEvent)
	hook.Add("PlayerSpawnSENT", "_APAModelBypassFix_", APAPropSpawnEvent)
	hook.Add("PlayerSpawnVehicle", "_APAModelBypassFix_", APAPropSpawnEvent)

	MsgAll("\n<|||APAnti Is Now Running!|||>\n")
	APA.AddonLoaded = true -- This should now reload the script if the map changes.
end

hook.Add("PlayerConnect", "APAnti-Execution-Hook", function() -- Contrary to other addons, this loads when the first player connects.
	if not APA.AddonLoaded then
		if #player.GetAll() <= 1 then
			MsgAll("\n<|||APAnti Is Loading...|||>\n")
			APAntiLoad()
		end
	end
end)

hook.Add("PostGamemodeLoaded", "APAnti-ReloadOnMap", function() 
	APA.AddonLoaded = false; APAntiLoad(); 
end)

concommand.Add( "apa_help", function() 
	print( file.Read( "apa_help.txt", "DATA" ) )
end, _, _, FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE )

-- concommand.Add("j", function() APAntiLoad() end)

-- hook.Add("EntityTakeDamage","__ap",function(t,d) if( d:GetAttacker():GetClass() == "prop_physics" or d:GetInflictor():GetClass() == "prop_physics" or d:GetDamageType() == DMG_CRUSH ) then d:SetDamage(0) d:ScaleDamage(0) end end)
-- hook.Add( "PlayerSpawnedProp", "__ex", function( _, _, p ) if( p and IsValid(p) ) then p:SetKeyValue("ExplodeDamage", "0") p:SetKeyValue("ExplodeRadius", "0") end end)
-- hook.Add( "PhysgunDrop", "__dr", function( _, e ) if e and IsValid(e) then local p = e:GetPhysicsObject() if p and IsValid(p) then p:SetVelocityInstantaneous( Vector(0,0,0) ) end end end)
-- If you want a simple anti prop kill to run in "ulx luarun" use the code above.