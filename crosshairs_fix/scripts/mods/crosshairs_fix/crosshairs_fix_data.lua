local mod = get_mod("crosshairs_fix")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "shotshell_spread_alpha",
				type = "numeric",
				title = "shotshell_spread_alpha_title",
				tooltip = "shotshell_spread_alpha_tooltip",
				default_value = 255,
				range = {0, 255},
			},
		},
	},
}
