net.Receive("cdpSend_loader", function()
	local tables = net.ReadTable()
	
	print("hai")
	
	for k,v in pairs(tables) do
		if tables[k].map == game.GetMap() then
			tables[k].status = nil
			tables[k].err = nil
			tables[k].browsermat = nil
			tables[k].id = tostring(k) .. "_" .. tostring(math.random(111,999)) .. tostring(LocalPlayer():EntIndex()) -- Make a unique ID for each image.

			if ( timer.Exists( "cdp_delay" ) ) then timer.Destroy( tables[k].id .. "__cdp_delay" ) end
			hook.Remove("RenderScreenspaceEffects", tables[k].id .. "__CDP_3DHTMLSign")
			if tables[k].browser then tables[k].browser:Remove() end; tables[k].browser = nil;

			tables[k].browser = vgui.Create("HTML", _, "cdp."..tostring(tables[k].id))
			tables[k].browser:SetPaintedManually(true)
			tables[k].browser:SetSize(tables[k].width, tables[k].height)
			tables[k].browser:SetMouseInputEnabled(false)
			tables[k].browser:OpenURL(tables[k].url)

			timer.Create( tables[k].id .. "_cdp_delay", 1.5, 1, function() 
				tables[k].browser:UpdateHTMLTexture()
				tables[k].browsermat = tables[k].browser:GetHTMLMaterial()

				tables[k].DrawSign = function()
					-- Draw the screen
					if tables[k].browser then
						tables[k].browser:UpdateHTMLTexture()
						if tables[k].browsermat then render.SetMaterial(tables[k].browsermat) end
					end
					
					render.DrawQuad(tables[k].plain[1], tables[k].plain[2], tables[k].plain[3], tables[k].plain[4])
					render.DrawQuad(tables[k].plain[2], tables[k].plain[1], tables[k].plain[4], tables[k].plain[3])
					-- render.DrawQuad(tables[k].plain[1], tables[k].plain[2]*-1, tables[k].plain[3]*Vector(-1,1,1), tables[k].plain[4])
				end
				
				tables[k].IsVisible = function( vecPos )

					local trace = { start = LocalPlayer():EyePos(), endpos = vecPos, filter = LocalPlayer(), mask = MASK_SHOT };
					local traceRes = util.TraceLine( trace );

					if ( traceRes.HitWorld ) then return false end;
					
					return true;
				end

				hook.Add("RenderScreenspaceEffects", tables[k].id .. "__CDP_3DHTMLSign", function()
					if tables[k].pos:Distance(LocalPlayer():GetPos()) <= 1950 and tables[k].IsVisible(tables[k].pos) then
						if tables[k].err != "ERROR_END_BREAK" then
							cam.Start3D(EyePos(), EyeAngles())
								cam.Start3D2D(tables[k].pos, tables[k].ang, tables[k].scale)
									tables[k].status, tables[k].err = pcall(tables[k].DrawSign)
								cam.End3D2D()
								if not tables[k].status then Error(tables[k].err)		tables[k].err = "ERROR_END_BREAK" end
							cam.End3D()
						end
					else
						tables[k].err = nil
					end
				end)
			end)
		end
	end
end)