local ECS = require 'libs.ecs'

---@class UpdateDistanceToPlayerSystem:ECSSystem
local System = ECS.system()
System.name = "UpdateDistanceToPlayerSystem"


function System:update()
	game.distance_objects_update(self.world.game_world.game.level_creator.player.position)
end

return System