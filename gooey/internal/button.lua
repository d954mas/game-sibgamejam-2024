local core = require "gooey.internal.core"

local M = {}

-- instance functions
local BUTTON = {}
function BUTTON.refresh(button)
	if button.refresh_fn then button.refresh_fn(button) end
end
function BUTTON.set_visible(button, visible)
	gui.set_enabled(button.node, visible)
end
function BUTTON.set_long_pressed_time(button, time)
	button.long_pressed_time = time
end

function BUTTON:on_input(action_id, action)
	self.enabled = gui.is_enabled(self.node, true)
	core.clickable(self, action_id, action)
	if self.clicked then
		self:fn()
	end

	self:refresh()
	return self.consumed
end

function M.new_button(node_id, fn, refresh_fn)
	node_id = core.to_hash(node_id)

	local button = core.instance(BUTTON)
	button.node = gui.get_node(node_id)
	button.enabled = gui.is_enabled(button.node, true)
	button.node_id = node_id
	button.refresh_fn = refresh_fn
	button.fn = fn

	return button
end

return M