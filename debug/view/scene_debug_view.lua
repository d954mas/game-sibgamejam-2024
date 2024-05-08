local COMMON = require "libs.common"
local WORLD = require "world.world"

---@class SceneDebugView
local View = COMMON.class("SceneDebugView")

function View:initialize(root_name)
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		lbl_scene = gui.get_node(root_name .. "/lbl_scene"),
		lbl_scene_stack = gui.get_node(root_name .. "/lbl_scene_stack"),
	}
end

function View:set_enabled(enabled)
	gui.set_enabled(self.vh.root, enabled)
end

function View:get_scene_string()
	local s = ""
	for _, scene in pairs(WORLD.sm.scenes) do
		s = s .. "[" .. (scene._config.modal and "M]" or "S]")
		s = s .. " " .. scene._name .. " " .. scene._state .. "\n"
	end
	return s
end

function View:get_scene_stack_string()
	local s = ""
	local len = #WORLD.sm.stack.stack
	for i = 1, len, 1 do
		local scene = WORLD.sm.stack.stack[len - i + 1]
		s = s .. "[" .. (scene._config.modal and "M]" or "S]")
		s = s .. " " .. scene._name .. " " .. scene._state .. "\n"
	end
	return s
end

function View:update(dt)
	if gui.is_enabled(self.vh.root) then
		gui.set_text(self.vh.lbl_scene, "Scene:\n" .. self:get_scene_string())
		gui.set_text(self.vh.lbl_scene_stack, "Stack:\n" .. self:get_scene_stack_string())
	end
end

return View