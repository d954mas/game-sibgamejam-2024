local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local StoragePart = require "world.storage.storage_part_base"

---@class LevelsStoragePart:StoragePartBase
local Storage = COMMON.class("LevelsStoragePart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.levels = self.storage.data.levels
end

function Storage:level_data_get(id)
	local data = self.levels[id]
	return data or { completed = false, stars = 0, play_time = 0 }
end

function Storage:level_completed(idx, stars, play_time)
	stars = stars or 0
	local data = self:level_data_get(idx)
	data.completed = true
	data.stars = math.max(data.stars, stars)
	data.play_time = math.min(data.play_time, play_time)
	self.levels[idx] = data
	self:save_and_changed()
end

function Storage:levels_get_last_opened()
	for _,level in ipairs(DEFS.LEVELS.LEVELS_LIST)do
		if not self:level_data_get(level).completed then
			return level
		end
	end
	return DEFS.LEVELS.LEVELS_LIST[#DEFS.LEVELS.LEVELS_LIST]
end

return Storage