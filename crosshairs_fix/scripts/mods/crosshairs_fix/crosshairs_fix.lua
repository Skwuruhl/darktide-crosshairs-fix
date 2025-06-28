local mod = get_mod("crosshairs_fix")
local fov = require("scripts/utilities/camera/fov")
local assault = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_assault")
local Crosshair = require("scripts/ui/utilities/crosshair")
local function _spread_settings(weapon_extension, movement_state_component)
	local spread_template = weapon_extension:spread_template()

	if not spread_template then
		return nil
	end

	local weapon_movement_state = WeaponMovementState.translate_movement_state_component(movement_state_component)
	local spread_settings = spread_template[weapon_movement_state]

	return spread_settings
end

--supplied with spread_offset_x and spread_offset_y and the angle of a crosshair segment, returns x and y coordinates adjusted for the rotation.
--minimum_offset is the mininum number of 1080 pixels the returned x, y should be from center. e.g. a value of 1 at an angle of 45° would set a minumum x and y value of 0.707. optional
--texture_rotation is an optional parameter in case the crosshair texture needs additional rotation. e.g. If you add 90 deg to _crosshair_segment() to rotate the texture, then pass 90 deg to texture rotation so it undoes the rotation for the purposes of crosshair placement
--As usual for lua all angles should be supplied in radians.
--0° is left and then rotates clockwise. Based on vanilla crosshair segment values.
mod.crosshair_rotation = function(x, y, angle, half_crosshair_size, minimum_offset, texture_rotation)
	minimum_offset = minimum_offset or 0
	texture_rotation = texture_rotation or 0
	x = -math.cos(angle - texture_rotation) * math.max(x + half_crosshair_size, minimum_offset)
	y = math.sin(angle - texture_rotation) * math.max(y + half_crosshair_size, minimum_offset)
	return x, y
end

mod:hook_origin("HudElementCrosshair", "_spread_yaw_pitch", function (self)
	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		local unit_data_extension = player_extensions.unit_data
		local buff_extension = player_extensions.buff
		local yaw, pitch

		if unit_data_extension then
			local spread_component = unit_data_extension:read_component("spread")
			local suppression_component = unit_data_extension:read_component("suppression")

			yaw = spread_component.yaw
			pitch = spread_component.pitch

			if buff_extension then
				local stat_buffs = buff_extension:stat_buffs()
				local modifier = stat_buffs.spread_modifier or 1

				yaw = yaw * modifier
				pitch = pitch * modifier
			end

			pitch, yaw = Suppression.apply_suppression_offsets_to_spread(suppression_component, pitch, yaw)
			local weapon_extension = player_extensions.weapon
			local movement_state_component = unit_data_extension:read_component("movement_state")
			local shooting_status_component = unit_data_extension:read_component("shooting_status")
			local spread_settings = _spread_settings(weapon_extension, movement_state_component)
			if spread_settings then
				local randomized_spread = spread_settings.randomized_spread or {}
				local min_spread_ratio = randomized_spread.min_ratio or 0.25
				local random_spread_ratio = randomized_spread.random_ratio or 0.75
				local first_shot = shooting_status_component.num_shots == 0
				if first_shot then
					min_spread_ratio = randomized_spread.first_shot_min_ratio or 0.25
					random_spread_ratio = randomized_spread.first_shot_random_ratio or 0.4
				end
				local multiplier = min_spread_ratio + random_spread_ratio
				pitch = pitch * multiplier
				yaw = yaw * multiplier
			end
			pitch, yaw = Fov.apply_fov_to_crosshair(pitch, yaw)
		end

		return yaw, pitch
	end
end)

mod:hook_safe("ActionHandler", "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, t, transition_type, condition_func_params, automatic_input, reset_combo_override)
	local handler_data = self._registered_components[id]
	local component = handler_data.component
	local weapon_template = WeaponTemplate.current_weapon_template(component)
	if weapon_template then
		local actions = weapon_template.actions
		local fire_configuration
		for k,v in pairs(action_settings.allowed_chain_actions) do
			if string.find(k,"shoot") then
				fire_configuration = actions[v.action_name].fire_configuration
				break
			end
		end
		if not fire_configuration then
			local fallback_action = actions.action_shoot_hip
			if fallback_action then
				fire_configuration = fallback_action.fire_configuration
			end
		end
		if fire_configuration then
			mod.shotshell = fire_configuration.shotshell
			mod.shotshell_special = fire_configuration.shotshell_special
			local inventory_component = self._inventory_component
			local wielded_slot = inventory_component.wielded_slot
			if PlayerUnitVisualLoadout.is_slot_of_type(wielded_slot, "weapon") then
				mod.inventory_slot_component = self._unit_data_extension:read_component(wielded_slot)
			end
		else
			mod.shotshell = nil
			mod.shotshell_special = nil
			mod.inventory_slot_component = nil
		end
	end
end)

--most templates multiply pitch and yaw by 10, and apply_fov_to_crosshair by 37. The result is 370 but needs to be 540, the number of pixels from center of crosshair to top of screen with a 1080p monitor.
mod:hook(fov, "apply_fov_to_crosshair", function(func, pitch, yaw)
	pitch, yaw = func(pitch, yaw)
	local correction = 54/37
	pitch = pitch and pitch * correction
	yaw = yaw and yaw * correction

	return pitch, yaw
end)

--assault is the only template that has a multiplier of 15 instead of 10.
--I tried to fix this without hook_origin but I couldn't get it to work. Only thing this hook changes is SPREAD_DISTANCE 15 to 10
mod:hook_origin(assault, "update_function", function(parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)
	local SPREAD_DISTANCE = 10

	if yaw and pitch then
		local scalar = SPREAD_DISTANCE * (crosshair_settings.spread_scalar or 1)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = yaw * scalar

		local top_style = style.top
		local top_size = top_style.size[1]

		top_style.offset[1] = 0
		top_style.offset[2] = math.min(-spread_offset_y - top_size/2, -top_size/2-2)

		local bottom_style = style.bottom
		local bottom_size = bottom_style.size[1]

		bottom_style.offset[1] = 0
		bottom_style.offset[2] = math.max(spread_offset_y + bottom_size/2, bottom_size/2+2)

		local left_style = style.left
		local left_size = left_style.size[1]

		left_style.offset[1] = math.min(-spread_offset_x - left_size/2, -left_size/2-2)
		left_style.offset[2] = 0

		local right_style = style.right
		local right_size = right_style.size[1]

		right_style.offset[1] = math.max(spread_offset_x + right_size/2, right_size/2+2)
		right_style.offset[2] = 0
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end)