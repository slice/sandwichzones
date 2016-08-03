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

function SZ.Zone.PlayerInZone(ply)
	local zones = SZ.Zone.GetAll()

	if not zones then return false end

	for _, zone in ipairs(zones) do
		-- If this is (somehow) an invalid zone,
		-- then return nil.
		if not zone or not zone.start or not zone["end"] then return end

		-- Convert zone range into Vectors.
		local start = Vector(zone.start[1], zone.start[2], zone.start[3])
		local end_ = Vector(zone["end"][1], zone["end"][2], zone["end"][3])

		-- Order the vectors, required by WithinAABox.
		OrderVectors(start, end_)

		-- If the player is within this zone,
		-- then return it.
		if ply:GetPos():WithinAABox(start, end_) then
			return zone
		end
	end

	-- Player not in a zone.
	return false
end
