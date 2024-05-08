local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"

local StoragePart = require "world.storage.storage_part_base"

---@class ResourcePartOptions:StoragePartBase
local Storage = COMMON.class("ResourcePartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.resources = self.storage.data.resources
end

function Storage:add(resource, value, placement)
	assert(DEFS.RESOURCES[resource])
	assert(value >= 0)
	placement = placement or ENUMS.RESOURCE_ADD_PLACEMENT.OTHER
	if (value == 0) then return end
	self.resources[resource].value = self.resources[resource].value + value
	COMMON.EVENTS.RESOURCE_ADD:trigger(resource, value, placement)

	self:changed()
	--ignore too often saves
	if placement == ENUMS.RESOURCE_ADD_PLACEMENT.PUNCH_BAG then return end
	self:save()
end

function Storage:spend(resource, value)
	assert(DEFS.RESOURCES[resource])
	assert(value >= 0)
	assert(self:can_spend(resource, value))
	if (value == 0) then return end

	self.resources[resource].value = self.resources[resource].value - value
	COMMON.EVENTS.RESOURCE_SPEND:trigger(resource, value)
	self:save_and_changed()
end

function Storage:can_spend(resource, value)
	assert(DEFS.RESOURCES[resource])
	assert(value >= 0)
	return self.resources[resource].value >= value
end

function Storage:get(resource)
	return self.resources[resource].value
end

function Storage:clear(resource)
	local value = self.resources[resource].value
	if value > 0 then
		self:spend(resource, value)
	end
end

return Storage