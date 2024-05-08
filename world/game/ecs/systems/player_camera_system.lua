local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"

local SmoothDumpV3 = require "libs.smooth_dump_v3"
local SmoothDump = require "libs.smooth_dump"

local TEMP_DMOVE = vmath.vector3(0)
local TEMP_Q_YAW_REVERSE = vmath.quat_rotation_z(0)
local TEMP_Q = vmath.quat_rotation_z(0)

local V_TARGET = vmath.vector3(0)

---@class PlayerCameraSystem:ECSSystem
local System = ECS.system()
System.name = "PlayerCameraSystem"

function System:init()
	self.smooth_dump = SmoothDumpV3(0.1, nil, 0.5)
	self.smooth_dump_yaw = SmoothDump(0.1)
end

function System:onAddToWorld()
	for i = 1, 5 do
		self:update(1)
	end
end

---@return EntityGame|nil
function System:find_target()
	local current_target = self.world.game_world.game.level_creator.player.target
	local target = current_target
	if target and target.die then target = nil end

	local distance = math.huge
	if target then
		distance = target.distance_to_player - 1
	end
	for _, enemy in ipairs(self.world.game_world.game.level_creator.entities.enemies) do
		if enemy.distance_to_player < distance and not enemy.die then
			target = enemy
			distance = enemy.distance_to_player
		end
	end
	return target
end

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player

	local camera = player.camera
	local config = COMMON.RENDER.screen_size.aspect >= 1 and camera.config or camera.config_portrait

	local yaw_rad = player.angle
	local pitch_rad = config.pitch.value

	if player.movement.type == ENUMS.PLAYER_MOVEMENT.FIXED_CAMERA then
		yaw_rad = config.yaw.value
	elseif player.movement.type == ENUMS.PLAYER_MOVEMENT.BATTLE then
		local target = self:find_target()
		if not target then
			yaw_rad = player.camera.yaw
		else
			yaw_rad = player.camera.yaw
			local look_vector = target.position - camera.position
			xmath.normalize(look_vector, look_vector)
			local new_yaw_rad = -math.atan2(look_vector.x, -look_vector.z)

			yaw_rad = self.smooth_dump_yaw:updateAngle(yaw_rad, new_yaw_rad, dt)
		end
		player.target = target
	end

	player.camera.pitch = pitch_rad
	player.camera.yaw = yaw_rad

	xmath.quat_rotation_y(TEMP_Q_YAW_REVERSE, yaw_rad)

	xmath.rotate(TEMP_DMOVE, TEMP_Q_YAW_REVERSE, config.position)

	--ORIENTATION
	xmath.quat_rotation_x(TEMP_Q, pitch_rad)
	xmath.quat_mul(player.camera.rotation, TEMP_Q_YAW_REVERSE, TEMP_Q)

	xmath.add(V_TARGET, player.position, TEMP_DMOVE)

	if self.world.game_world.game.state.in_battle then
		if COMMON.RENDER.screen_size.aspect < 1 then
			V_TARGET.x = V_TARGET.x
			V_TARGET.y = V_TARGET.y
		else
			V_TARGET.x = V_TARGET.x - 1.25
			V_TARGET.y = V_TARGET.y + 0.4
		end

	end

	self.smooth_dump:update(player.camera.position, V_TARGET, dt)

	player.camera.position.y = math.max(player.camera.position.y, config.position.y)

	local fov = config.fov
	--if (COMMON.RENDER.screen_size.aspect < 1) then
	--	fov = 2 * math.atan(math.tan(config.fov / 2) * 1 / COMMON.RENDER.screen_size.aspect)
	--end

	game.camera_set_fov(fov)
	game.camera_set_view_position(player.camera.position)
	game.camera_set_view_rotation(player.camera.rotation)

	xmath.quat_to_euler(player.camera.rotation_euler, player.camera.rotation)

end

return System