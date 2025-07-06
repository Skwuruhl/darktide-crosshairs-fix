local mod = get_mod("crosshairs_fix")
local Fov = require("scripts/utilities/camera/fov")
local Crosshair = require("scripts/ui/utilities/crosshair")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local template = {
	name = "shotshell_no_spread",
}
local SPREAD_DISTANCE = 10
local TEXTURE_ROTATION = math.rad(-90)

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
				24,
				8,
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
		_shotshell_crosshair_segment("shotshell_right", math.rad(0)+TEXTURE_ROTATION),
		_shotshell_crosshair_segment("shotshell_top", math.rad(90)+TEXTURE_ROTATION),
		_shotshell_crosshair_segment("shotshell_left", math.rad(180)+TEXTURE_ROTATION),
		_shotshell_crosshair_segment("shotshell_bottom", math.rad(270)+TEXTURE_ROTATION),
	}, scenegraph_id)
end

template.on_enter = function (widget, template, data)
	return
end

template.update_function = function (parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt, false)
	local shotshell_yaw, shotshell_pitch = mod.shotshell_spread_yaw_pitch(false)

	if yaw and pitch and shotshell_yaw and shotshell_pitch then
		shotshell_pitch, shotshell_yaw = Fov.apply_fov_to_crosshair(pitch+shotshell_pitch, yaw+shotshell_yaw) -- add spread yaw and pitch bc no other spread indicators
		local shotshell_offset_y = shotshell_pitch * SPREAD_DISTANCE
        local shotshell_offset_x = shotshell_yaw * SPREAD_DISTANCE
		local shotshell_styles = {style.shotshell_right, style.shotshell_top, style.shotshell_left, style.shotshell_bottom}
		for _,v in ipairs(shotshell_styles) do
			local half_size_x, quarter_size_y = v.size[1]/2, v.size[2]/4
			v.offset[1], v.offset[2] = mod.crosshair_rotation(shotshell_offset_x, shotshell_offset_y, v.angle, quarter_size_y, quarter_size_y+half_size_x, TEXTURE_ROTATION)
		end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end

return template