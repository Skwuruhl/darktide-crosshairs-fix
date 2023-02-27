local mod = get_mod("crosshairs_fix")

mod:hook(CLASS.HudElementCrosshair, "_spread_yaw_pitch", function(func, self)
	local yaw, pitch = func(self)
	local local_player = Managers.player:local_player(1)
	if yaw and pitch and local_player then
		local current_fov = Managers.state.camera:fov(local_player.viewport_name) or 1
		yaw = 54 * math.tan(math.rad(yaw))/math.tan(current_fov/2)
		pitch = 54 * math.tan(math.rad(pitch))/math.tan(current_fov/2)
	end
	return yaw, pitch
end)
