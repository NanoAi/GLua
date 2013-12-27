GM.Version = "0.1.0"
GM.Name = "DarkScape"
GM.Author = "By HeLLFox_15"

CUR = "$"

-- Checking if counterstrike is installed correctly
if table.Count(file.Find("*", "cstrike")) == 0 then
	timer.Create("TheresNoCSS", 10, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Counter Strike: Source is incorrectly installed!")
			v:ChatPrint("You need it for DarkScape to work!")
			print("Counter Strike: Source is incorrectly installed!\nYou need it for DarkScape to work!")
		end
	end)
end

-- Hello World! --

-- Derived from Sandbox --
DeriveGamemode("sandbox")

-- Adding the Client Side Lua --

-- Adding the Shared Lua --
include("shared/ds_dm.lua")
include("shared/ds_invis.lua")

