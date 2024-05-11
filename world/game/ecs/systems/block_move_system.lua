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
		if vmath.length(need_movement) < 0.1 then
			-- Move to the next target in the path
			e.path_movement.cell_idx = e.path_movement.cell_idx + 1
			if e.path_movement.cell_idx > #e.path_movement.targets then
				e.path_movement.cell_idx = 1 -- Loop back to the first target
			end
		end

		TARGET_DIR.x, TARGET_DIR.y, TARGET_DIR.z = need_movement.x, need_movement.y, need_movement.z
		local max_speed = e.move_block.speed
		if (vmath.length(TARGET_DIR) > 0) then
			xmath.normalize(TARGET_DIR, TARGET_DIR)
		end

		local vel = TARGET_DIR, max_speed
		if vmath.length(vel) > vmath.length(need_movement) then
			vel = vel * vmath.length(need_movement) / vmath.length(vel)
		end

		xmath.mul(e.physics_linear_velocity, TARGET_DIR, max_speed)
		physics.wakeup(e.cell_go.collision)
	end
end

return System