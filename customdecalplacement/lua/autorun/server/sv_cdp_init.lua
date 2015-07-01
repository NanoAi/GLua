AddCSLuaFile("autorun/client/cl_cdp_init.lua")
util.AddNetworkString("cdpSend_loader")

function cdpLoadDecals()
	local tables = {}

	if file.Exists( "cdp_PaintLocations.txt", "DATA" ) then
		local cdpPaint = string.Split(file.Read( "cdp_PaintLocations.txt", "DATA" ),"\n") -- Collect list.
		for k,v in pairs(cdpPaint) do if string.Trim(v) == "" then cdpPaint[k] = nil else cdpPaint[k] = string.Trim(v) end end -- Clean up the list and remove blank values.

		for k,v in pairs(cdpPaint) do
			tables[k] = util.JSONToTable( v )
		end

		hook.Add( "PlayerInitialSpawn", "CDP_StartupHook", function( ply )
			net.Start("cdpSend_loader")
			net.WriteTable(tables)
			net.Send(ply)
		end)

		for _, v in pairs(player.GetAll()) do
			net.Start("cdpSend_loader")
			net.WriteTable(tables)
			net.Send(v)
		end
	end
end; cdpLoadDecals();