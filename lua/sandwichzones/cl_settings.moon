SZ.Log "init settings"

SettingsUISettings = {
	IgnoreZ: {
		NiceName: SZ.Lang.UIZoneIgnoreZ
		Type: "bool"
	}
}

SZ.CL.Settings.Show = ->
	frame = vgui.Create "DFrame"
	frame\SetSize 300, 400
	frame\SetTitle SZ.Lang.UITitleSettings
	frame\Center!
	frame\MakePopup!

	checks = vgui.Create "DListLayout", frame
	checks\Dock FILL

	for identifier, opt in pairs SettingsUISettings do
		-- Make checkbox when settings type is a boolean
		if opt.Type == "bool"
			checkbox = vgui.Create "DCheckBoxLabel", checks

			-- Apply text.
			checkbox\SetText opt.NiceName

			-- Check if the setting is already enabled.
			checkbox\SetChecked SZ.CL.Settings[identifier]

			-- On change, reflect changes immediately.
			checkbox.OnChange = (val) => SZ.CL.Settings[identifier] = val

			checks\Add(checkbox)
