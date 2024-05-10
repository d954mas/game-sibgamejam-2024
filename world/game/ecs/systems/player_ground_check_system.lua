local ECS = require 'libs.ecs'

local TEMP_V = vmath.vector3()
local RAYCAST_FROM = vmath.vector3()
local RAYCAST_V = vmath.vector3(0, -0.075, 0)
local RAYCAST_START_DY = 0.5

local DIR_UP = vmath.vector3(0, 1, 0)

local points = {
	vmath.vector3(0, 0, 0),
	vmath.vector3(0.2, 0, 0),
	vmath.vector3(-0.2, 0, 0),
	vmath.vector3(0, 0, 0.2),
	vmath.vector3(0, 0, -0.2),
}

---@class PlayerGroundCheckSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player")
System.name = "PlayerGroundCheckSystem"

function System:init()
	self.ground_raycast_groups = {
		hash("obstacle"),
		hash("geometry")
	}
	self.ground_raycast_mask = game.physics_count_mask(self.ground_raycast_groups)
end

---@param e EntityGame
function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		--add RAYCAST_START_DY to avoid raycast from edge of earth
		RAYCAST_FROM.x, RAYCAST_FROM.y, RAYCAST_FROM.z = e.position.x, e.position.y + RAYCAST_START_DY, e.position.z
		TEMP_V.x, TEMP_V.y, TEMP_V.z = e.position.x, e.position.y + RAYCAST_V.y, e.position.z

		local exist, x, y, z, nx, ny, nz
		for idx, point in ipairs(points) do
			RAYCAST_FROM.x, RAYCAST_FROM.z = e.position.x + point.x, e.position.z + point.z
			TEMP_V.x, TEMP_V.z = RAYCAST_FROM.x, RAYCAST_FROM.z

			exist, x, y, z, nx, ny, nz = game.physics_raycast_single(RAYCAST_FROM, TEMP_V, self.ground_raycast_mask)

			if (exist) then
				if (idx ~= 1) then
					nx, ny, nz = DIR_UP.x, DIR_UP.y, DIR_UP.z
				end
				break
			end
		end


		--[[(not results)then
			TEMP_V.z = TEMP_V.z -0.001
			results = physics.raycast(e.position, TEMP_V, self.ground_raycast_groups, CLOSEST)
		end
		if(not results)then
			TEMP_V.z = TEMP_V.z +0.001
			results = physics.raycast(e.position, TEMP_V, self.ground_raycast_groups, CLOSEST)
		end--]]
		--pprint(results)

		if exist then
			if (not e.on_ground) then
				--	self.world.game_world.sounds:jump_land()
			end
			--	for _, result in ipairs(results) do
			e.on_ground_time = self.world.game_world.game.state.time
			e.on_ground = true
			e.ground_normal.x, e.ground_normal.y, e.ground_normal.z = nx, ny, nz
			--	end
		else
			e.on_ground = false
			e.ground_normal.x, e.ground_normal.y, e.ground_normal.z = DIR_UP.x, DIR_UP.y, DIR_UP.z

			if (self.world.game_world.game.state.time - e.physics_reset_y_velocity > 0.1 and not e.in_jump) then
				--e.in_jump = true--only onced reset it
				e.physics_reset_y_velocity = self.world.game_world.game.state.time
				--reset y velocity
				local vel = e.physics_linear_velocity
				if (vel.y > 10) then
					vel.y = vel.y * 0.5
				elseif (vel.y > 3) then
					vel.y = vel.y * 0.75
				end
			end

		end
	end

end

return System