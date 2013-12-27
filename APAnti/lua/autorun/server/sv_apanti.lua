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
-- Setting this to 1 will block some explosive barrels, while setting it to 0 will disable it!
APA.Settings.BlockExplosions = 1
-- Setting this to 1 will enable Anti Prop Push, setting it to 2 will make this also check constrains, while setting it to 0 will disable it!
APA.Settings.AntiPush = 0
-- Setting this to 1 (or lower) will make props phase through players only, setting it to 2 will make props phase through every thing! (Requires: APA.Settings.AntiPush to be enabled!)
APA.Settings.APCollision = 1 --(Requires: APA.Settings.AntiPush to be enabled!)
-- Setting this to true will make it so that props are ghosted when they spawn, while setting it to false will disable it!
APA.Settings.GhostOnSpawn = true
-- Setting this to 1 will make it impossible to fling props, while setting it to 0 will allow you to fling props normally.
APA.Settings.Nerf = 0
-- Setting this to true will attempt to automatically block huge props, setting this to false will disable it! (Requires: Falco's Prop Protection!)
APA.Settings.FPP.AutoBlock = true
APA.Settings.FPP.ABSize = 5.85 --How big a prop should be before it is blocked.
-- Set to true to enable the Blacklist, and to false to disable it!
APA.Settings.Blacklist = true
-- Set to true to enable the Whitelist, and to false to disable it!
APA.Settings.Whitelist = false

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

local function APAntiLoad()
	function APA.FindOwner( ent )
		local owner = owner or nil
		local cppi,_ = ent:CPPIGetOwner()
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
			
			if( APA.Settings.Blacklist ) then
				for _,v in pairs(ClassBlacklist) do
					if( string.find( string.lower(entClass), string.lower(v) ) ) then
						badEntity = true
					end
				end
			end
			
			if( APA.Settings.Whitelist ) then
				for _,v in pairs(ClassWhitelist) do
					if( string.find( string.lower(entClass), string.lower(v) ) ) then
						goodEntity = true
					end
				end
			end
			
			if ( dmginfo:GetDamageType() == DMG_CRUSH or badEntity ) and !goodEntity then
				local atker = dmginfo:GetAttacker()
				local inflictor = dmginfo:GetInflictor()
				local dmg = dmginfo:GetDamage()

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

	---Block-Some-Explosions---
	
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
			local plyEnt = APA.FindOwner( ent )		local picker = picker
			if( plyEnt ~= nil and (plyEnt:IsValid() and plyEnt:IsPlayer()) ) then
				if( spoof or ( ( plyEnt == picker ) or ( picker:IsAdmin() or picker:IsSuperAdmin() ) ) ) then
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
		for _,v in pairs(cube) do 
			if( ( IsValid(v) and v:GetModel() and v != ent ) and ( v:GetClass() != "physgun_beam" and !v:IsWorld() ) ) then
				local PhysObj = v:GetPhysicsObject()
				if( IsValid(PhysObj) ) then
					if( PhysObj:IsMotionEnabled() ) then
						return false
					end
				else
					return false
				end
			end 
		end
		return true
	end

	function APA.Ghost.Off( picker, ent, spoof )
		if( APA.Ghost.CanOff( ent ) ) then
			if( ent.APGhost and (ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld()) ) then
				local plyEnt = APA.FindOwner( ent )		local picker = picker
				if( spoof or ( ( plyEnt == picker ) or ( picker:IsAdmin() or picker:IsSuperAdmin() ) ) ) then
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
	
	--PHYSGUN-DROP--
	/*
	-- Perhapse a better method of checking if a prop needs unghosting.
	hook.Add( "PhysgunDrop", "APAntiPropPush-Drop", function( picker, ent ) -- We always want to unghost props if they are ghosted.
		if( !ent.APGhostOff ) then
			APA.Ghost.Off( picker, ent, false )
			ent.APGhostOff = true
		end
	end)
	*/
	
	hook.Add( "PhysgunDrop", "APAntiPropPush-Drop", function( picker, ent ) -- We always want to unghost props if they are ghosted.
		if( ( !ent:IsPlayer() and !ent:IsNPC() ) and picker != ent ) then
			APA.Ghost.Off( picker, ent, false )
			ent.APGhostOff = true
		end
	end)
	
	---Physgun-Stuff---
	
	if( APA.Settings.AntiPush >= 1 ) then
	
		--ANTI-TRAP--
		hook.Add( "Think", "APAntiPropPush-AntiTrap", function()
			if( APA.Settings.AntiPush >= 1 ) then
				for _,ent in pairs(ents.GetAll()) do
					if ent.APGhostOff then
						local MotionEnabled = false;local PhysObj = ent:GetPhysicsObject();if( IsValid(PhysObj) ) then MotionEnabled = PhysObj:IsMotionEnabled() end
						if (ent:GetVelocity():Distance( Vector( 0.1, 0.1, 0.1 ) ) > 0.2 and MotionEnabled) then
							APA.Ghost.On( nil, ent, true )
						end
						if ( ( ent:GetVelocity():Distance( Vector( 0.1, 0.1, 0.1 ) ) <= 0.2 or !MotionEnabled ) and ent.APGhost ~= nil ) then
							if APA.Ghost.CanOff( ent ) then
								APA.Ghost.Off( nil, ent, true ) 
							end
						end
					end
				end
			end
		end)
		
		--Property-Setting-Fix--
		hook.Add("CanProperty", "APA.CanPropertyFix", function( _, property, ent )
			if( tostring(property) == "collision" and ent.APNoColided ) then return false end
		end)
		
		--PHYSGUN-PICKUP--
		hook.Add( "PhysgunPickup", "APAntiPropPush-Pickup", function( picker, ent )
			if( APA.Settings.AntiPush >= 1 ) then
				if( ( !ent:IsPlayer() and !ent:IsNPC() ) and picker != ent ) then
					APA.Ghost.On( picker, ent, false )
					ent.APGhostOff = false
				end
			end
		end)
		
	end
	
	--PHYSGUN-THROW-NERF--
	if APA.Settings.Nerf >= 1 then
		hook.Add( "PhysgunDrop", "APAntiPropPush-Nerf", function( _, ent )
			if APA.Settings.Nerf >= 1 then
				if( ent and (ent:IsValid() and !ent:IsPlayer() and !ent:IsWorld()) and ent:GetPhysicsObject() and ent:GetPhysicsObject():IsMotionEnabled() ) then 
					ent:GetPhysicsObject():EnableMotion( false )
					timer.Simple(0.1, function() ent:GetPhysicsObject():EnableMotion( true ) end)
				end
			end
		end)
	end
	
	
	--Ghost Props On Spawn:
	if APA.Settings.GhostOnSpawn then
		hook.Add("PlayerSpawnedProp", "_APA.AntiSpam.PropSafeSpawn", function(_, _, ent)
			if IsValid(ent) and APA.Settings.GhostOnSpawn then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					APA.Ghost.Force( ent )
					ent.APGhostOff = false
				end
			end
		end)
	end

	---I dont like huge props | Default big props math.pow(10, 5.85) or 707945.784384 & math.pow(3.23, 5.85) or 952.433704327---
	if APA.Settings.FPP.AutoBlock then
		hook.Add("PlayerSpawnedProp", "APA.Settings.FPP.AutoBlock", function(ply,mdl,ent)
			if APA.Settings.FPP.AutoBlock then
				if ( ent:GetPhysicsObject() and ent:GetPhysicsObject():GetVolume() ) then
					local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
					if ( ent:GetPhysicsObject():GetVolume() > math.pow(10,APA.Settings.FPP.ABSize) ) or ( mins:Distance(maxs) > math.pow(3.23,APA.Settings.FPP.ABSize) ) then
						if( mdl and ( type(FPP) == "table" ) ) then --This will only work if you have Falco's Prop Protection!
							mdl = string.Replace(string.Replace(string.Replace( mdl, "\\", "/" ), "\"", ""), ";", "") --Just in case.
							RunConsoleCommand( "FPP_AddBlockedModel", mdl ) 
						end
						if( ply:IsValid() ) then ply:ChatPrint("That prop is now blocked, thanks. ;)") end
						if( ent:IsValid() ) then ent:Remove() end
					end
				end
			end
		end)
	end
	
	MsgAll("\n<|||APAnti Is Now Running!|||>\n")
	hook.Remove("PlayerConnect", "APAnti-Execution-Hook")
end

hook.Add("PlayerConnect", "APAnti-Execution-Hook", function() MsgAll("\n<|||APAnti Is Loading...|||>\n") timer.Simple( 0.5, function() APAntiLoad() end ) end)
