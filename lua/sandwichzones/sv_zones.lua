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

SZ.Zone = {}
SZ.Zone.Zones = {}

--[[------------------------------------------------
	Tells a player to begin the visual editing process.
------------------------------------------------]]--
function SZ.Zone.StartAdd(ply)
	hook.Call("SZ_VisualEditingStart", nil, ply)
	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_BEGIN, 4)
	net.Send(ply)
end

--[[------------------------------------------------
	Updates local client zone cache for all clients
	that have access to szaddzone.
------------------------------------------------]]--
function SZ.Zone.Rebroadcast()
	SZ.Log("zone: rebroadcasting")
	for _, ply in ipairs(player.GetAll()) do
		if ULib.ucl.query(ply, "ulx szaddzone") then
			SZ.Zone.SendAll(ply)
		end
	end
end

--[[------------------------------------------------
	Sends the table of zones to a client.
------------------------------------------------]]--
function SZ.Zone.SendAll(ply)
	SZ.Log("zone: sending zones to " .. ply:Nick() .. " (" .. ply:SteamID() .. ")")
	net.Start("sz_zones")
	net.WriteTable(SZ.Zone.GetAll() or {})
	net.Send(ply)
end

--[[------------------------------------------------
	Tells a player to abort the visual editing process.
	This does not add a new zone.
------------------------------------------------]]--
function SZ.Zone.EndAdd(ply)
	hook.Call("SZ_VisualEditingEnd", nil, ply)
	net.Start("sz_zoneui")
	net.WriteUInt(SZ.ZONEUI_END, 4)
	net.Send(ply)
end

--[[------------------------------------------------
	Saves zones to zones.txt
------------------------------------------------]]--
function SZ.Zone.Save()
	hook.Call("SZ_ZoneSave")
	SZ.Log("zone: saving zones...")
	file.Write("zones.txt", util.TableToJSON(SZ.Zone.Zones, true))
	SZ.Log("zone: done.")
	hook.Call("SZ_PostZoneSave")
end

--[[------------------------------------------------
	Loads zones from zones.txt
------------------------------------------------]]--
function SZ.Zone.Load()
	hook.Call("SZ_ZoneLoad")
	if file.Exists("zones.txt", "DATA") then
		SZ.Log("zone: found zones.txt, reading.")
		SZ.Zone.Zones = util.JSONToTable(file.Read("zones.txt"))
	else
		SZ.Log("zone: no zones.txt. not reading.")
	end
	hook.Call("SZ_PostZoneLoad")
end

--[[

Converts begin and end in zones to vectors.
Unused.

function SZ.Zone.Inflate()
	SZ.Log("zone: inflating")
	for map, _ in pairs(SZ.Zone.Zones) do
		for zonen, zone in pairs(SZ.Zone.Zones[map]) do
			-- Inflate tables into zone objects
			local start_table = zone.start
			local end_table = zone["end"]
			SZ.Zone.Zones[map][zonen].start = Vector(start_table[1], start_table[2], start_table[3])
			SZ.Zone.Zones[map][zonen]["end"] = Vector(end_table[1], end_table[2], end_table[3])
		end
	end
	SZ.Log("zone: finished inflation")
end

]]--

--[[------------------------------------------------
	Returns the zones for this map.
------------------------------------------------]]--
function SZ.Zone.GetAll()
	return SZ.Zone.Zones[game.GetMap()]
end

--[[------------------------------------------------
	Creates a new zone and saves it into the
	zone file.
------------------------------------------------]]--
function SZ.Zone.Add(start, end_, ply)
	local map = game.GetMap()

	-- Create table for this map in zones if not already created.
	if not SZ.Zone.Zones[map] then
		SZ.Log("zone: creating table for map " .. map)
		SZ.Zone.Zones[map] = {}
	end

	SZ.Log("zone: inserting")

	local override = hook.Call("SZ_ZoneAdd", nil, start, end_, ply)
	if override == false then
		SZ.Log("zone: insertion denied via hook")
		return
	end

	-- Insert the newly created zone into the zone list.
	table.insert(SZ.Zone.Zones[map], {
		["start"] = {start.x, start.y, start.z},
		["end"] = {end_.x, end_.y, end_.z},
		["created_by"] = ply:SteamID(),
		["created_by_64"] = ply:SteamID64(),
		["created_at"] = os.time(),
		["uuid"] = SZ.UUID(),
	})

	SZ.Log("zone: saving")
	SZ.Zone.Save()

	hook.Call("SZ_PostZoneAdd", nil, start, end_, ply)
end

--[[------------------------------------------------
	Hooks.
------------------------------------------------]]--
hook.Add("Initialize", "sz_load_zones", SZ.Zone.Load)
hook.Add("Initialize", "sz_check_ulx", function()
	if not ulx or not ULib then
		-- ULX not found. Whoopsies.
		SZ.ErrorBanner()
		SZ.Error(SZ.Lang.ErrUNotFound)
	end
end)
