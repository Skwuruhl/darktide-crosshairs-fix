# Darktide Crosshairs Fix

Darktide 1.4 fixed most issues with crosshairs but a few remain. Mod fixes remaining issues. Most notably I recently discovered that the vanilla crosshairs don't include spread ratio multipliers. 

Now includes shotshell pellet patterns. You can customize how spread is displayed with shotshell weapons via mod options.

Basic flamer support. It's not perfect but much more accurate than vanilla (and scales with FOV).

The mod has a function that custom crosshairs can use to properly have diagonal segments (e.g. through crosshair remap). Additionally other mods can also read the active shotshell and shotshell spread via a function. 

[Nexus Mods](https://www.nexusmods.com/warhammer40kdarktide/mods/36)

# Shotshell Explanation

In Darktide shotguns have two spread values: The shotgun itself, and then the 'shotshell'. The shotshell is a static size that determines the pellet grouping. For example, the shotpistol & shield has a pitch (up and down) deviatition of ~1.8° and yaw (left and right) deviation of ~1.4°. All of the pellets will be distributed within the ellipse determined by these values. Running, jumping, etc. will not change these values. If your shotgun has a tighter pellet grouping when ADS, like the Agripinaa, it's because your shotshell actually gets replaced with a different one while ADS.

This is where shotgun spread comes in: the shotgun spread determines where the center of your pellet grouping will land and is affected by things like movement. Some shotguns have very little spread and this won't make a big difference (aside from trying to hit snipers or something). Others like the Zarona Mk VI Combat Shotgun have ~1.2° in moving hipfire which may not sound like much, but when you consider that the shotshell spread is ~2.2°, that ~1.2° can easily make a significant portion of the shotshell miss.

# Real Spread and Config Spread Discrepancies

If you look at the configured spread values of each weapon/shotshell you'll notice a discrepancy between those values and my above example (or those used by my mod). That's because the game does additional adjustments to spread before being used as spread values that the vanilla crosshair spread function didn't take into account. The most immediate one is the "randomized_spread" table. For most weapons your first shot has a minimum spread multiplier of 0.25 with math.random adding up to 0.4 to that multiplier, to a maximum of 0.65. Shots afterward have a minimum value of 0.25 with up to 0.75 added randomly, to a maximum of 1.0. Some weapons are configured with different values though, like the Zarona combat shotgun which has 0.05 and 0.25 for first shot. This means for the first shot your maximum spread is only 0.3 times the configured spread. The Zarona's post-first shot multiplier is still 0.3 maximum, just split into 0.1 and 0.2.

Shotshells don't have such a value affecting the maximum spread, but the random multiplier for maximum deviation is calculated with math.sqrt(0.25 + 0.5 * math.random()). This puts the deviation between 0.5 and ~0.87 of the configured shotshell spread. Notably if a shotshell template has no_random_roll set to true in the config, the deviation multiplier is replaced with a static value of 1. Shotshell templates with "no_random_roll = true" actually still experience random roll, just not random deviation from center of the shotshell. You can see this with the Agripinaa combat shotgun or any horizontal line pattern. The pellets always land equidistant from the center of the pattern, but randomly rolled clockwise or counter-clockwise a bit.

If you go digging you may find some weapons have a "max_pitch_delta" (or yaw) in the "randomized_spread" table. This is a funny little value that, as best as I can tell, scales how far your next shot can land from your last shot. A value of 0.5 would cause a bullet to land halfway between where the last one landed and where the next one "would" have landed, while a value of 1 has no effect. There's not a ton of practical info here other than that for some weapons like braced autoguns, you can kinda-sorta counter-strike compensate for the spread.

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

Custom crosshairs (from Crosshair Remap or similar) should use a SPREAD_DISTANCE value of 10 and, as vanilla crosshairs have been updated to do, use horizontal_alignment and vertical_alignment of "center". If your crosshair has no diagonal segments this is all you need to do. Though you can still use the function for non-diagonal crosshairs to do things with a for loop instead of manually doing each segment of the crosshair. See example_crosshair.lua for examples of what I mean.

If you want diagonal crosshairs then use the crosshair_rotation function to get x, y coordinates. Check example_crosshair.lua for a rough example of how to use the function.

## crosshair_rotation(x, y, angle, half_crosshair_size, minimum_offset, texture_rotation)

* supplied with spread_offset_x and spread_offset_y and the angle of a crosshair segment, returns x and y coordinates adjusted for the rotation.

* half_crosshair_size is what it says. Be sure to use the correct dimension. Not optional.

* minimum_offset is the mininum number of 1080 pixels the returned x, y should be from center. e.g. a value of 1 at an angle of 45° would set a minumum x and y value of 0.707. optional.

* texture_rotation is an optional parameter in case the crosshair texture needs additional rotation. Be sure to also adjust the crosshair segment angles as needed. optional.

* As usual for lua all angles should be supplied in radians.
 
