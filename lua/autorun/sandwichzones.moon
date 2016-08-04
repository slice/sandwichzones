-- Autorun script, AKA entry point.
--
-- AddCSLuaFile-s all of the files required
-- and includes sh_init, sv_init, cl_init

if SERVER
	-- Serverside.
	AddCSLuaFile!
	AddCSLuaFile "sandwichzones/sh_init.lua"

	sendtoclient = {
		"sh_lang.lua", "cl_init.lua", "cl_menu.lua", "cl_settings.lua",
		"cl_zoneui.lua", "sh_zoneproperties.lua",
	}

	[AddCSLuaFile "sandwichzones/#{file}" for _, file in ipairs sendtoclient]

	include "sandwichzones/sh_init.lua"
	include "sandwichzones/sv_init.lua"
else
	-- Clientside.
	include "sandwichzones/sh_init.lua"
	include "sandwichzones/cl_init.lua"
