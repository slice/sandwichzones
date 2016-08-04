SZ.Zone = {}
SZ.Zone.Zones = {}

-- Tells a player to begin the visual editing process.
SZ.Zone.StartAdd = (ply) ->
	hook.Call "SZ_VisualEditingStart", nil, ply
	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_BEGIN, 4
	net.Send ply

-- Updates local client zone cache for all clients
-- that have access to szaddzone.
SZ.Zone.Rebroadcast = ->
	SZ.Log "zone: rebroadcasting"
	for _, ply in ipairs player.GetAll! do
		if ULib.ucl.query ply, "ulx szaddzone" then
			SZ.Zone.SendAll ply

-- Sends the table of zones to a client.
SZ.Zone.SendAll = (ply) ->
	SZ.Log "zone: sending zones to #{ply\Nick!} (#{ply\SteamID!})"
	net.Start "sz_zones"
	net.WriteTable SZ.Zone.GetAll! or {}
	net.Send ply


-- Tells a player to abort the visual editing process.
-- This does not add a new zone.
SZ.Zone.EndAdd = (ply) ->
	hook.Call "SZ_VisualEditingEnd", nil, ply
	net.Start "sz_zoneui"
	net.WriteUInt SZ.ZONEUI_END, 4
	net.Send ply

-- Saves zones to zones.txt
SZ.Zone.Save = ->
	hook.Call "SZ_ZoneSave"
	SZ.Log"zone: saving zones..."
	file.Write "zones.txt", util.TableToJSON(SZ.Zone.Zones, true)
	SZ.Log"zone: done."
	hook.Call"SZ_PostZoneSave"

-- Loads zones from zones.txt
SZ.Zone.Load = ->
	hook.Call "SZ_ZoneLoad"
	if file.Exists "zones.txt", "DATA" then
		SZ.Log "zone: found zones.txt, reading."
		SZ.Zone.Zones = util.JSONToTable(file.Read "zones.txt")
	else
		SZ.Log "zone: no zones.txt. not reading."
	hook.Call "SZ_PostZoneLoad"


-- Converts begin and end in zones to vectors.
-- Unused.
-- function SZ.Zone.Inflate()
-- 	SZ.Log("zone: inflating")
-- 	for map, _ in pairs(SZ.Zone.Zones) do
-- 		for zonen, zone in pairs(SZ.Zone.Zones[map]) do
-- 			-- Inflate tables into zone objects
-- 			local start_table = zone.start
-- 			local end_table = zoneend
-- 			SZ.Zone.Zones[map][zonen].start = Vector(start_table[1], start_table[2], start_table[3])
-- 			SZ.Zone.Zones[map][zonen]end = Vector(end_table[1], end_table[2], end_table[3])
-- 		end
-- 	end
-- 	SZ.Log("zone: finished inflation")
-- end
--

-- Returns the zones for this map.
SZ.Zone.GetAll = ->
	SZ.Zone.Zones[game.GetMap()]

-- Creates a new zone and saves it into the
-- zone file.
SZ.Zone.Add = (start, end_, ply) ->
	map = game.GetMap()

	-- Create table for this map in zones if not already created.
	unless SZ.Zone.Zones[map] then
		SZ.Log("zone: creating table for map #{map}")
		SZ.Zone.Zones[map] = {}

	SZ.Log("zone: inserting")

	override = hook.Call("SZ_ZoneAdd", nil, start, end_, ply)
	if override == false then
		SZ.Log("zone: insertion denied via hook")
		return

	-- Insert the newly created zone into the zone list.
	table.insert SZ.Zone.Zones[map],
		start: { start.x, start.y, start.z },
		end: { end_.x, end_.y, end_.z },
		created_by: ply\SteamID!
		created_by_64: ply\SteamID64,
		created_at: os.time!
		uuid: SZ.UUID!

	-- Save changes.
	SZ.Log "zone: saving"
	SZ.Zone.Save!

	hook.Call "SZ_PostZoneAdd", nil, start, end_, ply

-- Hooks.
hook.Add "Initialize", "sz_load_zones", SZ.Zone.Load

hook.Add "Initialize", "sz_check_ulx", ->
	unless (ulx or ULib) then
		-- ULX not found. Whoopsies.
		SZ.ErrorBanner!
		SZ.Error SZ.Lang.ErrUNotFound
