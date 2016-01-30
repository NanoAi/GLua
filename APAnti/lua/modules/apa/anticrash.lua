-- A Fork of https://github.com/Kefta/Entity-Crash-Catcher Most of the code left untouched. -- Friday, January 15, 2016 --

local has = AntiCrashCMDTable
local inworld = util.IsInWorld

hook.Add("OnEntityCreated", "APAAntiCrash", function(ent)
	if APA.Settings.AntiCrash:GetBool() then
		timer.Simple(0, function()
			if not IsValid(ent) then return end
			if ent.IsPlayer and ent:IsPlayer() then return end

			local pos = ent.GetPos and ent:GetPos()
			local phys = ent.GetPhysicsObject and ent:GetPhysicsObject() or nil
			local physpos = IsValid(phys) and phys.GetPos and phys:GetPos() or nil

			if IsValid(phys) and ((pos and not inworld(pos)) or (physpos and not inworld(physpos)) or 
				ent.GetClass and ent:GetClass() != "prop_ragdoll" and phys:HasGameFlag(FVPHYSICS_PENETRATING)) then
				phys:SetVelocityInstantaneous(Vector(0,0,0))
				phys:EnableMotion(false)
			end
		end)
	end
end)

local ents = ents
local util = util

local function KillVelocity( ent )
	if ( not IsValid( ent ) ) then return end
	
	local oldcolor = ent:GetColor() or Color( 255, 255, 255, 255 )
	local newcolor = Color( 255, 0, 255, 255 )

	if not ent:IsPlayer() then
		ent:SetColor( newcolor )
	end
	
	ent:SetVelocity( vector_origin )
	if ent:IsPlayer() then ent:SetVelocity(ent:GetVelocity()*-1) end
	
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local subphys = ent:GetPhysicsObjectNum( i )
		if ( IsValid( subphys ) ) then
			subphys:EnableMotion( false )
			subphys:SetMass( subphys:GetMass() * 20 )
			subphys:SetVelocity( vector_origin )
		end
	end
	
	timer.Simple( has.FreezeTime:GetFloat(), function()
		if ( not IsValid( ent ) ) then return end
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local subphys = ent:GetPhysicsObjectNum( i )
			if ( IsValid( subphys ) ) then
				subphys:SetMass( subphys:GetMass() / 20 )
				subphys:EnableMotion( true )
				subphys:Wake()
			end
		end
		
		ent:SetColor( oldcolor )
	end )
end

if ( has.VelocityHook:GetBool() or has.UnreasonableHook:GetBool() ) then
	local NextThink = 0
	
	local InvalidStrings =
	{
		["nan"] = true,
		["inf"] = true,
		["-inf"] = true,
		["-nan"] = true
	}
	
	hook.Add( "Think", "physics.Unreasonable", function()
		if ( NextThink > CurTime() ) then return end
		if not APA.Settings.AntiCrash:GetBool() then return end
		
		NextThink = CurTime() + has.ThinkDelay:GetFloat()
		
		local ents = ents.GetUnreasonables()
		local ent
		
		for i = 1, #ents do
			ent = ents[i]
			if ( IsValid( ent ) ) then
				if ( has.NaNCheck:GetBool() ) then
					local pos = ent:GetPos()
					if ( InvalidStrings[tostring( pos.x )] or InvalidStrings[tostring( pos.y )] or InvalidStrings[tostring( pos.z )] ) then
						ent:Remove()
						continue
					end
					local ang = ent:GetAngles()
					if ( InvalidStrings[tostring( ang.p )] or InvalidStrings[tostring( ang.y )] or InvalidStrings[tostring( ang.r )] ) then
						ent:Remove()
						continue
					end
				end

				if ( has.VelocityHook:GetBool() and ent ) then
					local velo = ent:GetVelocity():Length()
					if ( (ent:IsPlayer() and has.EffectPlayers:GetBool()) or not ent:IsPlayer() ) then
						if ( velo >= has.RemoveSpeed:GetFloat() or (ent._GCFreezeTimes and ent._GCFreezeTimes > 7) ) then
							local nick = ent:GetNWString( "nick", ent:GetClass() )
							
							if ent:IsPlayer() then
								ent:SetPos(vector_origin)
								ent:SetVelocity(ent:GetVelocity()*-1)
								ent:KillSilent()
							else
								ent:Remove()
							end

							local message = "[GS] Removed " .. nick .. " for moving too fast"
							ServerLog( message .. " (" .. velo .. ")\n" )
							if ( has.EchoRemove:GetBool() ) then
								for _,v in next, player.GetAll() do
									APA.Notify( v, message .. " (" .. velo .. ")", NOTIFY_GENERIC, 1.5, 0 )
								end
							end
						elseif ( velo >= has.FreezeSpeed:GetFloat() ) then
							ent:CollisionRulesChanged()
							local nick = ent:GetNWString( "nick", ent:GetClass() )
							local phys = ent.GetPhysicsObject and ent:GetPhysicsObject()

							KillVelocity( ent )
							ent._GCFreezeTimes = (ent._GCFreezeTimes or 0) + 1

							local message = "[GS] Froze " .. nick .. " for moving too fast"
							ServerLog( message .. " (" .. velo .. ") \n" )
							if ( has.EchoFreeze:GetBool() ) then
								for _,v in next, player.GetAll() do
									APA.Notify( v, message .. " (" .. velo .. ")", NOTIFY_GENERIC, 1.5, 0 )
								end
							end
						end
					end
				end
				
				if ( has.UnreasonableHook:GetBool() ) then
					local ang = ent:GetAngles()
					if ( not util.IsReasonable( ang ) ) then
						ent:SetAngles( ang.p % 360, ang.y % 360, ang.r % 360 )
					end
				
					local pos = ent:GetPos()
					if ( not util.IsReasonable( pos ) ) then
						if ( ent:IsPlayer() or ent:IsNPC() ) then
							ent:SetPos( vector_origin )
						else
							ent:Remove()
						end
					end

					if ( !(ent:IsPlayer() or ent:IsNPC()) and ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) ) then
						local vphys = ent:GetPhysicsObject()
						local pos, physpos = ent:GetPos(), IsValid(vphys) and vphys:GetPos()
						if (ent.__APAPhysgunHeld == {}) and IsValid(vphys) and (not vphys:IsAsleep()) and ((pos and not inworld(pos)) or (physpos and not inworld(physpos))) then
							vphys:SetVelocityInstantaneous(Vector(0,0,0))
							vphys:Sleep()
						end
					end
				end
			end
		end
	end )
end

local maxcoord = 15950
local maxangle = 15950
local mincoord = -maxcoord
local minangle = -maxangle

function util.IsReasonable( struct )
	if ( isvector( struct ) ) then
		if( struct.x >= maxcoord or struct.x <= mincoord or 
			struct.y >= maxcoord or struct.y <= mincoord or 
			struct.z >= maxcoord or struct.y <= mincoord ) then
			return false
		end
	elseif ( isangle( struct ) ) then
		if( struct.p >= maxangle or struct.p <= minangle or 
			struct.y >= maxangle or struct.y <= minangle or 
			struct.r >= maxangle or struct.r <= minangle ) then
			return false
		end
	else
		error( string.format( "Invalid data type sent into util.IsReasonable ( Vector or Angle expected, got %s )", type( struct ) ) )
	end
	
	return true
end

local UnreasonableEnts =
{
	[ "prop_physics" ] = true,
	[ "prop_ragdoll" ] = true
}

function ents.GetUnreasonables()
	local ParedEnts = {}
	local AllEnts = ents.GetAll()
	
	for i = 1, #AllEnts do
		if ( UnreasonableEnts[ AllEnts[i]:GetClass() ] or AllEnts[i]:IsPlayer() or AllEnts[i]:IsNPC() ) then
			ParedEnts[#ParedEnts + 1] = AllEnts[i]
		end
	end
	
	return ParedEnts
end

local unfrozenobj = 0
hook.Add("PlayerUnfrozeObject", "APA-AC-MassUnfreeze", function(_,_,phys)
	if APA.Settings.AntiCrash:GetBool() and has.MassUnfreeze:GetBool() then
		unfrozenobj = unfrozenobj + 1   timer.Simple(1, function() unfrozenobj = 0 end)

		timer.Simple(0, function()
			if unfrozenobj > 25 then
				for _,ent in next, ents.FindInSphere(phys:GetPos(), 320) do
					local objects = ent:GetPhysicsObjectCount()
					for i=1, objects do
						local physobject = ent:GetPhysicsObjectNum( i - 1 )
						if IsValid(physobject) and physobject:IsMoveable() then physobject:Sleep() end
					end
				end
			end
		end)
	end
end)


APA.initPlugin('anticrash')