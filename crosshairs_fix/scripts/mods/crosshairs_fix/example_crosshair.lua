local crosshair_fix = get_mod("crosshairs_fix")
local Crosshair = require("scripts/ui/utilities/crosshair")

-- manual example
mod:hook_origin(assault_new, "update_function", function(parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	local SPREAD_DISTANCE = 10

	if yaw and pitch then
		local scalar = SPREAD_DISTANCE * (crosshair_settings.spread_scalar or 1)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = yaw * scalar
		local x, y

		local top_style = style.top
		x, y = crosshair_fix.diagonal_coordinates(spread_offset_x, spread_offset_y, top_style.angle, top_style.size[1]/2, 2)

		top_style.offset[1] = x
		top_style.offset[2] = y

		local bottom_style = style.bottom
		x, y = crosshair_fix.diagonal_coordinates(spread_offset_x, spread_offset_y, bottom_style.angle, bottom_style.size[1]/2, 2)

		bottom_style.offset[1] = x
		bottom_style.offset[2] = y

		local left_style = style.left
		x, y = crosshair_fix.diagonal_coordinates(spread_offset_x, spread_offset_y, left_style.angle, left_style.size[1]/2, 2)

		left_style.offset[1] = x
		left_style.offset[2] = y

		local right_style = style.right
		x, y = crosshair_fix.diagonal_coordinates(spread_offset_x, spread_offset_y, right_style.angle, right_style.size[1]/2, 2)

		right_style.offset[1] = x
		right_style.offset[2] = y
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end)

-- for loop example
mod:hook_origin(assault_new, "update_function", function(parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	local SPREAD_DISTANCE = 10

	if yaw and pitch then
		local scalar = SPREAD_DISTANCE * (crosshair_settings.spread_scalar or 1)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = yaw * scalar
		local styles = {style.top, style.bottom, style.left, style.right}

		for i=1,4 do
			styles[i].offset[1], styles[i].offset[2] = crosshair_fix.diagonal_coordinates(spread_offset_x, spread_offset_y, styles[i].angle, styles[i].size[1]/2, 2)
		end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end)