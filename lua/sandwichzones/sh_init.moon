-- This code executes on both the client and the server before
-- cl_init.lua and sv_init.lua

-- Global SZ table.
export SZ = {}

SZ.Config = {}

-- Include configuration file.
include "sandwichzones/sv_config.lua" if SERVER

include "sh_lang.lua"

-- Log colors.
SZ.LogRed = Color 255, 81, 0
SZ.LogCL = Color 0, 208, 255
SZ.LogSV = Color 255, 153, 0

-- Constants.
SZ.ZONEUI_BEGIN = 1
SZ.ZONEUI_END = 2
SZ.ZONEUI_ALL_ON = 3
SZ.ZONEUI_ALL_OFF = 4
SZ.ZONEUI_SETTINGS = 5
SZ.ZONEUI_MENU = 6

-- Simple log function.
-- Second argument is optional.
SZ.Log = (text, _color) ->
	return if SZ.Config.DisableLogging

	local tag, color

	if SERVER
		tag = "sz/sv"
		color = _color or SZ.LogSV
	else
		tag = "sz/cl"
		color = _color or SZ.LogCL

	MsgC color, "#{tag}: #{text}\n"

-- Simple error function.
SZ.Error = (text) ->
	SZ.Log "error: #{text}", SZ.LogRed

-- Huge error banner.
--
-- Use this to get the user's attention.
SZ.ErrorBanner = ->
	MsgC SZ.LogRed, [[

  d88888b d8888b. d8888b.  .d88b.  d8888b.
  88'     88  `8D 88  `8D .8P  Y8. 88  `8D
  88ooooo 88oobY' 88oobY' 88    88 88oobY'
  88~~~~~ 88`8b   88`8b   88    88 88`8b
  88.     88 `88. 88 `88. `8b  d8' 88 `88.
  Y88888P 88   YD 88   YD  `Y88P'  88   YD

  Something wrong happened with Sandwich Zones.
  Please look below for the description of the error:

	]]

-- Call initialize hook.
hook.Call "SZ_Initialize"
SZ.Log "init"

-- Include zone properties.
include "sandwichzones/sh_zoneproperties.lua"
