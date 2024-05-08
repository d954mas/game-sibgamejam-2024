local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"

---@class AutosizeLbl
local Lbl = COMMON.class("AutosizeLbl")

function Lbl:initialize(node)
	self.node = type(node) == "string" and gui.get_node(node) or node
	self.scale = gui.get_scale(self.node)
end

function Lbl:set_text(text)
	--if self.text ~= text then
		GUI.autosize_text(self.node, self.scale, text)
	--end
end


return Lbl