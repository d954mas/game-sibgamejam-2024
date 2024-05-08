local COMMON = require "libs.common"
local TEXT_SETTING = require "libs.text_settings"
local RICHTEXT = require "richtext.richtext"
local checks  = require "libs.checks"

---@class RichtextLbl
local Lbl = COMMON.class("RichtextLbl")

function Lbl:initialize()
	self.nodes = nil
	self.text_metrics = nil
	self.text = nil
	self.center_v = false
	self.root_node = gui.new_box_node(vmath.vector3(0), vmath.vector3(1))
	gui.set_texture(self.root_node, "gui")
	gui.play_flipbook(self.root_node, "empty")
	gui.set_visible(self.root_node, false)
	self:set_text_setting(TEXT_SETTING.BASE_CENTER)
	self:set_font("Base")
	self.position = vmath.vector3(0, 0, 0)
end

function Lbl:set_position(position)
	self.position = position
end

function Lbl:set_max_width(width)
	self.text_setting.width = width
end

function Lbl:refresh()
	local text = self.text
	self.text = nil
	self:set_text(text)
end

function Lbl:set_parent(parent)
	gui.set_parent(self.root_node, assert(parent))
end

function Lbl:set_font(font)
	checks("?", "string")
	self.font = font
end

function Lbl:set_text_setting(config)
	checks("?", "table")
	self.text_setting = TEXT_SETTING.make_copy(config, { parent = self.root_node })
end

function Lbl:set_text(text)
	checks("?", "string|number")
	text = tostring(text)
	if (self.text == text) then
		return
	end
	self.text = text
	if (self.nodes) then
		for _, node in ipairs(self.nodes) do
			gui.delete_node(node.node)
		end
	end
	-- RICHTEXT.DEFAULT_ALIGN = gui.PIVOT_W
	self.nodes, self.text_metrics = RICHTEXT.create(self.text, self.font, self.text_setting)
	--  RICHTEXT.DEFAULT_ALIGN = nil

	if (self.center_v) then
		gui.set_position(self.root_node, vmath.vector3(self.position.x, self.position.y + self.text_metrics.height/2 *gui.get_scale(self.root_node).y, 0))
	else
		gui.set_position(self.root_node, self.position)
	end
end

return Lbl