return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Crosshairs Fix` encountered an error loading the Darktide Mod Framework.")

		new_mod("Crosshairs Fix", {
			mod_script       = "Crosshairs Fix/scripts/mods/Crosshairs Fix/Crosshairs Fix",
			mod_data         = "Crosshairs Fix/scripts/mods/Crosshairs Fix/Crosshairs Fix_data",
			mod_localization = "Crosshairs Fix/scripts/mods/Crosshairs Fix/Crosshairs Fix_localization",
		})
	end,
	packages = {},
}
