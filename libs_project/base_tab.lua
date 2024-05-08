local COMMON = require "libs.common"

---@class GameTabBase
local Tab = COMMON.class("GameTabBase")

function Tab:bind_vh()
	self.vh = {}
	self.views = {}
end

function Tab:init_gui()

end

function Tab:set_enabled(enabled)
	assert(type(enabled) == "boolean")
	self.enabled = enabled
	gui.set_enabled(self.root_node, self.enabled)
end

function Tab:set_ignore_input(ignore_input)
	self.ignore_input = assert(type(ignore_input) == "boolean")
end

function Tab:initialize(root_name)
	self.root_name = assert(root_name)
	self.root_node = gui.get_node(root_name .. "/root")
	self.enabled = false
	self.ignore_input = false

	self:bind_vh()

	self:init_gui()
	self:on_storage_changed()

	gui.set_enabled(self.root_node, false)
end

function Tab:update(dt) end

function Tab:on_storage_changed() end
function Tab:on_resize() end

function Tab:final()

end

function Tab:on_input(action_id, action)
	if (self.ignore_input) then return false end
end

return Tab