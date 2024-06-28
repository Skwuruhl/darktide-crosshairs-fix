# Darktide Crosshairs Fix

Darktide 1.4 fixed most issues with crosshairs but a few remain. Mod fixes remaining issues. Additionally the mod now has a function that custom crosshairs can use to properly have diagonal segements.

[Nexus Mods](https://www.nexusmods.com/warhammer40kdarktide/mods/36)

# Installation

Drop the crosshairs_fix folder into your mods folder. Add "crosshairs_fix" to your mod_load_order.txt

# Math

Original crosshairs equation:

    370 * tan(spread) / tan(current_vertical_fov / 2)

Result is the number of pixels your crosshair is placed from the center of the screen, scaled from 1080p as baseline. Assault is 555 instead of 370.

New equation:

    540 * tan(spread) / tan(current_vertical_fov / 2)

Also applied to assault crosshair.

# For Modders

Custom crosshairs (from Crosshair Remap or similar) should use a SPREAD_DISTANCE value of 10. If your crosshair has no diagonal segments this is all you need to do.

If want diagonal crosshairs use the diagonal_coordinates function to get x, y coordinates. Check example_crosshair.lua for a rough example of how to use.

## diagonal_coordinates(x, y, angle, half_crosshair_size, minimum_offset, texture_rotation)

supplied with spread_offset_x and spread_offset_y and the angle of a crosshair segment, returns x and y coordinates adjusted for the rotation.

half_crosshair_size is what it says. Be sure to use the correct dimension. Not optional.

minimum_offset is the mininum number of 1080 pixels the returned x, y should be from center. e.g. a value of 1 at an angle of 45° would set a minumum x and y value of 0.707. optional.

texture_rotation is an optional parameter in case the crosshair texture needs additional rotation. Be sure to also adjust the crosshair segment angles as needed. optional.

As usual for lua all angles should be supplied in radians.
