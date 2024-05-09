local ECS = require 'libs.ecs'

---@class PlayerAutojumpSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player")
System.name = "PlayerAutojumpSystem"

---@param e EntityGame
function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if not e.on_ground then
			self.world.game_world.game:player_jump()
		end
	end
end

return System