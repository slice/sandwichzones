SZ.Log "init zoneui"

-- Settings
SZ.CL = {}
SZ.CL.Active = false
SZ.CL.PanelMargin = 20
SZ.CL.PanelPadding = 10

SZ.CL.Settings = {}
SZ.CL.Settings.IgnoreZ = false

-- Clientside zones from server
SZ.CL.DrawAllZones = false
SZ.CL.Zones = {}

-- Visual editing
SZ.CL.FirstPos = nil
SZ.CL.SecondPos = nil
SZ.CL.Stage = 0

-- Draws the boxes at the top left of the screen
-- that tells you what you are doing.
SZ.CL.DrawUI = ->
	-- Only draw UI when we are adding a zone.
	return unless SZ.CL.Active

	surface.SetFont "DermaLarge"
	w, h = surface.GetTextSize SZ.Lang.AddingZone

	-- DRAW: Drawing Zone huge text panel.
	draw.RoundedBox 5, SZ.CL.PanelMargin, SZ.CL.PanelMargin,
		w + SZ.CL.PanelPadding * 2, -- Width
		50, -- Height
		Color 0, 0, 0, 200

	draw.DrawText SZ.Lang.AddingZone, "DermaLarge",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding, SZ.CL.PanelMargin + SZ.CL.PanelPadding

	-- DRAW: Adding zone note. Describes what you are
	-- doing right now.
	surface.SetFont "DermaDefault"
	w, h = surface.GetTextSize SZ.Lang.AddingZoneNote
	draw.RoundedBox 5, SZ.CL.PanelMargin,
		SZ.CL.PanelMargin + 50 + 10, -- Account for padding + previous panels
		w + SZ.CL.PanelPadding * 2, -- Width
		30, -- Height
		Color 0, 0, 0, 200

	draw.DrawText SZ.Lang.AddingZoneNote, "DermaDefault",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding, SZ.CL.PanelMargin + 50 + SZ.CL.PanelPadding + h / 2 + 1

  --	DRAW: How to stop adding a zone.
	w, h = surface.GetTextSize SZ.Lang.AddingZoneStop
	draw.RoundedBox 5, SZ.CL.PanelMargin, SZ.CL.PanelMargin + 30 + 50 + 10 * 2,
		w + SZ.CL.PanelPadding * 2, -- Width
		30, -- Height
		Color 0, 0, 0, 200

	draw.DrawText SZ.Lang.AddingZoneStop, "DermaDefault",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding,
		SZ.CL.PanelMargin + 30 + 50 + SZ.CL.PanelPadding * 2 + h / 2 + 1

-- 	Draws a zone.
SZ.CL.DrawZone = (origin, end_) ->
	-- Calculate maxs from origin.
	maxs = Vector end_.x, end_.y, end_.z
	maxs\Sub origin

	-- Draw outline.
	render.DrawWireframeBox origin,
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		maxs,
		Color(255, 255, 0),
		not SZ.CL.Settings.IgnoreZ

	-- Draw fill.
	render.DrawBox origin,
		Angle(0, 0, 0), Vector(0, 0, 0), maxs, Color(255, 255, 255, 50), not SZ.CL.Settings.IgnoreZ

SZ.CL.DrawBoxes = ->
	-- Start 3D rendering context.
	-- Ignore lighting, colorize material.
	cam.Start3D!
	render.SuppressEngineLighting true
	render.SetColorMaterial!

	-- Draw all zones.
	if SZ.CL.DrawAllZones
		for _, zone in ipairs(SZ.CL.Zones) do
			-- Render zones.
			--
			-- We don't actually store the Vector objects themselves,
			-- so we need to manually construct them.
			SZ.CL.DrawZone Vector(zone.start[1], zone.start[2], zone.start[3]),
				Vector(zone.end[1], zone.end[2], zone.end[3])

	unless SZ.CL.Active
		-- If we aren't active, then that means we won't
		-- render the "visual editing" boxes.
		--
		-- Stop our context then return.
		render.SuppressEngineLighting false
		cam.End3D!
		return

	-- Draw Stage 1 box.
	SZ.CL.DrawZone LocalPlayer!\GetPos!, SZ.CL.FirstPos if SZ.CL.Stage == 1

	-- Draw player box at feet.
	--
	-- This is handy during the visual editing process.
	render.DrawWireframeBox LocalPlayer!\GetPos!,
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		Vector(10, 10, 10),
		Color(255, 255, 255),
		true
	render.DrawBox LocalPlayer!\GetPos!,
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		Vector(10, 10, 10),
		Color(255, 255, 255, 50),
		true

	render.SuppressEngineLighting false
	cam.End3D!

-- Show notification, and play a sound.
SZ.CL.Notify = (text) ->
	notification.AddLegacy text, NOTIFY_HINT, 7
	surface.PlaySound "garrysmod/content_downloaded.wav"

--	This function is used for handling commands that
--	are used during the visual editing process.
--
--	For the time being, this only handles !szmark,
--	and is not part of ULX.
SZ.CL.HandleCMD = (ply, text, teamonly, dead) ->
	tokens = string.Split(text, " ")

	if tokens[1] == "!szmark"
		return true unless SZ.CL.Active

		SZ.CL.Stage += 1
		SZ.Log("zoneui: stage: " .. SZ.CL.Stage)

		if SZ.CL.Stage == 1
			-- Mark top left corner of cubical area
			SZ.CL.FirstPos = LocalPlayer!\GetPos!
			SZ.CL.Notify SZ.Lang.HintStage1
		elseif SZ.CL.Stage == 2
			SZ.CL.Notify SZ.Lang.HintStage2

			-- Mark bottom right corner of cubical area
			SZ.CL.SecondPos = LocalPlayer!\GetPos!
			SZ.CL.Stage = 0
			SZ.CL.Active = false

			-- Shhh.
			--
			-- Execute command to create a zone.
			-- The visual editing is only a "frontend".
			RunConsoleCommand "ulx", "szrawcreatezone",
				tostring(SZ.CL.FirstPos.x),
				tostring(SZ.CL.FirstPos.y),
				tostring(SZ.CL.FirstPos.z),
				tostring(SZ.CL.SecondPos.x),
				tostring(SZ.CL.SecondPos.y),
				tostring(SZ.CL.SecondPos.z)

			-- Attempt to recache zones.
			net.Start("sz_zones")
			net.SendToServer!
		return true

-- sz_zoneui messages are sent from the server to the
-- client to signal a state change.
--
-- ZONEUI_BEGIN: Start the visual editing process.
-- ZONEUI_END: Abort the visual editing process (does not create a zone)
-- ZONEUI_ALL_ON: Shows all zones.
-- ZONEUI_ALL_OFF: Stops showing all zones.
net.Receive "sz_zoneui", ->
	action = net.ReadUInt 4

	if action == SZ.ZONEUI_BEGIN
		-- Begin visual editing.
		SZ.Log("zoneui: begin")
		SZ.CL.Active = true
		SZ.CL.Stage = 0
		SZ.CL.Notify SZ.Lang.HintStage0
	elseif action == SZ.ZONEUI_END
		-- End visual editing.
		SZ.Log "zoneui: end"
		SZ.CL.Active = false
	elseif action == SZ.ZONEUI_ALL_ON
		-- Begin all viewing.
		SZ.Log "zoneui: all on"

		-- Because zones are stored on the server,
		-- it needs to be sent to us.
		SZ.CL.Zones = net.ReadTable!
		SZ.CL.DrawAllZones = true
	elseif action == SZ.ZONEUI_ALL_OFF
		-- Stop all viewing.
		SZ.Log "zoneui: all off"
		-- SZ.CL.Zones = {}
		-- Keep zones cached.
		SZ.CL.DrawAllZones = false
	elseif action == SZ.ZONEUI_SETTINGS
		-- Show this zone's settings panel.
		zone = net.ReadTable!
		SZ.CL.Menu.ShowZoneSettings zone
	elseif action == SZ.ZONEUI_MENU
		SZ.CL.Menu.Show!

-- Receive zones from the server.
net.Receive "sz_zones", ->
	SZ.Log("zoneui: cached new zones from server.")
	data = net.ReadTable!
	SZ.CL.Zones = data
	hook.Call "SZ_CL_ZonesCached", nil, data

hook.Add "HUDPaint", "sz_cl_drawzoneui", SZ.CL.DrawUI
hook.Add "OnPlayerChat", "sz_cl_cmdhandler", SZ.CL.HandleCMD
hook.Add "PostDrawOpaqueRenderables", "sz_cd_drawzoneui_boxes", SZ.CL.DrawBoxes
