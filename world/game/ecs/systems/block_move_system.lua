local COMMON = require "libs.common"
local ECS = require 'libs.ecs'
local TWEEN = require 'libs.tween'
local ENUMS = require "world.enums.enums"

local TARGET_DIR = vmath.vector3()
local TARGET_V = vmath.vector3()
local TEMP_V = vmath.vector3()

local CURRENT_VELOCITY_DIR = vmath.vector3()

local V_FORWARD = vmath.vector3(0, 0, -1)
local V_UP = vmath.vector3(0, 1, 0)
local Q_ROTATION_NORMAL = vmath.quat_rotation_z(0)

local IMPULSE_V = vmath.vector3(0, 0, 0)

local QUAT_TEMP = vmath.quat_rotation_z(0)

---@class BlockMoveSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("move_block")
System.name = "BlockMoveSystem"

---@param e EntityGame
function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		-- Determine the next target position on the path
		local next_target = e.path_movement.targets[e.path_movement.cell_idx]
		local current_position = e.position

		-- Calculate the direction vector from the current position to the target
		local need_movement = next_target - current_position

		-- Determine if the block has reached the vicinity of the target
		if vmath.length(need_movement) < 0.05 then
			if not e.path_movement.pause then
				print("PAUSE")
				e.path_movement.pause = true
				e.path_movement.pause_time = e.move_block.path[e.path_movement.cell_idx].pause or 0
			end
		end

		if e.path_movement.pause then
			e.path_movement.pause_time = e.path_movement.pause_time - dt
			if e.path_movement.pause_time <= 0 then
				e.path_movement.cell_idx = e.path_movement.cell_idx + e.path_movement.direction
				-- Move to the next target in the path
				if e.path_movement.cell_idx > #e.path_movement.targets then
					e.path_movement.direction = -1
					e.path_movement.cell_idx = #e.path_movement.targets - 1
				end
				if e.path_movement.cell_idx <= 0 then
					e.path_movement.direction = 1
					e.path_movement.cell_idx = 2
				end
				e.path_movement.pause = false
				e.path_movement.pause_time = 0
			end
		end

		TARGET_DIR.x, TARGET_DIR.y, TARGET_DIR.z = need_movement.x, need_movement.y, need_movement.z
		local max_speed = e.move_block.speed
		if (vmath.length(TARGET_DIR) > 0) then
			xmath.normalize(TARGET_DIR, TARGET_DIR)
		end

		local vel = TARGET_DIR * max_speed
		if vmath.length(vel*dt) > vmath.length(need_movement) then
			vel = vel * vmath.length(need_movement) / vmath.length(vel*dt)
		end

		e.physics_linear_velocity.x = vel.x
		e.physics_linear_velocity.y = vel.y + 10*dt
		e.physics_linear_velocity.z = vel.z
		physics.wakeup(e.cell_go.collision)

		local player = self.world.game_world.game.level_creator.player
		if player.on_ground and not player.moving then
			local dpos = player.position - e.position
			dpos.y = 0
			if vmath.length(dpos) < 1.75 then
				player.physics_linear_velocity.x = player.physics_linear_velocity.x + e.physics_linear_velocity.x
				--player.physics_linear_velocity.y =  player.physics_linear_velocity.y + e.physics_linear_velocity.y
				player.physics_linear_velocity.z = player.physics_linear_velocity.z + e.physics_linear_velocity.z
			end
		end
	end
end

return System