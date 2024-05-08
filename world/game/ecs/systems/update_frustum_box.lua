local COMMON = require "libs.common"
local ECS = require 'libs.ecs'

---@class CheckFrustumBoxSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("frustum_native_dynamic")
System.name = "UpdateFrustumBoxSystem"

local TEMP_V = vmath.vector3()

function System:update(dt)
	game.frustum_set(COMMON.RENDER.camera_frustum_objects)

	for i = 1, #self.entities do
		local e = self.entities[i]
		xmath.add(TEMP_V, e.position, e.frustum_native_dynamic_delta_pos)
		e.frustum_native:SetPosition(TEMP_V)
	end

	game.frustum_objects_list_update(self.world.game_world.game.level_creator.player.position)
end

return System