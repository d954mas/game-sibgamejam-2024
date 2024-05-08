local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local CHEKCKBOX_CHECKED_NORMAL = hash("checkbox_checked_normal")
local CHEKCKBOX_NORMAL = hash("checkbox_normal")

local CHECKBOX_REFRESH = function(checkbox)
	gui.play_flipbook(checkbox.node, checkbox.checked and CHEKCKBOX_CHECKED_NORMAL or CHEKCKBOX_NORMAL)
end

---@class Checkbox
local Btn = COMMON.class("ButtonScale")

function Btn:initialize(root_name, path)
	self.root_name = root_name .. (path or "/root")
	self.vh = {
		root = gui.get_node(self.root_name),
		box = gui.get_node(self.root_name .. "/box"),
	}
	self.checked = false
	self.gooey_listener = function(cb)
		self.checked = cb.checked
		if self.input_listener then self.input_listener() end
	end
	self.checkbox = GOOEY.checkbox(self.root_name .. "/box", self.gooey_listener, CHECKBOX_REFRESH)
end

function Btn:set_input_listener(listener)
	self.input_listener = listener
end

function Btn:set_checked(checked)
	self.checked = checked
	self.checkbox:set_checked(checked)
end

function Btn:on_input(action_id, action)
	if (not self.ignore_input) then
		return self.checkbox:on_input(action_id, action)
	end
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end

function Btn:set_ignore_input(ignore)
	self.ignore_input = ignore
end

return Btn