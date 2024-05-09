local ECS = require 'libs.ecs'
local ENUMS = require "world.enums.enums"

---@class FailSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player|enemy")
System.name = "FailSystem"

function System:init()
	self.interval = 4 / 60
end

function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if not e.die and e.position.y < -6 then
			self.world.game_world.game:die(e)
		end
	end
end

return System