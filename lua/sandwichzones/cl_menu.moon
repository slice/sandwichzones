SZ.CL.Menu = {}

WaitingForZones = false
SelectedRowZone = nil
NotifyNoZone = ->
	surface.PlaySound "buttons/button11.wav"
	notification.AddLegacy SZ.Lang.UISelectAZone, NOTIFY_ERROR, 3

frame = nil

SidebarButtons = {
	{
		Text: SZ.Lang.UIClientSettings
		Icon: "icon16/wrench.png"
		Click: SZ.CL.Settings.Show
	},

	{
		Text: SZ.Lang.UIAddZone
		Icon: "icon16/picture_add.png"
		Click: -> RunConsoleCommand "ulx", "szaddzone"
	},

	{
		Text: SZ.Lang.UIGotoZone
		Icon: "icon16/lightning_go.png"
		Click: ->
			if not SelectedRowZone then
				NotifyNoZone!
				return

			RunConsoleCommand "ulx", "szgotozone", SelectedRowZone.uuid
	},

	{
		Text: SZ.Lang.UIDeleteZone,
		Icon: "icon16/picture_delete.png",
		Click: ->
			if not SelectedRowZone then
				NotifyNoZone!
				return

			SZ.Log "menu: deleting zone #{SelectedRowZone.uuid}"
			RunConsoleCommand "ulx", "szdeletezone", SelectedRowZone.uuid

			-- Hide frame
			x, y = frame\GetPos()
			frame\Close()
			cx, cy = input.GetCursorPos()

			-- Show frame again
			SZ.CL.Menu.Show()

			hook.Add "SZ_CL_ZoneMenu_Open", "sz_cl_wfz_restoreui", ->
				-- Restore frame position
				return unless frame

				frame\SetPos(x, y)
				input.SetCursorPos(cx, cy)
				hook.Remove("SZ_CL_ZoneMenu_Open", "sz_cl_wfz_restoreui")
	},

	{
		Text: SZ.Lang.UIZoneSettings,
		Icon: "icon16/wrench.png",
		Click: ->
			if not SelectedRowZone then
				NotifyNoZone!
				return

			-- Stops errors when there are no properties.
			SelectedRowZone.properties = {} unless SelectedRowZone.properties

			SZ.CL.Menu.ShowZoneSettings(SelectedRowZone)
	},

	{
		Text: SZ.Lang.UIViewZones
		Icon: "icon16/eye.png"
		Click: -> RunConsoleCommand("ulx", "szviewallon")
	},

	{
		Text: SZ.Lang.UIStopViewZones
		Icon: "icon16/eye.png"
		Click: -> RunConsoleCommand("ulx", "szviewalloff")
	},

	{
		Text: SZ.Lang.UIReloadZones
		Icon: "icon16/picture_save.png"
		Click: -> RunConsoleCommand("ulx", "szreloadzones")
	},
}

TimeAgo = (time) ->
	now = os.time()
	difference = now - time

	one_hour = 60 * 60
	one_day = one_hour * 24
	one_minute = 60
	one_week = one_day * 7

	if difference < one_minute then
		-- Less than a minute.
		return "#{math.floor difference} second(s) ago"
	elseif difference >= one_minute and difference < one_hour then
		-- Happened more than a minute ago but less than an hour ago.
		return "#{math.floor difference / one_minute} minute(s) ago"
	elseif difference >= one_hour and difference < one_day then
		-- Happened more than an hour ago but less than a day ago.
		return "#{math.floor difference / one_hour} hour(s) ago"
	elseif difference >= one_day and difference < one_week then
		-- Happened more than a day ago but less than a week ago.
		return "#{math.floor difference / one_day} day(s) ago"
	elseif difference >= one_week then
		-- Happened more than a week ago.
		return "#{math.floor difference / one_week} week(s) ago"

SZ.CL.Menu.ShowZoneSettings = (zone) ->
	settings_frame = vgui.Create "DFrame"
	settings_frame\SetTitle SZ.Lang.UITitleSettings
	settings_frame\SetSize 350, 380
	settings_frame\Center!
	settings_frame\MakePopup!

	-- Panel list for holding checkboxes and
	-- Apply button.
	list_ = vgui.Create("DListLayout", settings_frame)
	list_\Dock FILL
	list_\DockMargin 10, 10, 10, 10

	boxes = {}

	for properties_name, info in pairs(SZ.ZoneProperties) do
		chb = vgui.Create "DCheckBoxLabel", list_

		-- Set nice text.
		chb\SetText(info.NiceName)

		-- If the setting is already on,
		-- then check it.
		chb\SetValue(1) if (zone.properties or {})[properties_name] == "yes"

		list_\Add(chb)
		boxes[properties_name] = chb

	app = vgui.Create "DButton", list_
	app\SetText("Apply")

	app.DoClick = =>
		-- Apply.
		for properties_name, checkbox in pairs boxes do
			SZ.Log "zoneui: modify (#{zone.uuid}, #{properties_name}, #{tostring(checkbox\GetChecked!)}"
			RunConsoleCommand "ulx", "szzonesetproperty",
				zone.uuid, properties_name, checkbox\GetChecked() and "yes" or "no"

	list_\Add(app)

SZ.CL.Menu.Show = ->
	SZ.Log "menucl: waiting for zones"

	-- Request zones from the server.
	net.Start "sz_zones"
	net.SendToServer!

	WaitingForZones = true

hook.Add "SZ_CL_ZonesCached", "sz_cl_waitingforzones", ->
	if WaitingForZones then
		WaitingForZones = false
		SZ.Log "menucl: got zones"
		SZ.CL.Menu.ShowReal!

SZ.CL.Menu.ShowReal = ->
	frame = vgui.Create "DFrame"
	frame\SetSize 500, 300
	frame\SetTitle SZ.Lang.UITitleMenu
	frame\Center!
	frame\MakePopup!

	hook.Call "SZ_CL_ZoneMenu_Open"

	zones = vgui.Create "DListView", frame
	zones\Dock FILL
	zones\AddColumn SZ.Lang.UIUUID
	zones\AddColumn SZ.Lang.UIAddedBy
	zones\AddColumn SZ.Lang.UITime

	-- Clear selected row on close.
	frame.OnClose = => SelectedRowZone = nil

	-- When the user selects a row,
	-- update SelectedRowZone.
	zones.OnRowSelected = (num, panel) =>
		SelectedRowZone = SZ.CL.Zones[num]

	-- Add all zones into the DListView.
	[zones\AddLine zone.uuid, zone.created_by, TimeAgo(zone.created_at) for _, zone in ipairs SZ.CL.Zones]

	-- Button list
	buttons = vgui.Create "DPanel", frame
	buttons\Dock RIGHT

	-- Override width to be wider, because some
	-- buttons have long text.
	buttons\SetWidth 150
	buttons\InvalidateParent true

	for i, btninfo in ipairs SidebarButtons do
		-- Create button.
		button = vgui.Create "DButton", buttons
		button\Dock TOP
		button\DockMargin 5, 0, 5, 5

		-- Set text, icon, and DoClick.
		button\SetText btninfo.Text
		button\SetImage btninfo.Icon
		button.DoClick = btninfo.Click

	buttons.Paint = ->
