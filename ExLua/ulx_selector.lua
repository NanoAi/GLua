--[[------------------------------------------------------------------------------------------------------------------------
	ULX ExLua for ULX SVN/ULib SVN by LuaTenshi, YVL, and TheLastPenguin.
-----------------------------------------------------------------------------------------------------------------------]]--
-- The Config
local should_side_load_easylua = false
-- The Prep Code
if SERVER then 
	util.AddNetworkString("xlSendULXCommand") 
	net.Receive("xlSendULXCommand", function(_, ply)
		ulx.exlua( ply, net.ReadString() )
	end)
end
if CLIENT then
	local pastCommands = {}
	hook.Add("ChatTextChanged", "__ExLuaM", function(str)
		if str == "!l " then
			table.RemoveByValue( pastCommands, "" )
			table.RemoveByValue( pastCommands, nil )
			chat.Close()

			local hax = vgui.Create("DFrame")
			hax:SetPos(0,0)
			hax:SetSize( ScrW(), ScrH() )
			hax:SetTitle(" ")
			hax:SetDraggable( false )
			hax:ShowCloseButton( false )
			hax:MakePopup()
			hax.Paint = function()
				draw.RoundedBox( 8, 0, 0, hax:GetWide(), hax:GetTall(), Color( 0, 0, 0, 0 ) )
			end

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
				if key == KEY_UP then
					i=i+1; if i > #pastCommands then i = 1 end
					if pastCommands[i] then
						self:SetText(pastCommands[i])
						self:SetValue(pastCommands[i])
					end
					return true
				elseif key == KEY_DOWN then
					i=i-1; if i > #pastCommands or i <= 0 then i = #pastCommands end
					if pastCommands[i] then
						self:SetText(pastCommands[i])
						self:SetValue(pastCommands[i])
					end
					return true
				elseif key == KEY_ESCAPE then
					hax:Remove()
					return true
				elseif key == KEY_ENTER then
					if not table.HasValue(pastCommands, string.Left(str, 1000)) then
						if #pastCommands <= 5 then
							table.insert(pastCommands, string.Left(str, 1000))
						else
							table.Empty(pastCommands)
						end
					end

					net.Start("xlSendULXCommand")
					net.WriteString(str)
					net.SendToServer()

					hax:Remove()
					return true
				end
				return false
			end
		end
	end)
end

-- The Real Code

local ExLua = {}
table.Inherit(ExLua, _G) -- Make a local global table.

if should_side_load_easylua then
	local fetch_url = "https://raw.githubusercontent.com/CapsAdmin/fast_addons/master/lua/helpers/easylua.lua"
	local fetch_status = false

	http.Fetch( fetch_url, 
		function(s) 
			RunStringEx("EasyLuaInit", s) 
			fetch_status = true
		end, 
		function() 
			print("Notice: EasyLua not loaded!") 
			fetch_status = false
		end
	)

	if fetch_status then
		if easylua then
			table.Merge( ExLua, easylua ) -- Living on the edge.
		end
	end
end

setfenv(1, ExLua) -- Now time to get fancy.

local _ent = FindMetaTable("Entity")
-- Entity - Shortners
function _ent:color(color, ...)
	if color == nil then
		local color = Color(0,0,0,0)
		if self:IsPlayer() then color = self:GetPlayerColor(Vector(color.r/255, color.g/255, color.b/255)) else color = self:GetColor(color) end
		return color
	end
	if type(color) == "string" then color = string.ToColor(color) end
	if select("#", ...) >= 1 then color = Color(color, select(1, ...) or 0, select(2, ...) or 0, select(3, ...) or 255) end
	if self:IsPlayer() then self:SetPlayerColor(Vector(color.r/255, color.g/255, color.b/255)) else self:SetColor(color) end
end; function _ent:colour(color, ...) return self:color(color, ...) end
function _ent:del() SafeRemoveEntity(self) end
function _ent:move(vector)
	local mins, maxs = self:OBBMins(), self:OBBMaxs()
	local dif = (mins:Distance(maxs)/2) - 7
	self:SetPos(vector + Vector(0,0,dif))
end
function _ent:hurt(n)
	local me = ExLua.util.me
	if n then
		self:TakeDamage( n, me, me )
	else
		local hp = self:Health() or 0
		self:TakeDamage( hp+10, me, me )
	end
end

-- Shortners
V = Vector
H = hook
E = Entity
tmr = timer
tmrc = timer.Create
tmrs = timer.Simple
ply = player
plys = player.GetAll

H.a = hook.Add
H.d = hook.Remove
H.r = hook.Run
H.c = hook.Call
H.g = hook.GetTable

function _I(ObjectTable)
	if (not ObjectTable) or type(ObjectTable) ~= "table" then return end
	local first = ObjectTable[1] -- we assume this is a prototype for all objects
	if not first then ULib.tsayError( me(), "ExLua:1: The table has no values!" ) return end
	return setmetatable(ObjectTable, {
		__index = function(self, key)
			local val = first[key]
			if val and isfunction(val) then
				return function(meee, ...)
					if meee == self then
						for _, v in next, ObjectTable do
								val(v, ...)
						end
					else
						ULib.tsayError( me(), "ExLua:1: No method called!" )
					end
				end
			else
				ULib.tsayError( me(), "ExLua:1: Unsupported type or nil refrence." )
			end
		end
	})
end

function _L( t, i )
	if not i then i = 0 end
	if not t then t = player.GetAll() end
	i = i + 1
	local v = t[ i ] 
	if v then return i, v end 
	return nil
end

function _S( s, i )
	s = tobool(s)
	local c, t = {}, util.me._ulxSelection
	if s then
		for _,v in next, t do if IsValid(v) and v:IsPlayer() then table.insert(c, v) end end
	else
		for _,v in next, t do if IsValid(v) and not v:IsPlayer() then table.insert(c, v) end end
	end
	t = c
	if not i then i = 0 end
	i = i + 1 
	local v = t[ i ] 
	if v then return i, v end 
	return nil
end

function _s( s, i )
	s = tobool(s)
	local c, t = {}, util.me._ulxSelection
	if s then
		for _,v in next, t do if IsValid(v) and v:IsPlayer() then table.insert(c, v) end end
	else
		for _,v in next, t do if IsValid(v) and not v:IsPlayer() then table.insert(c, v) end end
	end; return c
end

__index = function(t, k)
	local tr, _ = ULib.getUser(tostring(k),true,util.me)
	if tr then
		return tr 
	else
		return nil
	end 
end; setmetatable(ExLua, ExLua)

-- Macros
util.me = Entity(0)
function me() return util.me end

function this() 
	local tr = util.me:GetEyeTrace() 
	util.me.mark = tr.Entity 
	return tr.Entity 
end

function that() return util.me.mark end
function here() local tr = util.me:GetEyeTrace() return tr.HitPos end

-- Easy Entity Marking
function gmk() return util.me.mark end -- Obsolete?
function gsel(n) local t = util.me._ulxSelection if type(n) == "number" then return t[n] end return t end

setfenv(1, _G) -- Back to the global.
-- Make it Safe
ExLua.setfenv, ExLua.ulx, ExLua.FAdmin, ExLua.fadmin = nil, nil, nil, nil

function ulx.exlua( calling_ply, str )
	local tab, out, s, p, err = {}, "", ""
	local ply = calling_ply; ExLua.util.me = calling_ply
	
	if string.Trim(str) == "" or string.Trim(str) == "Lua Code" then ULib.tsayError( ply, "ExLua:1: Please enter some code to run." ) return end
	if string.len(str) <= 1 then ULib.tsayError( ply, "ExLua:1: The string you entered is too short." ) return end
	
	for x,y in string.gmatch(str, "(%S+):(%S+)") do table.insert(tab, {x = x, y = y}) end

	local return_results = false
	if str:sub( 1, 1 ) == "=" then
		str = "tmp_var" .. str
		return_results = true
	end

	local should_replace = false
	for _,t in next, tab do
		local x, y = t.x, t.y
		local trg, err = Entity(0), "ExLua:0: Unknown Error!"
		if x then
			if x == "^" or x == "@" or string.GetChar( x, 1 ) == "$" then
				trg, err = ULib.getUser(tostring(x),true,ply)
				if trg and not err then
					out = string.Replace(str, tostring(x), "E("..trg:EntIndex()..")")
					should_replace = true
				else
					ULib.tsayError(	ply, "ExLua:2: "..tostring(err) )
					return
				end
			elseif x == "*" or string.GetChar( x, 1 ) == "%" or string.GetChar( x, 1 ) == "#" then
				trg, err = ULib.getUsers(tostring(x),true,ply)
				if trg and not err then
					calling_ply.targets = trg
					out = string.Replace(str, x..":"..y, "_I(me.targets):"..y)
					should_replace = true
				else
					ULib.tsayError(	ply, "ExLua:2: "..tostring(err) )
					return
				end
			elseif x == "&" then
				out = string.Replace(str, x..":"..y, "for _,v in _S do v:"..y.." end")
				should_replace = true
			end
		end
	end; if not should_replace then out = str end
	
	local func = CompileString( out, "ExLua", false )
	
	if type(func) == "function" and func and not err then
		func = setfenv(func, ExLua) -- Push our function into the environment.
		local succ, err = pcall(func)
		if err then ULib.tsayError( ply, err ) return end
		if succ then
			if return_results then
				timer.Simple(0.01, function()
					if type( ExLua.tmp_var ) == "table" then
						ULib.console( calling_ply, "Result:" )
						local lines = ULib.explode( "\n", ulx.dumpTable( ExLua.tmp_var ) )
						local chunk_size = 50
						for i=1, #lines, chunk_size do -- Break it up so we don't overflow the client
							ULib.queueFunctionCall( function()
								for j=i, math.min( i+chunk_size-1, #lines ) do
									ULib.console( calling_ply, lines[ j ]:gsub( "%%", "<p>" ) )
								end
							end )
						end
					else
						ULib.console( calling_ply, "Result: " .. tostring( ExLua.tmp_var ):gsub( "%%", "<p>" ) )
					end
				end)
			end
			ulx.fancyLogAdmin( calling_ply, true, "#A ran ExLua: #s", str )
		else
			ulx.fancyLogAdmin( calling_ply, true, "#A attempted to run ExLua: #s", str )
			ULib.tsayError(	ply, "ExLua:3: pcall returned false." )
		end
	elseif func then
		ULib.tsayError(	ply, tostring(func) )
	else
		ULib.tsayError(	ply, "ExLua:1: No callback found. This should not happen." )
	end
	calling_ply.targets = nil
end
local exlua = ulx.command( "Extra Utility", "ulx exlua", ulx.exlua, "!l" )
exlua:addParam{ type=ULib.cmds.StringArg, hint="Lua Code", ULib.cmds.takeRestOfLine }
exlua:defaultAccess( ULib.ACCESS_SUPERADMIN )
exlua:help( [[Run a lua script on the server. 

Excepts player arguments such as a players name or the ULX keywords.

Accepted Keywords: ^, @, $10 ]] )

-- _G.__index = function(t, k) local tr = ULib.getUser(tostring(k),true,nil) if tr then return tr else return nil end end setmetatable(_G, _G)