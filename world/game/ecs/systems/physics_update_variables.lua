local ECS = require 'libs.ecs'

---@class PhysicsUpdateVariables:ECSSystem
local System = ECS.system()
System.name = "PhysicsUpdateVariables"

function System:update()
	game.physics_objects_update_variables()
end

return System