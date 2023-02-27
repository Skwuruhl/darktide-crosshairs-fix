# Darktide Crosshairs Fix

Fixes crosshairs to be actually representative of spread, taking your FOV into account.

[Nexus Mods](https://www.nexusmods.com/warhammer40kdarktide/mods/36)

# Installation

Drop the crosshairs_fix folder into your mods folder. Add "crosshairs_fix" to your mod_load_order.txt

# Math

Original crosshairs equation:

    spread_in_degrees * 10

Result is the number of pixels your crosshair is placed from the center of the screen, scaled from 1080p as baseline.

New equation:

    540 * tan(spread) / tan(current_vertical_fov / 2)
