/*----------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon: APAnti
-- Author: LuaTenshi
-- Contact: luatenshi@gmail.com
----------------------------------------------------------------------------------------------------------------------------------------------------*/

local function escape(s)
	return s:gsub( "%%", "<p>" )
end

net.Receive("sMsgStandard", function()
	local a,w,h = 0, 0, ""
	local s,c = net.ReadString(), net.ReadTable()
	
	if type(s) != "string" then return end
	if type(c) != "table" then return end

	for k,_ in pairs(c) do a = k end
	if a > 3 then return end

	if str == "APA-DMG-WARN" then 
		w = 1
	 	str = "WARNING: This may be abused. Players may launch other peoples props at them selves thus killing innocents."
	 	h = "Please watch this video about how one may abuse this. ( http://youtu.be/PHiDushdnpo )"
	end

	if string.len(h) > 0 then
		h = escape(h)
		h = string.format(h)
	end
	-------------------------
	local str = escape(s)
	str = string.format(str)

	if s then
		chat.AddText(Color(255,170,0), "[A2PK] ", c, str)
		if h then
			chat.AddText(Color(255,170,0), "[A2PK] ", c, h)
		end
	end
end)

net.Receive("sNotifyHit", function()
	local a,b,c,d = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadString()
	local strs = escape(string.format("A prop belonging to %s[%s] has hit %s[%s]!", a, b, c, d))
	strs = string.format(strs)

	MsgC( Color( 255, 0, 0 ), strs )
end)

net.Receive("sMsgAdmins", function()
	local a,b,c,d = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadString()

	local str = escape(string.format("A prop belonging to %s[%s] has hit %s[%s]!", a, b, c, d))
	str = string.format(str)

	if a then
		chat.AddText(Color(255,170,0), "[A2PK] ", Color(255,0,0), str)
	end
end)

net.Receive("sAlertNotice", function()
	local a,b,c,d = net.ReadString(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()

	if not a then return end
	if not c then return end
	if not b then b = 1 end
	if not d then d = 0 end

	a = escape(a)
	a = string.format(a)

	notification.AddLegacy( a, b, c )

	if d == 1 then
		surface.PlaySound("ambient/alarms/klaxon1.wav")
	end
end)