local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"
local DEFS = require "world.balance.def.defs"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"
local StoragePart = require "world.storage.storage_part_base"

---@class PowerupsStoragePart:StoragePartBase
local Storage = COMMON.class("PowerupsStoragePart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.powerups = self.storage.data.powerups
end

function Storage:start(id, free)
	assert(id)
	local powerup = self.powerups[id]
	if powerup.state == ENUMS.POWERUP_STATE.ACTIVE then return end
	ANALYTICS_HELPER.powerup_activate(id, not free)
	powerup.state = ENUMS.POWERUP_STATE.ACTIVE
	powerup.active_time = 0
	if free then
		powerup.cooldown_start_time = socket.gettime()
	end
	powerup.cooldown_spend_time = socket.gettime() - powerup.cooldown_start_time

	self:save_and_changed()
end

function Storage:update(dt)
	for _, powerup_def in pairs(DEFS.POWERUPS) do
		local powerup = self.powerups[powerup_def.id]
		if powerup.state == ENUMS.POWERUP_STATE.ACTIVE then
			powerup.active_time = powerup.active_time + dt
			if powerup.active_time >= powerup_def.duration then
				powerup.state = ENUMS.POWERUP_STATE.IDLE
				powerup.active_time = 0
				powerup.cooldown_start_time = socket.gettime() - powerup.cooldown_spend_time
				powerup.cooldown_spend_time = 0
				self:save_and_changed()
			end
		end
	end
end

function Storage:get_state(id)
	return self.powerups[id].state
end

function Storage:get_active_countdown(id)
	if self.powerups[id].state == ENUMS.POWERUP_STATE.ACTIVE then
		return DEFS.POWERUPS[id].duration - self.powerups[id].active_time
	else
		return 0
	end
end

function Storage:get_cooldown_countdown(id)
	if self.powerups[id].state == ENUMS.POWERUP_STATE.IDLE then
		local cooldown = DEFS.POWERUPS[id].cooldown
		local time = socket.gettime() - self.powerups[id].cooldown_start_time
		return cooldown - time
	else
		return 0
	end
end

return Storage