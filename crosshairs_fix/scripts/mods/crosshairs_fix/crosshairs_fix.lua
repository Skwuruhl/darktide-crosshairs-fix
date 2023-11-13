local mod = get_mod("crosshairs_fix")
local assault = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_assault")
local bfg = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_bfg")
local cross = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_cross")
local projectile_drop = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_projectile_drop")
local shotgun_slug = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_shotgun_slug")
local shotgun_wide = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_shotgun_wide")
local shotgun = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_shotgun")
local spray_n_pray = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_spray_n_pray")

mod:hook(CLASS.HudElementCrosshair, "_spread_yaw_pitch", function(func, self)
	local yaw, pitch = func(self)
	local local_player = Managers.player:local_player(1)
	if yaw and pitch and local_player then
		local current_fov = Managers.state.camera:fov(local_player.viewport_name) or 1
		yaw = 540 * math.tan(math.rad(yaw))/math.tan(current_fov/2)
		pitch = 540 * math.tan(math.rad(pitch))/math.tan(current_fov/2)
	end
	return yaw, pitch
end)

mod:hook(assault, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_style = widget.style.up
		local left_style = widget.style.bottom_left
		local right_style = widget.style.bottom_right
		local styles = {up_style, left_style, right_style}
		for i=1,3 do
			styles[i].angle = math.rad(-120 + 120*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle+math.pi/2) * (styles[i].size[2]/2 + yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle+math.pi/2) * (styles[i].size[2]/2 + pitch)
		end
	end
end)

mod:hook(bfg, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_style = widget.style.up
		local down_style = widget.style.down
		local left_style = widget.style.left
		local right_style = widget.style.right
		local styles = {right_style, up_style, left_style, down_style}
		for i=1,4 do
			styles[i].angle = math.rad(-90 + 90*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle) * (styles[i].size[1]/2 + yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle) * (styles[i].size[1]/2 + pitch)
		end
	end
end)

mod:hook(cross, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_style = widget.style.up
		local down_style = widget.style.down
		local left_style = widget.style.left
		local right_style = widget.style.right
		local styles = {right_style, up_style, left_style, down_style}
		for i=1,4 do
			styles[i].angle = math.rad(-90 + 90*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle) * (styles[i].size[1]/2 + yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle) * (styles[i].size[1]/2 + pitch)
		end
	end
end)

mod:hook(projectile_drop, "update_function" , function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local left_style = widget.style.left
		local right_style = widget.style.right
		local styles = {right_style, left_style}
		for i=1,2 do
			styles[i].angle = math.rad(-180 + 180*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle) * (styles[i].size[1]/2 + yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle) * (styles[i].size[1]/2 + pitch)
		end
	end
end)

mod:hook(shotgun_slug, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_style = widget.style.up
		local down_style = widget.style.down
		local left_style = widget.style.left
		local right_style = widget.style.right
		local styles = {right_style, up_style, left_style, down_style}
		for i=1,4 do
			styles[i].angle = math.rad(-90 + 90*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle) * (styles[i].size[1]/2 + yaw/3)
			styles[i].offset[2] = -math.sin(styles[i].angle) * (styles[i].size[1]/2 + pitch/3)
		end
	end
end)

mod:hook(shotgun_wide, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_left_style = widget.style.up_left
		local up_right_style = widget.style.up_right
		local bottom_left_style = widget.style.bottom_left
		local bottom_right_style = widget.style.bottom_right
		local styles = {up_right_style, up_left_style, bottom_left_style, bottom_right_style}
		for i=1,4 do
			styles[i].angle = math.rad(-90 + 90*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle+math.pi/4) * (yaw*6.5/2.5)
			styles[i].offset[2] = -math.sin(styles[i].angle+math.pi/4) * (pitch/6.5*2.5)
		end
	end
end)

mod:hook(shotgun, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local up_left_style = widget.style.up_left
		local up_right_style = widget.style.up_right
		local bottom_left_style = widget.style.bottom_left
		local bottom_right_style = widget.style.bottom_right
		local styles = {up_right_style, up_left_style, bottom_left_style, bottom_right_style}
		for i=1,4 do
			styles[i].angle = math.rad(-90 + 90*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle+math.pi/4) * (yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle+math.pi/4) * (pitch)
		end
	end
end)

mod:hook(spray_n_pray, "update_function", function(func, parent, ui_renderer, widget, template, dt, t)
	func(parent, ui_renderer, widget, template, dt, t)
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	if yaw and pitch then
		local left_style = widget.style.left
		local right_style = widget.style.right
		local styles = {right_style, left_style}
		for i=1,2 do
			styles[i].angle = math.rad(-180 + 180*i)
			styles[i].horizontal_alignment = "center"
			styles[i].vertical_alignment = "center"
			styles[i].offset[1] = math.cos(styles[i].angle) * (styles[i].size[1]/4 + yaw)
			styles[i].offset[2] = -math.sin(styles[i].angle) * (styles[i].size[1]/4 + pitch)
		end
	end
end)