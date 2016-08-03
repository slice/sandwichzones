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

SZ.Log("init zoneui")

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

--[[------------------------------------------------
	Draws the boxes at the top left of the screen
	that tells you what you are doing.
------------------------------------------------]]--
function SZ.CL.DrawUI()
	-- Only draw UI when we are adding a zone.
	if not SZ.CL.Active then return end

	surface.SetFont("DermaLarge")
	local w, h = surface.GetTextSize(SZ.Lang.AddingZone)

	--[[------------------------------------------------
		DRAW: Drawing Zone huge text panel.
	------------------------------------------------]]--
	draw.RoundedBox(5,
		-- X position
		SZ.CL.PanelMargin,
		-- Y position
		SZ.CL.PanelMargin,
		-- Panel width
		-- Size of text + Padding * 2
		w + SZ.CL.PanelPadding * 2,
		-- Panel height
		50,
		Color(0, 0, 0, 200)
	)
	draw.DrawText(SZ.Lang.AddingZone, "DermaLarge",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding, SZ.CL.PanelMargin + SZ.CL.PanelPadding)

	--[[------------------------------------------------
		DRAW: Adding zone note. Describes what you are
		doing right now.
	------------------------------------------------]]--
	surface.SetFont("DermaDefault")
	w, h = surface.GetTextSize(SZ.Lang.AddingZoneNote)
	draw.RoundedBox(5,
		-- X position
		SZ.CL.PanelMargin,
		-- Y position
		-- Should obey margin.
		-- Add 50 to account for the previous panel.
		-- Should obey padding.
		SZ.CL.PanelMargin + 50 + 10,
		-- Panel width
		w + SZ.CL.PanelPadding * 2,
		-- Panel height
		30,
		Color(0, 0, 0, 200)
	)
	draw.DrawText(SZ.Lang.AddingZoneNote, "DermaDefault",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding, SZ.CL.PanelMargin + 50 + SZ.CL.PanelPadding + h / 2 + 1)

	--[[------------------------------------------------
		DRAW: How to stop adding a zone.
	------------------------------------------------]]--
	w, h = surface.GetTextSize(SZ.Lang.AddingZoneStop)
	draw.RoundedBox(5,
		-- X position
		SZ.CL.PanelMargin,
		-- Y position
		-- Obey margin + padding
		-- Move down from previous panels.
		SZ.CL.PanelMargin + 30 + 50 + 10 * 2,
		-- Panel width
		w + SZ.CL.PanelPadding * 2,
		-- Panel height
		30,
		Color(0, 0, 0, 200)
	)
	draw.DrawText(SZ.Lang.AddingZoneStop, "DermaDefault",
		SZ.CL.PanelMargin + SZ.CL.PanelPadding,
		SZ.CL.PanelMargin + 30 + 50 + SZ.CL.PanelPadding * 2 + h / 2 + 1)
end

--[[------------------------------------------------
	Draws a zone.
------------------------------------------------]]--
function SZ.CL.DrawZone(origin, end_)
	-- Calculate maxs from origin.
	local maxs = Vector(end_.x, end_.y, end_.z)
	maxs:Sub(origin)

	-- Draw outline.
	render.DrawWireframeBox(
		origin,
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		maxs,
		Color(255, 255, 0),
		not SZ.CL.Settings.IgnoreZ
	)

	-- Draw fill.
	render.DrawBox(
		origin, Angle(0, 0, 0), Vector(0, 0, 0), maxs, Color(255, 255, 255, 50), not SZ.CL.Settings.IgnoreZ)
end

function SZ.CL.DrawBoxes()
	-- Start 3D rendering context.
	-- Ignore lighting, colorize material.
	cam.Start3D()
	render.SuppressEngineLighting(true)
	render.SetColorMaterial()

	-- Draw all zones.
	if SZ.CL.DrawAllZones then
		for _, zone in ipairs(SZ.CL.Zones) do
			-- Render zones.
			--
			-- We don't actually store the Vector objects themselves,
			-- so we need to manually construct them.
			SZ.CL.DrawZone(Vector(zone.start[1], zone.start[2], zone.start[3]),
				Vector(zone["end"][1], zone["end"][2], zone["end"][3]))
		end
	end

	if not SZ.CL.Active then
		-- If we aren't active, then that means we won't
		-- render the "visual editing" boxes.
		--
		-- Stop our context then return.
		render.SuppressEngineLighting(false)
		cam.End3D()
		return
	end

	-- Draw Stage 1 box.
	if SZ.CL.Stage == 1 then
		SZ.CL.DrawZone(LocalPlayer():GetPos(), SZ.CL.FirstPos)
	end

	-- Draw player box at feet.
	--
	-- This is handy during the visual editing process.
	render.DrawWireframeBox(
		LocalPlayer():GetPos(),
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		Vector(10, 10, 10),
		Color(255, 255, 255),
		true)
	render.DrawBox(
		LocalPlayer():GetPos(),
		Angle(0, 0, 0),
		Vector(0, 0, 0),
		Vector(10, 10, 10),
		Color(255, 255, 255, 50),
		true)

	render.SuppressEngineLighting(false)
	cam.End3D()
end

--[[------------------------------------------------
	Show notification, and play a sound.
------------------------------------------------]]--
function SZ.CL.Notify(text)
	notification.AddLegacy(text, NOTIFY_HINT, 7)
	surface.PlaySound("garrysmod/content_downloaded.wav")
end

--[[------------------------------------------------
	This function is used for handling commands that
	are used during the visual editing process.

	For the time being, this only handles !szmark,
	and is not part of ULX.
------------------------------------------------]]--
function SZ.CL.HandleCMD(ply, text, teamonly, dead)
	local tokens = string.Split(text, " ")

	if tokens[1] == "!szmark" then
		if not SZ.CL.Active then return true end

		SZ.CL.Stage = SZ.CL.Stage + 1
		SZ.Log("zoneui: stage: " .. SZ.CL.Stage)

		if SZ.CL.Stage == 1 then
			-- Mark top left corner of cubical area
			SZ.CL.FirstPos = LocalPlayer():GetPos()
			SZ.CL.Notify(SZ.Lang.HintStage1)
		elseif SZ.CL.Stage == 2 then
			SZ.CL.Notify(SZ.Lang.HintStage2)

			-- Mark bottom right corner of cubical area
			SZ.CL.SecondPos = LocalPlayer():GetPos()
			SZ.CL.Stage = 0
			SZ.CL.Active = false

			-- Shhh.
			--
			-- Execute command to create a zone.
			-- The visual editing is only a "frontend".
			RunConsoleCommand("ulx", "szrawcreatezone",
				tostring(SZ.CL.FirstPos.x),
				tostring(SZ.CL.FirstPos.y),
				tostring(SZ.CL.FirstPos.z),
				tostring(SZ.CL.SecondPos.x),
				tostring(SZ.CL.SecondPos.y),
				tostring(SZ.CL.SecondPos.z))

			-- Attempt to recache zones.
			net.Start("sz_zones")
			net.SendToServer()

			return true
		end
		return true
	end
end

--[[------------------------------------------------
	sz_zoneui messages are sent from the server to the
	client to signal a state change.

	ZONEUI_BEGIN: Start the visual editing process.
	ZONEUI_END: Abort the visual editing process (does not create a zone)
	ZONEUI_ALL_ON: Shows all zones.
	ZONEUI_ALL_OFF: Stops showing all zones.
------------------------------------------------]]--
net.Receive("sz_zoneui", function()
	local action = net.ReadUInt(4)

	if action == SZ.ZONEUI_BEGIN then
		-- Begin visual editing.
		SZ.Log("zoneui: begin")
		SZ.CL.Active = true
		SZ.CL.Stage = 0
		SZ.CL.Notify(SZ.Lang.HintStage0)
	elseif action == SZ.ZONEUI_END then
		-- End visual editing.
		SZ.Log("zoneui: end")
		SZ.CL.Active = false
	elseif action == SZ.ZONEUI_ALL_ON then
		-- Begin all viewing.
		SZ.Log("zoneui: all on")

		-- Because zones are stored on the server,
		-- it needs to be sent to us.
		SZ.CL.Zones = net.ReadTable()
		SZ.CL.DrawAllZones = true
	elseif action == SZ.ZONEUI_ALL_OFF then
		-- Stop all viewing.
		SZ.Log("zoneui: all off")
		-- SZ.CL.Zones = {}
		-- Keep zones cached.
		SZ.CL.DrawAllZones = false
	elseif action == SZ.ZONEUI_SETTINGS then
		-- Show this zone's settings panel.
		local zone = net.ReadTable()
		SZ.CL.Menu.ShowZoneSettings(zone)
	elseif action == SZ.ZONEUI_MENU then
		SZ.CL.Menu.Show()
	end
end)

net.Receive("sz_zones", function()
	SZ.Log("zoneui: cached new zones from server.")
	local data = net.ReadTable()
	SZ.CL.Zones = data
	hook.Call("SZ_CL_ZonesCached", nil, data)
end)

hook.Add("HUDPaint", "sz_cl_drawzoneui", SZ.CL.DrawUI)
hook.Add("OnPlayerChat", "sz_cl_cmdhandler", SZ.CL.HandleCMD)
hook.Add("PostDrawOpaqueRenderables", "sz_cd_drawzoneui_boxes", SZ.CL.DrawBoxes)
