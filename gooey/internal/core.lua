local HASHES = require "libs.hashes"

local M = {}

local long_press_start = 0

local function handle_action(component, action_id, action)
	action.id = action.id or -1
	component.long_pressed_time = component.long_pressed_time or 1.5
	if not component.touch_id or component.touch_id == action.id then
		local over = gui.pick_node(component.node, action.x, action.y)
		component.over_now = over and not component.over
		component.out_now = not over and component.over
		component.over = over

		local touch = action_id == HASHES.INPUT.TOUCH or action_id == HASHES.INPUT.TOUCH_MULTI
		local pressed = touch and action.pressed and component.over
		local released = touch and action.released
		if pressed then
			component.touch_id = action.id
			long_press_start = socket.gettime()
		elseif released then
			component.touch_id = nil
			component.long_pressed = socket.gettime() - long_press_start > component.long_pressed_time
		end

		component.pressed_now = pressed and not component.pressed
		component.released_now = released and component.pressed
		component.pressed = pressed or (component.pressed and not released)
		component.consumed = component.pressed or (component.released_now and component.over)
		component.clicked = component.released_now and component.over
		component.long_pressed = component.long_pressed or false
	end
end

--- Basic input handling for anything that is clickable
-- @param component Component state table
-- @param action_id
-- @param action
function M.clickable(component, action_id, action)
	if not component.enabled or not action then
		component.pressed_now = false
		component.released_now = false
		component.consumed = false
		component.clicked = false
		component.pressed = false
		return
	end

	if not action.touch then
		handle_action(component, action_id, action)
	else
		for _, touch_action in pairs(action.touch) do
			handle_action(component, action_id, touch_action)
		end
	end
end

function M.to_hash(str)
	return type(str) == "string" and hash(str) or str
end

---Create one if it doesn't
function M.instance(functions)
	local instance = { }
	if functions then
		for name, fn in pairs(functions) do
			instance[name] = fn
		end
	end
	return instance
end

return M