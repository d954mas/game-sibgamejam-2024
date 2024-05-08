local COMMON = require "libs.common"

local StoragePart = require "world.storage.storage_part_base"

---@class WorldsStoragePart:StoragePartBase
local Storage = COMMON.class("WorldsStoragePart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.worlds = self.storage.data.worlds
end

function Storage:world_get_state(world_id)
	return self.worlds[world_id].state
end

return Storage