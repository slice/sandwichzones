SZ.Zone.PlayerInZone = (ply) ->
	zones = SZ.Zone.GetAll()

	return false unless zones

	for _, zone in ipairs zones do
		-- If this is (somehow) an invalid zone,
		-- then return nil.
		return unless (zone and zone.start and zone.end)

		-- Convert zone range into Vectors.
		start = Vector zone.start[1], zone.start[2], zone.start[3]
		end_ = Vector zone.end[1], zone.end[2], zone.end[3]

		-- Order the vectors, required by WithinAABox.
		OrderVectors start, end_

		-- If the player is within this zone,
		-- then return it.
		if ply\GetPos!\WithinAABox start, end_ then
			return zone

	-- Player not in a zone.
	false
