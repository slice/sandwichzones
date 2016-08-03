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

SZ.Log("initializing ulx...")

SZ.ULX = {}

-- The name of our category.
SZ.ULX.Category = "Sandwich Zones"

--[[------------------------------------------------
	Add zone command (!szaddzone, ulx szaddzone)

	Turns on the visual editor, used for adding zones.
	Use this instead of szrawcreatezone.
------------------------------------------------]]--
function SZ.ULX.AddZone(calling_ply)
	-- Log to chat.
	ulx.fancyLogAdmin(
		calling_ply,
		"#A now starting to creating zone"
	)

	-- Prompt user to start zone.
	SZ.Zone.StartAdd(calling_ply)
end

--[[------------------------------------------------
	Create a zone by manually inputting coordinates (!szrawcreatezone, ulx szrawcreatezone)

	This is not recommended if you just want to add
	zones. Use szaddzone instead.
------------------------------------------------]]--
function SZ.ULX.RawCreateZone(calling_ply, startx, starty, startz, endx, endy, endz)
	ulx.fancyLogAdmin(
		calling_ply,
		"#A now created zone"
	)

	local start = Vector(startx, starty, startz)
	local end_ = Vector(endx, endy, endz)

	SZ.Zone.Add(start, end_, calling_ply)
	SZ.Log("zone: created")
end

--[[------------------------------------------------
	Lets you see all zones (!szviewallon, ulx szviewallon)

	By default, zones are not visible.
	This command lets you see all zones.
------------------------------------------------]]--
function SZ.ULX.ViewAllOn(ply)
	if not SZ.Zone.GetAll() then return end

	ulx.fancyLogAdmin(ply, "#A now viewing all zones")

	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_ALL_ON, 4)
	net.WriteTable(SZ.Zone.GetAll())
	net.Send(ply)
end

--[[------------------------------------------------
	Turns off global zone viewing (!szviewalloff, ulx szviewalloff)

	By default, zones are not visible.
	If you used szviewallon to view all zones, this will
	turn it back off.
------------------------------------------------]]--
function SZ.ULX.ViewAllOff(ply)
	ulx.fancyLogAdmin(ply, "#A stopped viewing all zones")

	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_ALL_OFF, 4)
	net.Send(ply)
end

--[[------------------------------------------------
	Displays a zone setting UI.
------------------------------------------------]]--
function SZ.ULX.ZoneSettings(ply)
	if not SZ.Zone.PlayerInZone(ply) then
		ULib.tsayError(ply, SZ.Lang.ULXNotInZone)
		return
	end

	local thiszone = SZ.Zone.PlayerInZone(ply)

	ulx.fancyLogAdmin(ply, "#A is changing zone settings")

	-- Send netmessage to show settings UI.
	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_SETTINGS, 4)
	net.WriteTable(thiszone)
	net.Send(ply)
end

--[[------------------------------------------------
	Displays the zone menu.
------------------------------------------------]]--
function SZ.ULX.ZoneMenu(ply)
	ulx.fancyLogAdmin(ply, "#A opened the zone menu")

	-- Send netmessage to show zone menu.
	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_MENU, 4)
	net.WriteTable(SZ.Zone.GetAll() or {})
	net.Send(ply)
end

--[[------------------------------------------------
	Changes a property of the zone you are standing in.
------------------------------------------------]]--
function SZ.ULX.ZoneProperty(ply, target_uuid, pr, pr_val)
	local zones = SZ.Zone.GetAll()

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs(zones) do
		if zone.uuid == target_uuid then
			-- Found it.
			ulx.fancyLogAdmin(ply, "#A modified zone (" .. target_uuid .. ") property " .. pr .. " to be " ..
				tostring(pr_val))

			local map = game.GetMap()

			-- Create zone properties if it doesn't exist.
			if not SZ.Zone.Zones[map][k].properties then
				SZ.Zone.Zones[map][k].properties = {}
			end

			-- Commit changes and save.
			SZ.Zone.Zones[map][k].properties[pr] = pr_val
			SZ.Zone.Save()

			for property_name, info in pairs(SZ.ZoneProperties) do
				if pr == property_name then
					-- If this property was enabled,
					-- call the property's OnEnable if it has one.
					if pr_val == "yes" and info.OnEnable then
						SZ.Log("zone: calling OnEnable for " .. property_name)
						info.OnEnable(zone)
					end

					-- If this value was disabled,
					-- call the property's OnDisable if it has one.
					if pr_val == "no" and info.OnDisable then
						SZ.Log("zone: calling OnDisable for " .. property_name)
						info.OnDisable(zone)
					end
				end
			end

			return
		end
	end

	-- Zone not found.
	ULib.tsayError(ply, SZ.Lang.ULXZoneNotFound)
end

--[[------------------------------------------------
	Re-read zones from the zone file (zones.txt)
------------------------------------------------]]--
function SZ.ULX.ReloadZones(ply)
	ulx.fancyLogAdmin(ply, "#A reloaded zones")
	SZ.Zone.Load()
end

function SZ.ULX.GotoZone(ply, uuid)
	if not SZ.Zone.GetAll() then return end

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs(SZ.Zone.GetAll()) do
		if zone.uuid == uuid then
			-- Found it.
			ulx.fancyLogAdmin(ply, "#A teleported to zone " .. uuid)

			-- Teleport to zone.
			ply:SetPos(Vector(zone.start[1], zone.start[2], zone.start[3]))
			return
		end
	end

	ULib.tsayError(ply, SZ.Lang.ULXZoneNotFound)
end

function SZ.ULX.DeleteZone(ply, uuid)
	-- Do not do anything if there are no zones.
	if not SZ.Zone.GetAll() then
		ULib.tsayError(ply, SZ.Lang.ULXZoneNotFound)
		return
	end

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs(SZ.Zone.GetAll()) do
		if zone.uuid == uuid then
			-- Found it.
			ulx.fancyLogAdmin(ply, "#A deleted zone " .. uuid)

			-- Remove to zone.
			table.remove(SZ.Zone.Zones[game.GetMap()], k)
			SZ.Zone.Save() -- Save changes.
			SZ.Zone.Rebroadcast() -- Rebroadcast zones.

			return
		end
	end

	ULib.tsayError(ply, SZ.Lang.ULXZoneNotFound)
end

--[[------------------------------------------------
	Aborts the creation of a new zone. (!szstopaddingzone, ulx szstopaddingzone)

	Stops creating a new zone.
------------------------------------------------]]--
function SZ.ULX.StopAddingZone(calling_ply)
	-- Log to chat.
	ulx.fancyLogAdmin(
		calling_ply,
		"#A stopped adding a zone"
	)

	SZ.Zone.EndAdd(calling_ply)
end

--[[------------------------------------------------
	ViewAllOn, ViewAllOff
------------------------------------------------]]--
local allon = ulx.command(
	SZ.ULX.Category,
	"ulx szviewallon",
	SZ.ULX.ViewAllOn,
	"!szviewallon"
)
allon:defaultAccess(ULib.ACCESS_ADMIN)
allon:help(SZ.Lang.ULXViewAllOn)
local alloff = ulx.command(
	SZ.ULX.Category,
	"ulx szviewalloff",
	SZ.ULX.ViewAllOff,
	"!szviewalloff"
)
alloff:defaultAccess(ULib.ACCESS_ADMIN)
alloff:help(SZ.Lang.ULXViewAllOff)

--[[------------------------------------------------
	AddZone, StopAddingZone
------------------------------------------------]]--
local addzone = ulx.command(
	SZ.ULX.Category,
	"ulx szaddzone",
	SZ.ULX.AddZone,
	"!szaddzone"
)
addzone:defaultAccess(ULib.ACCESS_ADMIN)
addzone:help(SZ.Lang.ULXAddZone)
local stopzone = ulx.command(
	SZ.ULX.Category,
	"ulx szstopaddingzone",
	SZ.ULX.StopAddingZone,
	"!szstopaddingzone"
)
stopzone:defaultAccess(ULib.ACCESS_ADMIN)
stopzone:help(SZ.Lang.ULXStopAddingZone)

--[[------------------------------------------------
	RawCreateZone
------------------------------------------------]]--
local rawcreatezone = ulx.command(
	SZ.ULX.Category,
	"ulx szrawcreatezone",
	SZ.ULX.RawCreateZone,
	"!szrawcreatezone")
rawcreatezone:defaultAccess(ULib.ACCESS_ADMIN)
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "startx"
}
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "starty"
}
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "startz"
}
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "endx"
}
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "endy"
}
rawcreatezone:addParam{
	type = ULib.cmds.NumArg,
	min = -65536, max = 65536, default = 0,
	hint = "endz"
}
rawcreatezone:help(SZ.Lang.ULXRawCreateZone)

--[[------------------------------------------------
	ReloadZones
------------------------------------------------]]--
local reloadzones = ulx.command(
	SZ.ULX.Category,
	"ulx szreloadzones",
	SZ.ULX.ReloadZones,
	"!szreloadzones")
reloadzones:defaultAccess(ULib.ACCESS_ADMIN)
reloadzones:help(SZ.Lang.ULXReloadZones)

--[[------------------------------------------------
	ZoneSettings
------------------------------------------------]]--
local zonesettings = ulx.command(
	SZ.ULX.Category,
	"ulx szzonesettings",
	SZ.ULX.ZoneSettings,
	"!szzonesettings")
zonesettings:defaultAccess(ULib.ACCESS_ADMIN)
zonesettings:help(SZ.Lang.ULXChangeZoneProperties)

--[[------------------------------------------------
	ZoneSetProperty
------------------------------------------------]]--
local zsp = ulx.command(
	SZ.ULX.Category,
	"ulx szzonesetproperty",
	SZ.ULX.ZoneProperty,
	"!szzonesetproperty")
zsp:defaultAccess(ULib.ACCESS_ADMIN)
zsp:addParam{
	type = ULib.cmds.StringArg,
	hint = "uuid"
}
zsp:addParam{
	type = ULib.cmds.StringArg,
	hint = "propertyname"
}
zsp:addParam{
	type = ULib.cmds.StringArg,
	hint = "propertyvalue"
}
zsp:help(SZ.Lang.ULXChangeProperty)

--[[------------------------------------------------
	ZoneMenu
------------------------------------------------]]--
local zonemenu = ulx.command(
	SZ.ULX.Category,
	"ulx szzonemenu",
	SZ.ULX.ZoneMenu,
	"!szzonemenu")
zonemenu:defaultAccess(ULib.ACCESS_ADMIN)
zonemenu:help(SZ.Lang.ULXCmdZoneMenu)

--[[------------------------------------------------
	GotoZone
------------------------------------------------]]--
local gotozone = ulx.command(
	SZ.ULX.Category,
	"ulx szgotozone",
	SZ.ULX.GotoZone,
	"!szgotozone")
gotozone:defaultAccess(ULib.ACCESS_ADMIN)
gotozone:addParam{
	type = ULib.cmds.StringArg,
	hint = "uuid"
}
gotozone:help(SZ.Lang.ULXCmdTPToZone)

--[[------------------------------------------------
	DeleteZone
------------------------------------------------]]--
local deletezone = ulx.command(
	SZ.ULX.Category,
	"ulx szdeletezone",
	SZ.ULX.DeleteZone,
	"!szdeletezone")
deletezone:defaultAccess(ULib.ACCESS_ADMIN)
deletezone:addParam{
	type = ULib.cmds.StringArg,
	hint = "uuid"
}
deletezone:help(SZ.Lang.ULXDeleteZone)
