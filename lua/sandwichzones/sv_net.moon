util.AddNetworkString "sz_zoneui"
util.AddNetworkString "sz_zones"

-- sz_zones from clients:
-- A request to get zones from us!
net.Receive "sz_zones", (len, ply) ->
	-- Only send them zones if they have permission to add zones.
	return unless ULib.ucl.query ply, "ulx szaddzone"

	-- Send zones.
	SZ.Zone.SendAll ply
