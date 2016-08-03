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

SZ.CL.Menu = {}

local WaitingForZones = false
local SelectedRowZone = nil
local function NotifyNoZone()
	surface.PlaySound("buttons/button11.wav")
	notification.AddLegacy(SZ.Lang.UISelectAZone, NOTIFY_ERROR, 3)
end
frame = nil

local SidebarButtons = {
	{
		Text = SZ.Lang.UIClientSettings,
		Icon = "icon16/wrench.png",
		Click = SZ.CL.Settings.Show,
	},

	{
		Text = SZ.Lang.UIAddZone,
		Icon = "icon16/picture_add.png",
		Click = function() RunConsoleCommand("ulx", "szaddzone") end,
	},

	{
		Text = SZ.Lang.UIGotoZone,
		Icon = "icon16/lightning_go.png",
		Click = function()
			if not SelectedRowZone then
				NotifyNoZone()
				return
			end

			RunConsoleCommand("ulx", "szgotozone", SelectedRowZone.uuid)
		end,
	},

	{
		Text = SZ.Lang.UIDeleteZone,
		Icon = "icon16/picture_delete.png",
		Click = function()
			if not SelectedRowZone then
				NotifyNoZone()
				return
			end
			SZ.Log("menu: deleting zone " .. SelectedRowZone.uuid)
			RunConsoleCommand("ulx", "szdeletezone", SelectedRowZone.uuid)

			-- Hide frame
			local x, y = frame:GetPos()
			frame:Close()
			local cx, cy = input.GetCursorPos()

			-- Show frame again
			SZ.CL.Menu.Show()

			hook.Add("SZ_CL_ZoneMenu_Open", "sz_cl_wfz_restoreui", function()
				-- Restore frame position
				if not frame then return end
				frame:SetPos(x, y)
				input.SetCursorPos(cx, cy)
				hook.Remove("SZ_CL_ZoneMenu_Open", "sz_cl_wfz_restoreui")
			end)
		end,
	},

	{
		Text = SZ.Lang.UIZoneSettings,
		Icon = "icon16/wrench.png",
		Click = function()
			if not SelectedRowZone then
				NotifyNoZone()
				return
			end

			-- Stops errors when there are no properties.
			if not SelectedRowZone.properties then
				SelectedRowZone.properties = {}
			end

			SZ.CL.Menu.ShowZoneSettings(SelectedRowZone)
		end,
	},

	{
		Text = SZ.Lang.UIViewZones,
		Icon = "icon16/eye.png",
		Click = function() RunConsoleCommand("ulx", "szviewallon") end,
	},

	{
		Text = SZ.Lang.UIStopViewZones,
		Icon = "icon16/eye.png",
		Click = function() RunConsoleCommand("ulx", "szviewalloff") end,
	},

	{
		Text = SZ.Lang.UIReloadZones,
		Icon = "icon16/picture_save.png",
		Click = function() RunConsoleCommand("ulx", "szreloadzones") end,
	},
}

local function TimeAgo(time)
	local now = os.time()
	local difference = now - time

	local one_hour = 60 * 60
	local one_day = one_hour * 24
	local one_minute = 60
	local one_week = one_day * 7

	if difference < one_minute then
		-- Less than a minute.
		return math.floor(difference) .. " second(s) ago"
	elseif difference >= one_minute and difference < one_hour then
		-- Happened more than a minute ago but less than an hour ago.
		return math.floor(difference / one_minute) .. " minute(s) ago"
	elseif difference >= one_hour and difference < one_day then
		-- Happened more than an hour ago but less than a day ago.
		return math.floor(difference / one_hour) .. " hour(s) ago"
	elseif difference >= one_day and difference < one_week then
		-- Happened more than a day ago but less than a week ago.
		return math.floor(difference / one_day) .. " day(s) ago"
	elseif difference >= one_week then
		-- Happened more than a week ago.
		return math.floor(difference / one_week) .. " week(s) ago"
	end
end

function SZ.CL.Menu.ShowZoneSettings(zone)
	local settings_frame = vgui.Create("DFrame")
	settings_frame:SetTitle(SZ.Lang.UITitleSettings)
	settings_frame:SetSize(350, 380)
	settings_frame:Center()
	settings_frame:MakePopup()

	-- Panel list for holding checkboxes and
	-- Apply button.
	local list_ = vgui.Create("DListLayout", settings_frame)
	list_:Dock(FILL)
	list_:DockMargin(10, 10, 10, 10)

	local boxes = {}

	for properties_name, info in pairs(SZ.ZoneProperties) do
		local chb = vgui.Create("DCheckBoxLabel", list_)

		-- Set nice text.
		chb:SetText(info.NiceName)

		-- If the setting is already on,
		-- then check it.
		if (zone.properties or {})[properties_name] == "yes" then
			chb:SetValue(1)
		end

		list_:Add(chb)
		boxes[properties_name] = chb
	end

	local app = vgui.Create("DButton", list_)
	app:SetText("Apply")
	function app.DoClick()
		-- Apply.
		for properties_name, checkbox in pairs(boxes) do
			SZ.Log("zoneui: modify (" .. zone.uuid .. ", " .. properties_name .. ", " .. tostring(checkbox:GetChecked()) .. ")")
			RunConsoleCommand("ulx", "szzonesetproperty",
				zone.uuid, properties_name, checkbox:GetChecked() and "yes" or "no")
		end
	end
	list_:Add(app)
end

function SZ.CL.Menu.Show()
	SZ.Log("menucl: waiting for zones")

	-- Request zones from the server.
	net.Start("sz_zones")
	net.SendToServer()

	WaitingForZones = true
end

hook.Add("SZ_CL_ZonesCached", "sz_cl_waitingforzones", function()
	if WaitingForZones then
		WaitingForZones = false
		SZ.Log("menucl: got zones")
		SZ.CL.Menu.ShowReal()
	end
end)

function SZ.CL.Menu.ShowReal()
	frame = vgui.Create("DFrame")
	frame:SetSize(500, 300)
	frame:SetTitle(SZ.Lang.UITitleMenu)
	frame:Center()
	frame:MakePopup()

	hook.Call("SZ_CL_ZoneMenu_Open", nil)

	local zones = vgui.Create("DListView", frame)
	zones:Dock(FILL)
	zones:AddColumn(SZ.Lang.UIUUID)
	zones:AddColumn(SZ.Lang.UIAddedBy)
	zones:AddColumn(SZ.Lang.UITime)

	-- Clear selected row on close.
	function frame:OnClose() SelectedRowZone = nil end

	-- When the user selects a row,
	-- update SelectedRowZone.
	function zones:OnRowSelected(num, panel)
		SelectedRowZone = SZ.CL.Zones[num]
	end

	for _, zone in ipairs(SZ.CL.Zones) do
		zones:AddLine(zone.uuid, zone.created_by, TimeAgo(zone.created_at))
	end

	-- Button list
	local buttons = vgui.Create("DPanel", frame)
	buttons:Dock(RIGHT)

	-- Override width to be wider, because some
	-- buttons have long text.
	buttons:SetWidth(150)
	buttons:InvalidateParent(true)

	for i, btninfo in ipairs(SidebarButtons) do
		-- Create button.
		local button = vgui.Create("DButton", buttons)
		button:Dock(TOP)
		button:DockMargin(5, 0, 5, 5)

		-- Set text, icon, and DoClick.
		button:SetText(btninfo.Text)
		button:SetImage(btninfo.Icon)
		button.DoClick = btninfo.Click
	end

	function buttons:Paint() end
end
