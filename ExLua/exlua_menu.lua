if SERVER then
	AddCSLuaFile( "exlua_menu.lua" )
	AddCSLuaFile("autorun/exlua_menu.lua")
	-------
	util.AddNetworkString("xlSendULXCommand") 
	net.Receive("xlSendULXCommand", function(_, ply)
		if ply:query( "ulx exlua" ) then
			ulx.exlua( ply, net.ReadString() )
		end
	end)
end

if CLIENT then
	local pastCommands, menuOpen = {}, false

	local function EntityClick(code, pos, tr, state)
		if not state and code == (MOUSE_RIGHT or 108) then
			if IsValid(tr.Entity) then
				local ent = {v = tr.Entity, tab = tr.Entity:GetTable()}
				local Menu = vgui.Create( "DMenu" )
				
				Menu.Paint = function(self, w, h)
					draw.RoundedBoxEx(8, 0, 0, w, h, Color( 255, 255, 255, 255 ), false, true, true, false)
				end

				local mTitle = Menu:AddOption( string.upper(tr.Entity:GetClass()) )
				mTitle:SetIcon( "icon16/bug.png" )
				mTitle.Paint = function(self, w, h) draw.RoundedBoxEx(8, 0, 0, w, h, Color( 240, 240, 240, 255 ), false, true, false, false) end

				Menu:GetVBar().Paint = mTitle.Paint
				Menu:GetVBar().btnUp.Paint = function() return true end
				Menu:GetVBar().btnDown.Paint = function() return true end
				Menu:GetVBar().btnGrip.Paint = Menu.Paint
				function Menu:OnScrollbarAppear() return true end

				Menu:AddSpacer()
				if (ent.v.Health and ent.v:Health() > 0) or ent.v.Team or ent.v.GetActiveWeapon or ent.v:IsPlayer() then
					if ent.v.Health and ent.v:Health() > 0 then Menu:AddOption("Health: "..tostring(ent.v:Health())) end
					if ent.v.Team then 
						local sm = Menu:AddSubMenu("Team: "..tostring(ent.v:Team()))
						local tm = sm:AddOption(" ")
						tm.Paint = function(self, w, h)
							draw.RoundedBox(0, 0, 0, w, h, team.GetColor( ent.v:Team() or 0 ))
							surface.SetDrawColor( 255, 255, 255, 255 )
						end
						Menu:AddOption("Group: "..tostring(ent.v:GetNetworkedString( "UserGroup" ))) 
					end
					if ent.v.GetActiveWeapon then
						local en = ent.v:GetActiveWeapon()
						if IsValid(en) then
							Menu:AddOption("Weapon: "..tostring(en:GetClass()))
						else
							Menu:AddOption("Weapon: <Undefined>")
						end
					end
					Menu:AddSpacer()
				end
				for k,v in next, ent.tab do
					local SubMenu = Menu:AddSubMenu( k )
					SubMenu.Paint = Menu.Paint
					local x = tostring(v)
					if string.Trim(x) ~= "" then
						if type(v) == "table" then
							local s = SubMenu:AddOption( tostring(x) )
							s.Paint = mTitle.Paint
							SubMenu:AddSpacer()
							for i,d in next, v do
								local l = SubMenu:AddSubMenu( tostring(i) )
								l.Paint = Menu.Paint
								if string.Trim(tostring(d)) ~= "" then
									l:AddOption( tostring(d) )
								else
									l:AddOption( "<Undefined>" )
								end
							end
						else
							SubMenu:AddOption( tostring(x) )
						end
					else
						SubMenu:AddOption( "<Undefined>" )
					end
				end
				Menu:Open()
			end
		end
	end

	local function BuildMenu()
		local hax = vgui.Create("DFrame")
		hax:SetPos(0,0)
		hax:SetSize( ScrW(), ScrH() )
		hax:SetTitle(" ")
		hax:SetDraggable( false )
		hax:ShowCloseButton( false )
		hax:SetWorldClicker( true )
		hax:MakePopup()
		hax.Paint = function()
			draw.RoundedBox( 8, 0, 0, hax:GetWide(), hax:GetTall(), Color( 0, 0, 0, 0 ) )
		end

		hax.OnMousePressed = function( p, code )
			EntityClick(code, gui.ScreenToVector( gui.MousePos() ), LocalPlayer():GetEyeTrace(), true)
		end
		hax.OnMouseReleased = function( p, code )
			EntityClick(code, gui.ScreenToVector( gui.MousePos() ), LocalPlayer():GetEyeTrace(), false)
		end

		menuOpen = true

		local txtbox = vgui.Create( "DTextEntry", hax )
		txtbox:SetPos( 0, ScrH() - 25 )
		txtbox:SetSize( ScrW(), 25 )
		txtbox:RequestFocus()
		txtbox.OnLoseFocus = function( self ) self:RequestFocus() end
		txtbox.Paint = function( self )
			draw.RoundedBoxEx(8, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 250 ), true, true, false, false)
			self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
		end

		local i = 0
		txtbox.OnKeyCodeTyped = function( self, key )
			local str = self:GetValue()
			if key == KEY_DOWN then
				i=i+1; if i > #pastCommands then i = 1 end
				if pastCommands[i] then
					self:SetText(pastCommands[i])
					self:SetValue(pastCommands[i])
				end
				return true
			elseif key == KEY_UP then
				i=i-1; if i > #pastCommands or i <= 0 then i = #pastCommands end
				if pastCommands[i] then
					self:SetText(pastCommands[i])
					self:SetValue(pastCommands[i])
				end
				return true
			elseif key == KEY_ESCAPE or gui.IsConsoleVisible() then
				hax:Remove()
				return true
			elseif key == KEY_ENTER then
				if not table.HasValue(pastCommands, string.Left(str, 1000)) then
					if #pastCommands <= 50 then
						table.insert(pastCommands, string.Left(str, 1000))
					else
						table.Empty(pastCommands)
					end
				end

				if LocalPlayer():query( "ulx exlua" ) then
					net.Start("xlSendULXCommand")
					net.WriteString(str)
					net.SendToServer()
				end

				menuOpen = false
				hax:Remove()
				return true
			end
			return false
		end
	end

	hook.Add("ChatTextChanged", "__ExLuaM", function(str)
		if str == "!l " or str == "!L " and LocalPlayer():query( "ulx exlua" ) then
			local tab = {}
			table.RemoveByValue( pastCommands, "" )
			table.RemoveByValue( pastCommands, nil )
			for _,v in next, pastCommands do 
				if string.Trim(v) ~= "" then
					table.insert(tab, v)
				end
			end
			pastCommands = tab
			tab = nil
			chat.Close()

			BuildMenu()
		end
	end)
end