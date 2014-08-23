-- USelect
if SERVER then
	AddCSLuaFile( "ulx_selector.lua" )
	AddCSLuaFile("autorun/ulx_selector.lua")
	util.AddNetworkString("ulx_selector")

	--[[
	hook.Add("ulx_custompiece", "__j", function(ply, p) 
		if p:sub( 1, 1 ) == "&" then
			local uSel = ply._ulxSelection
			if uSel and type(uSel) == "table" and #uSel >= 1 then
				local tab = {}
				for _,v in next, ply._ulxSelection do
					if IsValid(v) and v:IsPlayer() then
						table.insert(tab, v)
					end
				end
				return tab
			else
				return nil
			end
		end
	end)
	]]--

	net.Receive( "ulx_selector", function( _, ply )
		if ply and IsValid(ply) then
			if ply:query( "ulx _mcontext" ) or ply:query( "ulx exlua" ) then
				ply._ulxSelection = net.ReadTable()
			else
				ULib.tsayError(	ply, "You are not allowed to do this." )
			end
		end
	end)
end

if CLIENT then
	hook.Add("UCLAuthed", "__uselectinit", function(ply)
		if IsValid(ply) and (ply:query( "ulx _mcontext" ) or ply:query( "ulx exlua" )) then
			hook.Add("OnContextMenuOpen", "__uselectcall", function() LocalPlayer().contextopen = true end)
			hook.Add("OnContextMenuClose", "__uselectcall", function() LocalPlayer().contextopen = false; start = false end)
			local i, p, start = 0, {x = 0, y = 0}, false
			hook.Add("GUIMousePressed", "__uselectcall", function(m)
				if LocalPlayer().contextopen then
					if m == MOUSE_RIGHT then 
						start = true
						p = {x = gui.MouseX(), y = gui.MouseY(), p = gui.MousePos()}
					end
				end
			end)
			hook.Add("GUIMouseReleased", "__uselectcall", function(m, pos)
				if m == MOUSE_RIGHT and start then 
					start = false

					local selected = {}
					for _,trg in next, ents.FindInCone(LocalPlayer():GetPos(),LocalPlayer():EyeAngles():Forward(),1000,0) do
						local v, pv, ov = Vector(0,0),Vector(0,0),Vector(0,0)
						if trg and IsValid(trg) and not (trg == LocalPlayer() or trg:GetOwner() == LocalPlayer()) then
							if trg:IsPlayer() then
								v, _ = trg:GetBonePosition( trg:LookupBone( "ValveBiped.Bip01_Head1" ) or 12 );
							else
								local min,max = trg:WorldSpaceAABB()
								v = LerpVector(0.5, min, max)
							end
							v = v:ToScreen(); v = Vector(v.x, v.y)
							pv, ov = Vector(p.x, p.y), Vector(gui.MouseX(), gui.MouseY())
							if pv:Length2D() < ov:Length2D() then
								if v:WithinAABox( pv, ov ) then
									if trg:EntIndex() >= 1 then table.insert(selected, trg) end
								end
							else
								if v:WithinAABox( ov, pv ) then
									if trg:EntIndex() >= 1 then table.insert(selected, trg) end
								end
							end
						end
					end

					-- Note: Remove demo printing and add a net send so the server can do stuff now.
					for k,v in next, selected do
						local oc, om = v:GetColor(), v:GetMaterial()
						v:SetMaterial("models/wireframe"); v:SetColor(Color(100,255,255,255))
						timer.Simple(0.1, function() if IsValid(v) then v:SetColor(oc) v:SetMaterial(om) end end)
						local effectdata = EffectData(); effectdata:SetOrigin( v:GetPos() ); effectdata:SetEntity( v )
						util.Effect( "phys_freeze", effectdata, true, true )
					end
					--------
					net.Start("ulx_selector")
						net.WriteTable(selected)
					net.SendToServer()
				end
			end)
			hook.Add("DrawOverlay", "__uselectcall", function()
				if start then
					local o = {x = gui.MouseX(), y = gui.MouseY() }
					local square = {}
					square[1] =
					{
						{ x = p.x, y = p.y },
						{ x = o.x, y = p.y + 0 },
						{ x = o.x, y = o.y },
						{ x = p.x + 0, y = o.y }
					}
					--------
					square[2] = 
					{
						{ x = o.x, y = p.y },
						{ x = p.x, y = p.y },
						{ x = p.x, y = o.y },
						{ x = o.x, y = o.y }
					}
					-- draw.RoundedBox( 0, pos.x, pos.y, o.x, o.y, Color( 0, 119, 255, 100 ) )
					surface.SetDrawColor( 100, 255, 255, 128 )
					draw.NoTexture()
					surface.DrawPoly( square[1] )
					surface.DrawPoly( square[2] )
				end
			end)
		end
	end)
end