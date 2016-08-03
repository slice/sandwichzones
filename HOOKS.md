# Hooks #

- `SZ_Initialize`
	- Realms: Client, Server
	- Called after the SZ table is populated.
	  In other words, right before SZ is about to start.
- `SZ_VisualEditingEnd`
	- Realm: Server
	- Arguments: `(Player player)`
	- Called when a player's visual editing UI is about to
	  be hidden (the net message that hides the UI is about to be sent)
- `SZ_VisualEditingStart`
	- Realm: Server
	- Arguments: `(Player player)`
	- Called when a player's visual editing UI is about to
	  be hidden (the net message that hides the UI is about to be sent)
- `SZ_ZoneSave`
	- Realm: Server
	- Called when the zone file (zones.txt) is about to be
	  written to.
- `SZ_PostZoneSave`
	- Realm: Server
	- Called when the zone file (zones.txt) has been saved.
- `SZ_ZoneLoad`
	- Realm: Server
	- Called when the zone file (zones.txt) is about loaded
- `SZ_PostZoneLoad`
	- Realm: Server
	- Called when the zone file (zones.txt) has been loaded.
- `SZ_ZoneAdd`
	- Realm: Server
	- Arguments: `(Vector top_left, Vector bottom_right, Player creator)`
	- Called when a zone is about to be created.
	- Return false to disallow this zone from being created.
- `SZ_PostZoneAdd`
	- Realm: Server
	- Arguments: `(Vector top_left, Vector bottom_right, Player creator)`
	- Called when a zone has been created and it has been saved
	  into the zone file (zones.txt)
- `SZ_PlayerEnterZone`
	- Realm: Server
	- Arguments: `(Player player, table just_entered_zone)`
	- Called when a player enters a zone.
- `SZ_PlayerExitZone`
	- Realm: Server
	- Arguments: `(Player player, table just_exited_zone)`
	- Called when a player exits a zone.
- `SZ_PlayerInZoneUpdate`
	- Realm: Server
	- Arguments: `(Player player, table zone)`
	- Called continuously while a player is inside of a zone.
- `SZ_CL_ZonesCached`
	- Realm: Client
	- Arguments: `(table zone)`
	- Called when the client recieves the table of zones from the server.
- `SZ_CL_ZoneMenu_Open`
	- Realm: Client
	- Called when the zone menu opens (frame is open)
