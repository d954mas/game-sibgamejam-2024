local COMMON = require "libs.common"
local CHECKS = require "libs.checks"
local StoragePart = require "world.storage.storage_part_base"

---@class StoragePartOptions:StoragePartBase
local Options = COMMON.class("StorageOptions", StoragePart)

function Options:initialize(...)
	StoragePart.initialize(self, ...)
	self.options = self.storage.data.options
end

function Options:sound_set(enable)
	CHECKS("?", "boolean")
	self.options.sound = enable
	self:save_and_changed()
end

function Options:sound_get() return self.options.sound end

function Options:music_set(enable)
	CHECKS("?", "boolean")
	self.options.music = enable
	self:save_and_changed()
end
function Options:music_get() return self.options.music end

function Options:draw_shadows_set(enable)
	CHECKS("?", "boolean")
	self.options.draw_shadows = enable
	self:save_and_changed()
end
function Options:draw_shadows_get() return self.options.draw_shadows end

function Options:language_set(language)
	self.options.language = assert(language)
	COMMON.LOCALIZATION:set_locale(language)
	self:save_and_changed()
end

function Options:language_get()
	return self.options.language
end

return Options