return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`crosshairs_fix` encountered an error loading the Darktide Mod Framework.")

		new_mod("crosshairs_fix", {
			mod_script       = "crosshairs_fix/scripts/mods/crosshairs_fix/crosshairs_fix",
			mod_data         = "crosshairs_fix/scripts/mods/crosshairs_fix/crosshairs_fix_data",
			mod_localization = "crosshairs_fix/scripts/mods/crosshairs_fix/crosshairs_fix_localization",
		})
	end,
	packages = {},
}
