local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"

local StoragePart = require "world.storage.storage_part_base"

---@class TutorialPart:StoragePartBase
local Storage = COMMON.class("TutorialPart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.tutorial = self.storage.data.tutorial
end

function Storage:is_completed(id)
	return self.tutorial[id].completed
end

function Storage:complete(id)
	if not self:is_completed(id) then
		ANALYTICS_HELPER.tutorial_completed(id)
		self.tutorial[id].completed = true
		self:save_and_changed()
	end
end

return Storage