local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local CHEKCKBOX_CHECKED = COMMON.LUME.color_parse_hexRGBA("#48CC09")
local CHEKCKBOX_UNCHECKED = COMMON.LUME.color_parse_hexRGBA("#022345")
local TUMBLER_POS_CHECKED = vmath.vector3(16, 0, 0)
local TUMBLER_POS_UNCHECKED = vmath.vector3(-16, 0, 0)

---@class Tumbler:Checkbox
local Btn = COMMON.class("Tumbler")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
		bg = gui.get_node(root_name .. "/bg"),
		pie = gui.get_node(root_name .. "/pie")
	}
	self.root_name = root_name .. (path or "/root")
	self.checked = false
	self.gooey_listener = function(cb)
		self.checked = cb.checked
		if self.input_listener then self.input_listener() end
	end
	self.refresh_checkbox = function(checkbox)
		if checkbox.checked then
			gui.set_color(self.vh.bg, CHEKCKBOX_CHECKED)
			gui.set_position(self.vh.pie, TUMBLER_POS_CHECKED)
		else
			gui.set_color(self.vh.bg, CHEKCKBOX_UNCHECKED)
			gui.set_position(self.vh.pie, TUMBLER_POS_UNCHECKED)
		end

		gui.set_scale(self.vh.bg, checkbox.pressed and self.scale_pressed or self.scale)
	end

	self.scale = gui.get_scale(self.vh.bg)
	self.scale_pressed = self.scale * 0.9

	self.checkbox = GOOEY.checkbox(self.root_name, self.gooey_listener, self.refresh_checkbox)
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