local ECS = require 'libs.ecs'
local ENUMS = require "world.enums.enums"

local TARGET_DIR = vmath.vector3()
local TARGET_V = vmath.vector3()

local V_FORWARD = vmath.vector3(0, 0, -1)

local QUAT_TEMP = vmath.quat_rotation_z(0)

local VMATH_DOT = vmath.dot
local VMATH_LENGTH = vmath.length
local MATH_ABS = math.abs
local PHYSICS_WAKEUP = physics.wakeup

---@class PlayerMoveSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player")
System.name = "PlayerMoveSystem"

function System:update()
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		local movement = e.movement

		movement.direction.x = 0
		movement.direction.y = 0
		movement.direction.z = 0

		if movement.input.x ~= 0 or movement.input.z ~= 0 then
			movement.direction.x = movement.input.x
			movement.direction.z = movement.input.z
			xmath.normalize(movement.direction, movement.direction)
		end

		if (e.die) then
			movement.direction.x = 0
			movement.direction.z = 0
		end
		if self.world.game_world.game.state.in_battle then
			movement.direction.x = 0
			movement.direction.z = 0
		end

		--if e.camera.look_at_enemy then
		--	xmath.quat_rotation_y(QUAT_TEMP, e.angle)
		--else
		xmath.quat_rotation_y(QUAT_TEMP, e.camera.yaw)
		--end

		xmath.rotate(movement.direction, QUAT_TEMP, movement.direction)

		if movement.type == ENUMS.PLAYER_MOVEMENT.FIXED_CAMERA then
			if (movement.direction.x ~= 0 or movement.direction.z ~= 0) then
				e.look_dir.x = movement.direction.x
				e.look_dir.z = movement.direction.z
			end
		else
			if e.target then
				e.look_dir.x = -e.target.distance_to_player_vec_normalized.x
				e.look_dir.z = -e.target.distance_to_player_vec_normalized.z
			else
				xmath.rotate(e.look_dir, QUAT_TEMP, V_FORWARD)
			end
			e.look_dir.y = 0
		end

		--region GROUND MOVEMENT
		local max_speed = movement.input.z ~= 0 and movement.max_speed or movement.max_speed * movement.strafe_power
		max_speed = max_speed * movement.max_speed_limit

		xmath.mul(TARGET_V, movement.direction, max_speed)

		local is_accel = VMATH_DOT(TARGET_V, movement.velocity) > 0

		local accel = is_accel and movement.accel or movement.deaccel
		local force_last_time = 1000
		if e.force_last_time then
			force_last_time = self.world.game_world.game.state.time - e.force_last_time
		end
		if force_last_time < 0.33 then
			accel = 0
		elseif force_last_time < 0.66 then
			accel = accel * 0.1
		end

		if (movement.input.x == 0 and movement.input.z == 0 and force_last_time > 0.5) then
			xmath.lerp(movement.velocity, movement.deaccel_stop, e.physics_linear_velocity, TARGET_V)
			--	movement.velocity.y = 0
		else
			xmath.lerp(movement.velocity, accel, e.physics_linear_velocity, TARGET_V)
		end

		if (VMATH_LENGTH(movement.velocity) < 0.001) then
			movement.velocity.x = 0
			--movement.velocity.y = 0
			movement.velocity.z = 0
		end

		--e.physics_linear_velocity.y = movement.velocity.y
		e.physics_linear_velocity.x = movement.velocity.x
		e.physics_linear_velocity.z = movement.velocity.z
		--endregion

		e.moving = (MATH_ABS(movement.velocity.x) > 0 or MATH_ABS(movement.velocity.z) > 0)
				and (MATH_ABS(movement.direction.x) > 0 or MATH_ABS(movement.direction.z) > 0)

		--if (e.moving) then PHYSICS_WAKEUP(e.player_go.collision) end
		PHYSICS_WAKEUP(e.player_go.collision)
	end

end

return System