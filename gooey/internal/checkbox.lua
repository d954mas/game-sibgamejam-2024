local core = require "gooey.internal.core"

local M = {}

local checkboxes = {}

-- instance functions
local CHECKBOX = {}
function CHECKBOX.set_checked(checkbox, checked)
	if checked then
		checkbox.checked_now = true
	end
	checkbox.checked = checked
	if checkbox.refresh_fn then checkbox.refresh_fn(checkbox) end
end
function CHECKBOX.set_visible(checkbox, visible)
	gui.set_enabled(checkbox.node, visible)
end
function CHECKBOX.refresh(checkbox)
	if checkbox.refresh_fn then checkbox.refresh_fn(checkbox) end
end
function CHECKBOX.set_long_pressed_time(checkbox, time)
	checkbox.long_pressed_time = time
end
function CHECKBOX.on_input(checkbox, action_id, action)
	checkbox.enabled = gui.is_enabled(checkbox.node, true)
	core.clickable(checkbox, action_id, action)
	checkbox.checked_now = checkbox.clicked and not checkbox.checked or false
	checkbox.unchecked_now = checkbox.clicked and checkbox.checked or false
	if checkbox.clicked then
		checkbox.checked = not checkbox.checked
		checkbox.fn(checkbox)
	end

	checkbox:refresh()
end

function M.checkbox_new(node_id, fn, refresh_fn)
	node_id = core.to_hash(node_id)

	local checkbox = core.instance(CHECKBOX)
	checkbox.node = gui.get_node(node_id)
	checkbox.enabled = gui.is_enabled(checkbox.node, true)

	checkbox.node_id = node_id
	checkbox.refresh_fn = refresh_fn
	checkbox.fn = fn

	return checkbox
end


return M