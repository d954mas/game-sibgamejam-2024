local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"
local StoragePart = require "world.storage.storage_part_base"

---@class TimersStoragePart:StoragePartBase
local Storage = COMMON.class("TimersStoragePart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.timers = self.storage.data.timers
end

function Storage:reset(id, type)
	assert(id)
	type = type or ENUMS.TIMER_TYPE.GAME
	local start_time = self:get_time(type)
	self.timers[id] = { type = type, start_time = start_time }
	self:save_and_changed()
end

function Storage:get_time(type)
	if (type == ENUMS.TIMER_TYPE.GAME) then
		return self.timers.game_time
	elseif type == ENUMS.TIMER_TYPE.REAL then
		return socket.gettime()
	else
		error("unknown type:" .. tostring(type))
	end
end

function Storage:get_diff(id)
	local timer = self.timers[id]
	if not timer then return math.huge end

	return self:get_time(timer.type) - timer.start_time
end

function Storage:update(dt)
	self.timers.game_time = self.timers.game_time + dt
end

return Storage