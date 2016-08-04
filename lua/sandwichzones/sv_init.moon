include "sv_uuid.lua"
include "sv_net.lua"
include "sv_zones.lua"
include "sv_zonemath.lua"

timer.Create "sz_zone_update", 0.2, 0, ->
	-- Don't update if we don't have any zones.
	return unless SZ.Zone.GetAll!

	-- Check all players if they are in zones.
	for _, ply in ipairs player.GetAll! do
		-- Check if they are actually in a zone.
		zone = SZ.Zone.PlayerInZone ply

		-- Update their CurrentZone, and call hooks.
		if zone then
			unless ply.CurrentZone then
				-- Player entered zone.
				hook.Call "SZ_PlayerEnterZone", nil, ply, zone
				SZ.Log "player #{ply\Nick!} has entered zone"

			ply.CurrentZone = zone
			hook.Call "SZ_PlayerInZoneUpdate", nil, ply, zone
		else
			if ply.CurrentZone ~= nil then
				-- Player exited zone.
				hook.Call "SZ_PlayerExitZone", nil, ply, ply.CurrentZone
				SZ.Log "player #{ply\Nick!} has exited zone"

			ply.CurrentZone = nil

-- Used for handling zone properties defined in sh_zoneproperties.lua.
hook.Add "SZ_PlayerEnterZone", "sz_zone_property_action_enter", (ply, zone) ->
	zoneprops = zone.properties or {}

	-- For each property of this zone, check if it is defined in
	-- SZ.ZoneProperties and the value isn't "no".
	--
	-- If so, call OnEnter.
	for property, property_value in pairs zoneprops do
		-- Only call it if:
		-- - The actual property code exists
		-- - The property has a value
		-- - The property's value isn't "no"
		-- - OnEnter exists
		if SZ.ZoneProperties[property] and
			property_value and
			property_value ~= "no" and
			SZ.ZoneProperties[property].OnEnter then
			SZ.Log "zone: calling property #{property} (#{property_value})"
			SZ.ZoneProperties[property].OnEnter ply, zone

-- Used for handling zone properties defined in sh_zoneproperties.lua.
hook.Add "SZ_PlayerExitZone", "sz_zone_property_action_exit", (ply, zone) ->
	zoneprops = zone.properties or {}

	-- For each property of this zone, check if it is defined in
	-- SZ.ZoneProperties and the value isn't "no".
	--
	-- If so, call OnExit.
	for property, property_value in pairs zoneprops do
		-- Only call it if:
		-- - The actual property code exists
		-- - The property has a value
		-- - The property's value isn't "no"
		-- - OnExit exists
		if SZ.ZoneProperties[property] and
			property_value and
			property_value ~= "no" and
			SZ.ZoneProperties[property].OnExit then
			SZ.ZoneProperties[property].OnExit ply, zone
