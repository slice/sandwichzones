--
-- .d8888.  .d8b.  d8b   db d8888b. db   d8b   db d888888b  .o88b. db   db      d88888D  .d88b.  d8b   db d88888b .d8888.
-- 88'  YP d8' `8b 888o  88 88  `8D 88   I8I   88   `88'   d8P  Y8 88   88      YP  d8' .8P  Y8. 888o  88 88'     88'  YP
-- `8bo.   88ooo88 88V8o 88 88   88 88   I8I   88    88    8P      88ooo88         d8'  88    88 88V8o 88 88ooooo `8bo.
--   `Y8b. 88~~~88 88 V8o88 88   88 Y8   I8I   88    88    8b      88~~~88        d8'   88    88 88 V8o88 88~~~~~   `Y8b.
-- db   8D 88   88 88  V888 88  .8D `8b d8'8b d8'   .88.   Y8b  d8 88   88       d8' db `8b  d8' 88  V888 88.     db   8D
-- `8888Y' YP   YP VP   V8P Y8888D'  `8b8' `8d8'  Y888888P  `Y88P' YP   YP      d88888P  `Y88P'  VP   V8P Y88888P `8888Y'
--
-- This file is part of Sandwich Zones.
-- (c) 2016 System16

-- This code executes on both the client and the server before
-- cl_init.lua and sv_init.lua

-- Global SZ table.
SZ = {}

SZ.Config = {}

-- Include configuration file.
if SERVER then include("sandwichzones/sv_config.lua") end

include("sh_lang.lua")

-- Log colors.
SZ.LogRed = Color(255, 81, 0)
SZ.LogCL = Color(0, 208, 255)
SZ.LogSV = Color(255, 153, 0)

-- Constants.
SZ.ZONEUI_BEGIN = 1
SZ.ZONEUI_END = 2
SZ.ZONEUI_ALL_ON = 3
SZ.ZONEUI_ALL_OFF = 4
SZ.ZONEUI_SETTINGS = 5
SZ.ZONEUI_MENU = 6

-- Simple log function.
-- Second argument is optional.
function SZ.Log(text, _color)
	if SZ.Config.DisableLogging then return end

	local tag, color
	if SERVER then
		tag = "sz/sv"
		color = _color or SZ.LogSV
	else
		tag = "sz/cl"
		color = _color or SZ.LogCL
	end

	MsgC(color, tag .. ": " .. text .. "\n")
end

-- Simple error function.
function SZ.Error(text)
	SZ.Log("error: " .. text, SZ.LogRed)
end

-- Huge error banner.
--
-- Use this to get the user's attention.
function SZ.ErrorBanner()
	MsgC(SZ.LogRed, [[

  d88888b d8888b. d8888b.  .d88b.  d8888b.
  88'     88  `8D 88  `8D .8P  Y8. 88  `8D
  88ooooo 88oobY' 88oobY' 88    88 88oobY'
  88~~~~~ 88`8b   88`8b   88    88 88`8b
  88.     88 `88. 88 `88. `8b  d8' 88 `88.
  Y88888P 88   YD 88   YD  `Y88P'  88   YD

  Something wrong happened with Sandwich Zones.
  Please look below for the description of the error:

	]])
end

-- Call initialize hook.
hook.Call("SZ_Initialize")
SZ.Log("init")

-- Include zone properties.
include("sandwichzones/sh_zoneproperties.lua")
