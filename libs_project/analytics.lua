local COMMON = require "libs.common"
local CHECKS = require "libs.checks"

local Analytics = COMMON.class("Analytics")

---@param world GameWorld
function Analytics:initialize(world,config)
	CHECKS("?","?", "table")
	self.world = assert(world)
	self.initialized = true
	self.config = config
	self.disabled = false
	if (COMMON.CONSTANTS.PLATFORM_IS_WINDOWS) then
		--self.disabled = true
	end
	if(gameanalytics)then
		gameanalytics.setEnabledInfoLog(COMMON.CONSTANTS.VERSION_IS_DEV)
		gameanalytics.setCustomDimension01(COMMON.CONSTANTS.GAME_TARGET)
	else
		self.disabled = true
	end
end

function Analytics:error(message)
	if (self.initialized and not self.disabled) then
		gameanalytics.addErrorEvent { severity = "Error", message = message }
	end
end

function Analytics:eventCustom(id, value)
	if (self.initialized and not self.disabled) then
		gameanalytics.addDesignEvent { eventId = id, value = value }
	end
end

return Analytics
