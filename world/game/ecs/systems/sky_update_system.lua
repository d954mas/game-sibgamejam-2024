local ECS = require 'libs.ecs'

---@class SkyUpdateSystem:ECSSystem
local System = ECS.system()
System.name = "SkyUpdateSystem"

function System:init()
	self.url = msg.url("game_scene:/env_sky")
end

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	go.set_position(player.camera.position, self.url)
end

return System