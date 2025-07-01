local mod = get_mod("crosshairs_fix")
local Fov = require("scripts/utilities/camera/fov")
local Crosshair = require("scripts/ui/utilities/crosshair")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local template = {
	name = "shotshell",
}
local SPREAD_DISTANCE = 10

local function _crosshair_segment(style_id, angle)
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
				8,
				4,
			},
			color = Color.terminal_text_header(mod.shotshell_spread_alpha, true),
		},
	})
end

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
		_crosshair_segment("top", math.rad(90)),
		_crosshair_segment("bottom", math.rad(270)),
		_crosshair_segment("left", math.rad(0)),
		_crosshair_segment("right", math.rad(180)),
		_shotshell_crosshair_segment("shotshell_top", math.rad(0)),
		_shotshell_crosshair_segment("shotshell_bottom", math.rad(180)),
		_shotshell_crosshair_segment("shotshell_left", math.rad(90)),
		_shotshell_crosshair_segment("shotshell_right", math.rad(-90)),
	}, scenegraph_id)
end

template.on_enter = function (widget, template, data)
	return
end

template.update_function = function (parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = mod._spread_yaw_pitch_no_fov(parent, dt)
	local shotshell = mod.get_active_shotshell()

	-- if yaw and pitch then
	-- 	local scalar = SPREAD_DISTANCE * (crosshair_settings.spread_scalar or 1)
	-- 	local spread_offset_y = pitch * scalar
	-- 	local spread_offset_x = yaw * scalar
	-- 	local styles = {style.top_left, style.top_right, style.bottom_right, style.bottom_left}
	-- 	for _,v in pairs(styles) do
	-- 		local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
	-- 		v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, half_size_x, half_size_x+half_size_y)
	-- 	end
	-- end

	-- if shotshell then
	-- 	local shotshell_pitch, shotshell_yaw = shotshell.spread_pitch, shotshell.spread_yaw
	-- 	if not shotshell.no_random_roll then
	-- 		shotshell_pitch, shotshell_yaw = shotshell_pitch * math.sqrt(0.75), shotshell_yaw * math.sqrt(0.75)
	-- 	end
	-- 	shotshell_pitch, shotshell_yaw = Fov.apply_fov_to_crosshair(shotshell_pitch, shotshell_yaw)
	-- 	local scalar = SPREAD_DISTANCE * (1 + (shotshell.scatter_range or 0.1))
	-- 	local spread_offset_y = shotshell_pitch * scalar
	-- 	local spread_offset_x = shotshell_yaw * scalar
	-- 	local styles = {style.top, style.bottom, style.left, style.right}
	-- 	for _,v in pairs(styles) do
	-- 		local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
	-- 		v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, 0, half_size_x, math.rad(90))
	-- 	end
	-- end

	if yaw and pitch and shotshell then
		local scalar = SPREAD_DISTANCE * (crosshair_settings.spread_scalar or 1)
		local scatter_range = (1 + (shotshell.scatter_range or 0.1))
		local shotshell_pitch, shotshell_yaw = shotshell.spread_pitch * scatter_range, shotshell.spread_yaw * scatter_range
		if not shotshell.no_random_roll then
			shotshell_pitch, shotshell_yaw = shotshell_pitch * math.sqrt(0.75), shotshell_yaw * math.sqrt(0.75)
		end
		pitch, yaw = Fov.apply_fov_to_crosshair(pitch+shotshell_pitch, yaw+shotshell_yaw)
		shotshell_pitch, shotshell_yaw = Fov.apply_fov_to_crosshair(shotshell_pitch, shotshell_yaw)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = yaw * scalar
		local shotshell_offset_y = shotshell_pitch * SPREAD_DISTANCE
		local shotshell_offset_x = shotshell_yaw * SPREAD_DISTANCE
		local spread_styles = {style.top, style.bottom, style.left, style.right}
		local shotshell_styles = {style.shotshell_top, style.shotshell_bottom, style.shotshell_left, style.shotshell_right}
		for _,v in pairs(spread_styles) do
			local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
			v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, half_size_x, half_size_x+half_size_y)
		end
		for _,v in pairs(shotshell_styles) do
			local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
			v.offset[1], v.offset[2] = mod.crosshair_rotation(shotshell_offset_x, shotshell_offset_y, v.angle, 0, half_size_x, math.rad(90))
		end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end

return template