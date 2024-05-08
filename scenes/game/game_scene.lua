local COMMON = require "libs.common"
local BaseScene = require "libs.sm.scene"

---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
	BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
end

function Scene:pause_done()
	if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME_GUI)then
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		ctx.data.views.virtual_pad:reset()
		ctx:remove()
	end
end

return Scene