local COMMON = require "libs.common"
local SM_ENUMS = require "libs.sm.enums"

local BaseScene = require "libs.sm.scene"
---@class QuestScene:Scene
local Scene = BaseScene:subclass("QuestScene")
function Scene:initialize()
	BaseScene.initialize(self, "QuestScene", "/quest_scene#collectionproxy")
	self._config.modal = true
end

function Scene:transition(transition)
	if (transition == SM_ENUMS.TRANSITIONS.ON_HIDE or
			transition == SM_ENUMS.TRANSITIONS.ON_BACK_HIDE) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.QUEST_GUI)
		ctx.data:animate_hide()
		ctx:remove()

		COMMON.coroutine_wait(0.2)
	elseif (transition == SM_ENUMS.TRANSITIONS.ON_SHOW) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.QUEST_GUI)
		ctx.data:animate_show()
		ctx:remove()
		COMMON.coroutine_wait(0.15)
	end
end

return Scene