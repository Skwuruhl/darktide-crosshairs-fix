local mod = get_mod("crosshairs_fix")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "shotshell_spread_crosshair_center",
				type = "checkbox",
				title = "shotshell_spread_crosshair_center_title",
				tooltip = "shotshell_spread_crosshair_center_tooltip",
				default_value = true,
			},
			{
				setting_id = "shotshell_spread_crosshair_disable",
				type = "checkbox",
				title = "shotshell_spread_crosshair_disable_title",
				tooltip = "shotshell_spread_crosshair_disable_tooltip",
				default_value = false,
			},
		},
	},
}
