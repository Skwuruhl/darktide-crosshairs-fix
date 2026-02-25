local mod = get_mod("crosshairs_fix")
local Crosshair = require("scripts/ui/utilities/crosshair")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local template = {
	name = "flamer",
}
local SIZE = {
	32,
	12,
}
local HALF_SIZE_X = SIZE[1] * 0.5
local HALF_SIZE_Y = SIZE[2] * 0.5
local SPREAD_DISTANCE = 10
local MIN_OFFSET = HALF_SIZE_Y + HALF_SIZE_X
local TEXTURE_ROTATION = math.rad(-90)

local function _crosshair_segment(style_id, angle)
	return table.clone({
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/crosshairs/spray_n_pray_spread",
		style_id = style_id,
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			angle = angle,
			offset = {
				0,
				0,
				1,
			},
			size = {
				SIZE[1],
				SIZE[2],
			},
			color = UIHudSettings.color_tint_main_1,
		},
	})
end

template.create_widget_defintion = function (template, scenegraph_id)
	return UIWidget.create_definition({
		Crosshair.center_dot(),
		Crosshair.hit_indicator_segment("top_left"),
		Crosshair.hit_indicator_segment("bottom_left"),
		Crosshair.hit_indicator_segment("top_right"),
		Crosshair.hit_indicator_segment("bottom_right"),
		Crosshair.weakspot_hit_indicator_segment("top_left"),
		Crosshair.weakspot_hit_indicator_segment("bottom_left"),
		Crosshair.weakspot_hit_indicator_segment("top_right"),
		Crosshair.weakspot_hit_indicator_segment("bottom_right"),
		_crosshair_segment("left", math.rad(180)+TEXTURE_ROTATION),
		_crosshair_segment("right", math.rad(0)+TEXTURE_ROTATION),
	}, scenegraph_id)
end

template.on_enter = function (widget, template, data)
	return
end

template.update_function = function (parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)

	if yaw and pitch then
		local spread_offset_y = pitch * SPREAD_DISTANCE
		local spread_offset_x = yaw * SPREAD_DISTANCE

		local styles = {style.left, style.right}
		for _,v in ipairs(styles) do
            v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, HALF_SIZE_Y, MIN_OFFSET, TEXTURE_ROTATION)
        end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end

return template
