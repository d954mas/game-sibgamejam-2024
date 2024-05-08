local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class DebugStoragePart:StoragePartBase
local Debug = COMMON.class("DebugStoragePart", StoragePart)

function Debug:initialize(...)
	StoragePart.initialize(self, ...)
	self.debug = self.storage.data.debug
end

function Debug:draw_debug_info_is() return self.debug.draw_debug_info end
function Debug:draw_debug_info_set(enable)
	if (self.debug.draw_debug_info ~= enable) then
		self.debug.draw_debug_info = enable
		self:save_and_changed()
	end
end

function Debug:draw_physics_is() return self.debug.draw_physics end
function Debug:draw_physics_set(enable)
	if (self.debug.draw_physics ~= enable) then
		self.debug.draw_physics = enable
		self:save_and_changed()
	end
end

return Debug