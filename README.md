# Darktide Crosshairs Fix

Fixes crosshairs to be actually representative of spread, taking your FOV into account.

Original crosshairs equation:

    spread_in_degrees * 10

Result is the number of pixels your crosshair is placed from the screen, scaled from 1080p as baseline.

New equation:

    540 * tan(spread) / tan(current_fov / 2)