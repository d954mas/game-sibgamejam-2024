local ECS = require 'libs.ecs'


---@class PhysicsUpdateLinearVelocity:ECSSystem
local System = ECS.system()
System.name = "PhysicsUpdateLinearVelocity"

function System:update(dt)
	game.physics_objects_update_linear_velocity()
end

return System