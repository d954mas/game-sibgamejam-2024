local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"

local StoragePart = require "world.storage.storage_part_base"

---@class GamePartOptions:StoragePartBase
local Storage = COMMON.class("GamePartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.game = self.storage.data.game
end

function Storage:debug_add_money()
	local value = math.max(10000, self.world.game:offer_get_value(DEFS.RESOURCES.GOLD.id) * 5)
	self.storage.resources:add(DEFS.RESOURCES.GOLD.id, value, ENUMS.RESOURCE_ADD_PLACEMENT.DEBUG)
end


return Storage