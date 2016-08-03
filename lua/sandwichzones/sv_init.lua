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

include("sv_uuid.lua")
include("sv_net.lua")
include("sv_zones.lua")
include("sv_zonemath.lua")

timer.Create("sz_zone_update", 0.2, 0, function()
	-- Don't update if we don't have any zones.
	if not SZ.Zone.GetAll() then return end

	-- Check all players if they are in zones.
	for _, ply in ipairs(player.GetAll()) do
		-- Check if they are actually in a zone.
		local zone = SZ.Zone.PlayerInZone(ply)

		-- Update their CurrentZone, and call hooks.
		if zone then
			if not ply.CurrentZone then
				-- Player entered zone.
				hook.Call("SZ_PlayerEnterZone", nil, ply, zone)
				SZ.Log("player " .. ply:Nick() .. " has entered zone")
			end
			ply.CurrentZone = zone
			hook.Call("SZ_PlayerInZoneUpdate", nil, ply, zone)
		else
			if ply.CurrentZone ~= nil then
				-- Player exited zone.
				hook.Call("SZ_PlayerExitZone", nil, ply, ply.CurrentZone)
				SZ.Log("player " .. ply:Nick() .. " has exited zone")
			end
			ply.CurrentZone = nil
		end
	end
end)

-- Used for handling zone properties defined in sh_zoneproperties.lua.
hook.Add("SZ_PlayerEnterZone", "sz_zone_property_action_enter", function(ply, zone)
	local zoneprops = zone.properties or {}

	-- For each property of this zone, check if it is defined in
	-- SZ.ZoneProperties and the value isn't "no".
	--
	-- If so, call OnEnter.
	for property, property_value in pairs(zoneprops) do
		-- Only call it if:
		-- - The actual property code exists
		-- - The property has a value
		-- - The property's value isn't "no"
		-- - OnEnter exists
		if SZ.ZoneProperties[property] and
			property_value and
			property_value ~= "no" and
			SZ.ZoneProperties[property].OnEnter then
			SZ.Log("zone: calling property " .. property .. " (" .. property_value .. ")")
			SZ.ZoneProperties[property].OnEnter(ply, zone)
		end
	end
end)

-- Used for handling zone properties defined in sh_zoneproperties.lua.
hook.Add("SZ_PlayerExitZone", "sz_zone_property_action_exit", function(ply, zone)
	local zoneprops = zone.properties or {}

	-- For each property of this zone, check if it is defined in
	-- SZ.ZoneProperties and the value isn't "no".
	--
	-- If so, call OnExit.
	for property, property_value in pairs(zoneprops) do
		-- Only call it if:
		-- - The actual property code exists
		-- - The property has a value
		-- - The property's value isn't "no"
		-- - OnExit exists
		if SZ.ZoneProperties[property] and
			property_value and
			property_value ~= "no" and
			SZ.ZoneProperties[property].OnExit then
			SZ.ZoneProperties[property].OnExit(ply, zone)
		end
	end
end)
