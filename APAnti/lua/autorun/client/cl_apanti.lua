/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon: APAnti
-- Author: LuaTenshi
-- Contact: luatenshi@gmail.com
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local function escape(s)
	return s:gsub( "%%", "<p>" )
end

net.Receive("sMsgStandard", function()
	local s,c = net.ReadString(), net.ReadTable()
	
	if not (s and c) then return end
	if type(s) != "string" then return end
	if type(c) != "table" then return end

	if #c > 3 then return end

	if s == "APA-DMG-WARN" then
	 	s = "WARNING: This may be abused. Players may launch other peoples props at them selves thus killing innocents.\n\nPlease watch this video about how one may abuse this.\n( http://youtu.be/PHiDushdnpo )"
	end
	
	-------------------------

	local str = escape(s)
	str = string.format(str)

	if str then
		chat.AddText(Color(255,170,0), "[A2PK] ", c, str.."\n")
	end
end)

net.Receive("sNotifyHit", function()
	local a,b,c,d = "", "", "", ""
	
	a = net.ReadString() or "<N/A>"
	b = net.ReadString() or "<N/A>"
	c = net.ReadString() or "<N/A>"
	d = net.ReadString() or "<N/A>"

	local strs = escape(string.format("A prop belonging to %s[%s] has hit %s[%s]!", a, b, c, d))
	strs = string.format(strs)

	MsgC( Color( 255, 0, 0 ), strs.."\n" )
end)

net.Receive("sMsgAdmins", function()
	local a,b,c,d = "", "", "", ""
	
	a = net.ReadString() or "<N/A>"
	b = net.ReadString() or "<N/A>"
	c = net.ReadString() or "<N/A>"
	d = net.ReadString() or "<N/A>"

	local str = escape(string.format("A prop belonging to %s[%s] has hit %s[%s]!", a, b, c, d))
	str = string.format(str)

	if a then
		chat.AddText(Color(255,170,0), "[A2PK] ", Color(255,0,0), str.."\n")
	end
end)

net.Receive("sAlertNotice", function()
	local a,b,c,d = "",0,0,0

	a = net.ReadString()
	b = net.ReadFloat() or 1
	c = net.ReadFloat() or 2
	d = net.ReadFloat() or 0

	if not a then return end

	a = escape(a)
	a = string.format(a)

	notification.AddLegacy( a, b, c )

	if d >= 1 or tobool(d) then
		surface.PlaySound("ambient/alarms/klaxon1.wav")
	end
end)

--[[--
local gmblockspawn = 0
net.Receive("sBlockGMSpawn", function()
	local n = 0; n = net.ReadFloat() or 0;
	if gmblockspawn <= 0 and n >= 1 then
		hook.Add("PlayerBindPress", "_sBlockGMSpawn", function(pl, bind)
			if ( string.find( bind, "gm_spawn" ) or string.find( bind, "impulse 102" ) ) then 
				pl:ChatPrint("gm_spawn is currently disabled please try again later.")
				return true
			end
		end)
		gmblockspawn = 1
	elseif gmblockspawn >= 1 and n <= 0 then
		hook.Remove("PlayerBindPress", "_sBlockGMSpawn")
		gmblockspawn = 0
	end
end)
--]]--