local mod = get_mod("crosshairs_fix")
local Fov = require("scripts/utilities/camera/fov")
local Crosshair = require("scripts/ui/utilities/crosshair")
local UIWidget = require("scripts/managers/ui/ui_widget")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")
local Suppression = require("scripts/utilities/attack/suppression")
local WeaponMovementState = require("scripts/extension_systems/weapon/utilities/weapon_movement_state")
local assault = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_assault")
local flamer = require("scripts/ui/hud/elements/crosshair/templates/crosshair_template_flamer")

local function _spread_settings(weapon_extension, movement_state_component, locomotion_component, inair_state_component)
	local spread_template = weapon_extension:spread_template()

	if not spread_template then
		return nil
	end

	local weapon_movement_state = WeaponMovementState.translate_movement_state_component(movement_state_component, locomotion_component, inair_state_component)
	local spread_settings = spread_template[weapon_movement_state]

	return spread_settings
end

local template_paths = {
	"crosshairs_fix/scripts/mods/crosshairs_fix/crosshair_template_shotshell",
	"crosshairs_fix/scripts/mods/crosshairs_fix/crosshair_template_shotshell_wide",
	"crosshairs_fix/scripts/mods/crosshairs_fix/crosshair_template_shotshell_no_spread",
	"crosshairs_fix/scripts/mods/crosshairs_fix/crosshair_template_shotshell_wide_no_spread",
}

mod.shotshell_spread_crosshair_center = mod:get("shotshell_spread_crosshair_center")
mod.shotshell_spread_crosshair_disable = mod:get("shotshell_spread_crosshair_disable")
mod.shotshells = {}

mod.on_setting_changed = function()
	mod.shotshell_spread_crosshair_center = mod:get("shotshell_spread_crosshair_center")
	mod.shotshell_spread_crosshair_disable = mod:get("shotshell_spread_crosshair_disable")
end

--supplied with spread_offset_x and spread_offset_y and the angle of a crosshair segment, returns x and y coordinates adjusted for the rotation.
--minimum_offset is the mininum number of 1080 pixels the returned x, y should be from center. e.g. a value of 1 at an angle of 45° would set a minumum x and y value of 0.707. optional. Don't forget to include half crosshair here as well.
--texture_rotation is an optional parameter in case the crosshair texture needs additional rotation. e.g. If you add 90 deg to _crosshair_segment() to rotate the texture, then pass 90 deg to texture rotation so it undoes the rotation for the purposes of crosshair placement
--As usual for lua all angles should be supplied in radians.
--angle is per a unit circle. i.e. 0° is the right side and rotation is counter clockwise. Vanilla style names might be misnamed but the angle is the important bit so it works fine.
mod.crosshair_rotation = function(x, y, angle, half_crosshair_size, minimum_offset, texture_rotation)
	minimum_offset = minimum_offset or 0
	texture_rotation = texture_rotation or 0
	x = math.cos(angle - texture_rotation) * math.max(x + half_crosshair_size, minimum_offset)
	y = -math.sin(angle - texture_rotation) * math.max(y + half_crosshair_size, minimum_offset)
	return x, y
end

mod.get_active_shotshell = function()
	if mod.inventory_slot_component and mod.inventory_slot_component.special_active then
		return mod.shotshells.shotshell_special
	else
		return mod.shotshells.shotshell
	end
end

mod.shotshell_spread_yaw_pitch = function(apply_fov)
	apply_fov = apply_fov == nil or apply_fov
	local shotshell = mod.get_active_shotshell()
	if shotshell then
		local yaw, pitch = shotshell.corrected_yaw, shotshell.corrected_pitch
		if apply_fov then
			pitch, yaw = Fov.apply_fov_to_crosshair(pitch, yaw)
		end
		return yaw, pitch
	end
end

-- I don't wanna run this every frame but I don't wanna delete it so I'm commenting instead
-- mod.get_active_shotshell = function(unit_data_extension)
-- 	if not unit_data_extension then
-- 		local player = Managers.player:local_player_safe(1)
-- 		if player then
-- 			unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
-- 		end
-- 	end
-- 	local weapon_action_component = unit_data_extension and unit_data_extension:read_component("weapon_action")
-- 	if weapon_action_component then
-- 		local weapon_template = WeaponTemplate.current_weapon_template(weapon_action_component)
-- 		if weapon_template then
-- 			local current_action_name, action_settings = Action.current_action(weapon_action_component, weapon_template)
-- 			mod:echo(current_action_name ~= "none" and action_settings.name or "no_action")
-- 			local fire_configuration
-- 			if current_action_name ~= "none" then
-- 				for k,v in pairs(action_settings.allowed_chain_actions) do
-- 					if string.find(k, "shoot") then
-- 						fire_configuration = weapon_template.actions[v.action_name].fire_configuration
-- 						break
-- 					end
-- 				end
-- 			end
-- 			if not fire_configuration then
-- 				local fallback_action = weapon_template.actions.action_shoot_hip
-- 				if fallback_action then
-- 					fire_configuration = fallback_action.fire_configuration
-- 				end
-- 			end
-- 			if fire_configuration then
-- 				local inventory_component = unit_data_extension:read_component("inventory")
-- 				local wielded_slot = inventory_component.wielded_slot
-- 				local slot_type = PlayerCharacterConstants.slot_configuration[wielded_slot].slot_type
-- 				if slot_type == "weapon" then
-- 					local inventory_slot_component = unit_data_extension:read_component(inventory_component.wielded_slot)
-- 					mod:echo(inventory_slot_component.special_active)
-- 					if inventory_slot_component.special_active then
-- 						return fire_configuration.shotshell_special
-- 					else
-- 						return fire_configuration.shotshell
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

mod:hook_safe("ActionHandler", "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, t, transition_type, condition_func_params, automatic_input, reset_combo_override)
	local handler_data = self._registered_components[id]
	local component = handler_data.component
	local weapon_template = WeaponTemplate.current_weapon_template(component)
	if weapon_template then
		local actions = weapon_template.actions
		local fire_configuration
		for k,v in pairs(action_settings.allowed_chain_actions or {}) do
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
			mod.shotshells.shotshell = fire_configuration.shotshell
			mod.shotshells.shotshell_special = fire_configuration.shotshell_special
			for _, shotshell in pairs(mod.shotshells) do
				local correction = (1 + (shotshell.scatter_range or 0.1))
				if not shotshell.no_random_roll then
					correction = correction * math.sqrt(0.75)
				end
				shotshell.corrected_yaw = shotshell.spread_yaw * correction
				shotshell.corrected_pitch = shotshell.spread_pitch * correction
			end
		else
			mod.shotshells.shotshell = nil
			mod.shotshells.shotshell_special = nil
		end
		local inventory_component = self._inventory_component
		local wielded_slot = inventory_component.wielded_slot
		if PlayerUnitVisualLoadout.is_slot_of_type(wielded_slot, "weapon") then
			mod.inventory_slot_component = self._unit_data_extension:read_component(wielded_slot)
		else
			mod.inventory_slot_component = nil
		end
	end
end)

mod:hook_origin("HudElementCrosshair", "_spread_yaw_pitch", function (self, _, apply_fov)
	apply_fov = apply_fov == nil or apply_fov
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
			local locomotion_component = unit_data_extension:read_component("locomotion")
			local inair_state_component = unit_data_extension:read_component("inair_state")
			local shooting_status_component = unit_data_extension:read_component("shooting_status")
			local spread_settings = (weapon_extension and movement_state_component and locomotion_component and inair_state_component) and _spread_settings(weapon_extension, movement_state_component, locomotion_component, inair_state_component)
			if spread_settings and shooting_status_component then
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
			local size_of_flame_template = weapon_extension and weapon_extension:size_of_flame_template()
			if size_of_flame_template then
				yaw = (size_of_flame_template.spread_angle or yaw)
				pitch = (size_of_flame_template.spread_angle or pitch)
			end
			if apply_fov then
				pitch, yaw = Fov.apply_fov_to_crosshair(pitch, yaw)
			end
		end

		return yaw, pitch
	end
end)

--most templates multiply pitch and yaw by 10, and apply_fov_to_crosshair by 37. The result is 370 but needs to be 540, the number of pixels from center of crosshair to top of screen with a 1080p monitor.
mod:hook(Fov, "apply_fov_to_crosshair", function(func, pitch, yaw)
	pitch, yaw = func(pitch, yaw)
	local correction = 54/37
	pitch = pitch and pitch * correction
	yaw = yaw and yaw * correction

	return pitch, yaw
end)

--assault is the only basic template that has a multiplier of 15 instead of 10.
--I tried to fix this without hook_origin but I couldn't get it to work. Only thing this hook changes is SPREAD_DISTANCE 15 to 10
mod:hook_origin(assault, "update_function", function(parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)

	if yaw and pitch then
		local scalar = 10 * (crosshair_settings.spread_scalar or 1)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = yaw * scalar
		local styles = {style.top, style.bottom, style.left, style.right}
		for _,v in ipairs(styles) do
			local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
			v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, half_size_x, half_size_x+half_size_y)
		end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end)

mod:hook_origin(flamer, "update_function", function(parent, ui_renderer, widget, template, crosshair_settings, dt, t, draw_hit_indicator)
	local style = widget.style
	local hit_progress, hit_color, hit_weakspot = parent:hit_indicator()
	local yaw, pitch = parent:_spread_yaw_pitch(dt)

	if yaw and pitch then
		local scalar = 10 * (crosshair_settings.spread_scalar or 1)
		local spread_offset_y = pitch * scalar
		local spread_offset_x = pitch * scalar
		local TEXTURE_ROTATION = math.rad(-90)
		local styles = {style.right, style.left}
		for _,v in ipairs(styles) do
			local half_size_x, half_size_y = v.size[1]/2, v.size[2]/2
			v.offset[1], v.offset[2] = mod.crosshair_rotation(spread_offset_x, spread_offset_y, v.angle, half_size_y, half_size_y+half_size_x, TEXTURE_ROTATION)
		end
	end

	Crosshair.update_hit_indicator(style, hit_progress, hit_color, hit_weakspot, draw_hit_indicator)
end)

mod:hook_safe("HudElementCrosshair", "init", function(self, parent, draw_layer, start_scale, definitions)
	local scenegraph_id = "pivot"
	for _, template_path in ipairs(template_paths) do
		local template = mod:io_dofile(template_path)
		local name = template.name
		self._crosshair_templates[name] = template
		self._crosshair_widget_definitions[name] = template.create_widget_defintion(template, scenegraph_id)
	end
end)

mod:hook("HudElementCrosshair", "_get_current_crosshair_type", function(func, self, crosshair_settings)
	local crosshair_type = func(self, crosshair_settings)
	if mod.get_active_shotshell() then
		if crosshair_type == "shotgun" then
			return mod.shotshell_spread_crosshair_disable and "shotshell_no_spread" or "shotshell"
		elseif crosshair_type == "shotgun_wide" then
			return mod.shotshell_spread_crosshair_disable and "shotshell_wide_no_spread" or "shotshell_wide"
		end
	end
	return crosshair_type
end)