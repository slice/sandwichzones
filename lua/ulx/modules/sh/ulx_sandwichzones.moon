SZ.Log "initializing ulx..."

SZ.ULX = {}

-- The name of our category.
SZ.ULX.Category = "Sandwich Zones"

--
-- Add zone command (!szaddzone, ulx szaddzone)
--
-- Turns on the visual editor, used for adding zones.
-- Use this instead of szrawcreatezone.
--
SZ.ULX.AddZone = (calling_ply) ->
	-- Log to chat.
	ulx.fancyLogAdmin calling_ply,
		"#A now starting to creating zone"

	-- Prompt user to start zone.
	SZ.Zone.StartAdd calling_ply

--
-- Create a zone by manually inputting coordinates (!szrawcreatezone, ulx szrawcreatezone)
--
-- This is not recommended if you just want to add
-- zones. Use szaddzone instead.
--
SZ.ULX.RawCreateZone = (calling_ply, startx, starty, startz, endx, endy, endz) ->
	ulx.fancyLogAdmin calling_ply,
		"#A now created zone"

	start = Vector startx, starty, startz
	end_ = Vector endx, endy, endz

	SZ.Zone.Add start, end_, calling_ply
	SZ.Log "zone: created"

--
-- Lets you see all zones (!szviewallon, ulx szviewallon)
--
-- By default, zones are not visible.
-- This command lets you see all zones.
--
SZ.ULX.ViewAllOn = (ply) ->
	-- Only bother viewing zones if there are any
	return unless SZ.Zone.GetAll!

	ulx.fancyLogAdmin ply, "#A now viewing all zones"

	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_ALL_ON, 4
	net.WriteTable SZ.Zone.GetAll!
	net.Send ply

--
-- Turns off global zone viewing (!szviewalloff, ulx szviewalloff)
--
-- By default, zones are not visible.
-- If you used szviewallon to view all zones, this will
-- turn it back off.
--
SZ.ULX.ViewAllOff = (ply) ->
	ulx.fancyLogAdmin ply, "#A stopped viewing all zones"

	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_ALL_OFF, 4
	net.Send ply

--
-- Displays a zone setting UI.
--
SZ.ULX.ZoneSettings = (ply) ->
	-- Confirm that the player is in a zone.
	unless SZ.Zone.PlayerInZone ply then
		ULib.tsayError ply, SZ.Lang.ULXNotInZone
		return

	thiszone = SZ.Zone.PlayerInZone ply

	ulx.fancyLogAdmin ply, "#A is changing zone settings"

	-- Send netmessage to show settings UI.
	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_SETTINGS, 4
	net.WriteTable thiszone
	net.Send ply

--
-- 	Displays the zone menu.
--
SZ.ULX.ZoneMenu = (ply) ->
	ulx.fancyLogAdmin ply, "#A opened the zone menu"

	-- Send netmessage to show zone menu.
	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_MENU, 4
	net.WriteTable SZ.Zone.GetAll! or {}
	net.Send ply

--
-- 	Changes a property of the zone you are standing in.
--
SZ.ULX.ZoneProperty = (ply, target_uuid, pr, pr_val) ->
	zones = SZ.Zone.GetAll!

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs zones do
		if zone.uuid == target_uuid then
			-- Found it.
			ulx.fancyLogAdmin ply, "#A modified zone (#{target_uuid}) property #{pr} to be #{pr_val}"

			map = game.GetMap!

			-- Create zone properties if it doesn't exist.
			unless SZ.Zone.Zones[map][k].properties then
				SZ.Zone.Zones[map][k].properties = {}

			-- Commit changes and save.
			SZ.Zone.Zones[map][k].properties[pr] = pr_val
			SZ.Zone.Save!

			for property_name, info in pairs SZ.ZoneProperties do
				if pr == property_name then
					-- If this property was enabled,
					-- call the property's OnEnable if it has one.
					if pr_val == "yes" and info.OnEnable then
						SZ.Log "zone: calling OnEnable for #{property_name}"
						info.OnEnable zone

					-- If this value was disabled,
					-- call the property's OnDisable if it has one.
					if pr_val == "no" and info.OnDisable then
						SZ.Log "zone: calling OnDisable for #{property_name}"
						info.OnDisable zone

			return

	-- Zone not found.
	ULib.tsayError ply, SZ.Lang.ULXZoneNotFound

--
-- 	Re-read zones from the zone file (zones.txt)
--
SZ.ULX.ReloadZones = (ply) ->
	ulx.fancyLogAdmin ply, "#A reloaded zones"
	SZ.Zone.Load!

SZ.ULX.GotoZone = (ply, uuid) ->
	-- Only goto a zone if there ARE any zones!...
	return unless SZ.Zone.GetAll!

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs SZ.Zone.GetAll! do
		if zone.uuid == uuid then
			-- Found it.
			ulx.fancyLogAdmin ply, "#A teleported to zone #{uuid}"

			-- Teleport to zone.
			ply\SetPos Vector(zone.start[1], zone.start[2], zone.start[3])
			return

	ULib.tsayError ply, SZ.Lang.ULXZoneNotFound

SZ.ULX.DeleteZone = (ply, uuid) ->
	-- Do not do anything if there are no zones.
	unless SZ.Zone.GetAll! then
		ULib.tsayError ply, SZ.Lang.ULXZoneNotFound
		return

	-- Find the correct zone using the supplied UUID.
	for k, zone in pairs SZ.Zone.GetAll! do
		if zone.uuid == uuid then
			-- Found it.
			ulx.fancyLogAdmin ply, "#A deleted zone #{uuid}"

			-- Remove to zone.
			table.remove SZ.Zone.Zones[game.GetMap!], k
			SZ.Zone.Save! -- Save changes.
			SZ.Zone.Rebroadcast! -- Rebroadcast zones.

			return

	ULib.tsayError ply, SZ.Lang.ULXZoneNotFound

--
-- 	Aborts the creation of a new zone. (!szstopaddingzone, ulx szstopaddingzone)
--
SZ.ULX.StopAddingZone = (calling_ply) ->
	-- Log to chat.
	ulx.fancyLogAdmin calling_ply, "#A stopped adding a zone"

	SZ.Zone.EndAdd calling_ply

cmds = {
	szviewallon:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ViewAllOn
		help: SZ.Lang.ULXViewAllOn
	szviewalloff:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ViewAllOff
		help: SZ.Lang.ULXViewAllOff
	szaddzone:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.AddZone
		help: SZ.Lang.ULXAddZone
	szstopaddingzone:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.StopAddingZone
		help: SZ.Lang.ULXStopAddingZone
	szrawcreatezone:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.RawCreateZone
		help: SZ.Lang.ULXRawCreateZone
		params: {
			{
				type: ULib.cmds.NumArg
				min: -65536, max: 65536, default: 0
				hint: "startx"
			}
			{
				type: ULib.cmds.NumArg,
				min: -65536, max: 65536, default: 0,
				hint: "starty"
			}
			{
				type: ULib.cmds.NumArg,
				min: -65536, max: 65536, default: 0,
				hint: "startz"
			}
			{
				type: ULib.cmds.NumArg,
				min: -65536, max: 65536, default: 0,
				hint: "endx"
			}
			{
				type: ULib.cmds.NumArg,
				min: -65536, max: 65536, default: 0,
				hint: "endy"
			}
			{
				type: ULib.cmds.NumArg,
				min: -65536, max: 65536, default: 0,
				hint: "endz"
			}
		}
	szreloadzones:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ReloadZones
		help: SZ.Lang.ULXReloadZones
	szzonesettings:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ZoneSettings
		help: SZ.Lang.ULXChangeZoneProperties
	szzonesetproperty:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ZoneProperty
		help: SZ.Lang.ULXChangeProperty
		params: {
			{
				type: ULib.cmds.StringArg
				hint: "uuid"
			}
			{
				type: ULib.cmds.StringArg
				hint: "propertyname"
			}
			{
				type: ULib.cmds.StringArg
				hint: "propertyvalue"
			}
		}
	szzonemenu:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.ZoneMenu
		help: SZ.Lang.ULXCmdZoneMenu
	szgotozone:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.GotoZone
		help: SZ.Lang.ULXCmdTPToZone
		params: {
			{
				type: ULib.cmds.StringArg
				hint: "uuid"
			}
		}
	szdeletezone:
		access: ULib.ACCESS_ADMIN
		func: SZ.ULX.DeleteZone
		help: SZ.Lang.ULXDeleteZone
		params: {
			{
				type: ULib.cmds.StringArg,
				hint: "uuid"
			}
		}
}

for k, cmd in pairs cmds do
	ucmd = ulx.command SZ.ULX.Category,
		"ulx #{k}", cmd.func, "!#{k}"
	ucmd\defaultAccess(cmd.access)
	ucmd\help(cmd.help)
	if cmd.params then
		[ucmd\addParam param for _, param in ipairs(cmd.params)]
