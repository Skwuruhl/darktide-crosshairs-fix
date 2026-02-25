local mod = get_mod("crosshairs_fix")
local Crosshair = require("scripts/ui/utilities/crosshair")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local template = {
	name = "shotshell_wide",
}
local SPREAD_DISTANCE = 10
local TEXTURE_ROTATION = math.rad(-90)

local SHOTSHELL_SIZE = {
	24,
	8,
}
local SHOTSHELL_HALF_SIZE_X = SHOTSHELL_SIZE[1] * 0.5
local SHOTSHELL_HALF_SIZE_Y = SHOTSHELL_SIZE[2] * 0.5
local SHOTSHELL_MIN_OFFSET = SHOTSHELL_HALF_SIZE_Y + SHOTSHELL_HALF_SIZE_X

local function _shotshell_crosshair_segment(style_id, angle)
	return table.clone({
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/crosshairs/shotgun_spread_2",
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
				SHOTSHELL_SIZE[1],
				SHOTSHELL_SIZE[2],
			},
			color = UIHudSettings.color_tint_main_1,
		},
	})
end

local DEVIATION_SIZE = {
	8,
	4,
}
local DEVIATION_HALF_SIZE_X = DEVIATION_SIZE[1] * 0.5
local DEVIATION_HALF_SIZE_Y = DEVIATION_SIZE[2] * 0.5
local DEVIATION_MIN_OFFSET = DEVIATION_HALF_SIZE_X + DEVIATION_HALF_SIZE_Y

local function _deviation_crosshair_segment(style_id, angle)
	return table.clone({
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/crosshairs/default_spread",
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
				DEVIATION_SIZE[1],
				DEVIATION_SIZE[2],
			},
			color = UIHudSettings.color_tint_main_1,
		},
	})
end

template.create_widget_defintion = function (template, scenegraph_id)
	return UIWidget.create_definition({
		Crosshair.hit_indicator_segment("top_left"),
		Crosshair.hit_indicator_segment("bottom_left"),
		Crosshair.hit_indicator_segment("top_right"),
		Crosshair.hit_indicator_segment("bottom_right"),
		Crosshair.weakspot_hit_indicator_segment("top_left"),
		Crosshair.weakspot_hit_indicator_segment("bottom_left"),
		Crosshair.weakspot_hit_indicator_segment("top_right"),
		Crosshair.weakspot_hit_indicator_segment("bottom_right"),
		_shotshell_crosshair_segment("shotshell_left", math.rad(180)+TEXTURE_ROTATION),
		_shotshell_crosshair_segment("shotshell_right", math.rad(0)+TEXTURE_ROTATION),
		_deviation_crosshair_segment("deviation_top", math.rad(90)),
		_deviation_crosshair_segment("deviation_bottom", math.rad(270)),
		_deviation_crosshair_segment("deviation_left", math.rad(180)),
		_deviation_crosshair_segment("deviation_right", math.rad(0)),
	}, scenegraph_id)
end

template.on_enter = function (widget, template, data)
	return
end

template.update_function = function (parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local shotshell_yaw, shotshell_pitch = mod.shotshell_spread_yaw_pitch()
	local deviation_yaw, deviation_pitch = parent:_spread_yaw_pitch(dt, not mod.shotshell_spread_crosshair_center, false)

	if shotshell_yaw and shotshell_pitch then
		local spread_offset_y = shotshell_pitch * SPREAD_DISTANCE
		local spread_offset_x = shotshell_yaw * SPREAD_DISTANCE

        local styles = {style.shotshell_left, style.shotshell_right}
        for _,v in ipairs(styles) do
            v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, SHOTSHELL_HALF_SIZE_Y, SHOTSHELL_MIN_OFFSET, TEXTURE_ROTATION)
        end
	end

	if deviation_yaw and shotshell_pitch then
		local spread_offset_y = deviation_pitch * SPREAD_DISTANCE
		local spread_offset_x = deviation_yaw * SPREAD_DISTANCE
		
		local styles = {style.deviation_top, style.deviation_bottom, style.deviation_left, style.deviation_right}
		for _,v in ipairs(styles) do
            v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, DEVIATION_HALF_SIZE_X, DEVIATION_MIN_OFFSET)
        end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end

return template
