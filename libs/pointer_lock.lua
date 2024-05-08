local COMMON = require "libs.common"

local M = {}

M.DISPLAY_WIDTH = tonumber(sys.get_config("display.width"))
M.DISPLAY_HEIGHT = tonumber(sys.get_config("display.height"))

M.need_locked = false
M.locked = false

M.cursor_x = M.DISPLAY_WIDTH / 2
M.cursor_y = M.DISPLAY_HEIGHT / 2



--[[
local HASH_TOUCH = hash("touch")
function M.transform_input(action_id, action)
	if (action_id == nil or action_id == HASH_TOUCH) then
		if (M.locked) then
			action.x = M.cursor_x
			action.y = M.cursor_y
		end
	end

	return action_id, action
end
--]]

function M.unlock_cursor()
	if not COMMON.CONSTANTS.TARGET_IS_EDITOR then return end
	if (COMMON.is_mobile()) then return end
	M.need_locked = false
	window.set_mouse_lock(false)
	M.locked = false
end

function M.lock_cursor()
	if not COMMON.CONSTANTS.TARGET_IS_EDITOR then return end
	if (COMMON.is_mobile()) then return end
	M.need_locked = true
	if not html5 then
		window.set_mouse_lock(true)
		M.locked = true
	end
end

function M.init()
	if (COMMON.is_mobile()) then return end
	--[[if (html5) then
		html5.set_interaction_listener(function()
			if (M.need_locked and not M.locked) then
				window.set_mouse_lock(true)
			end
		end)
	end--]]
end

function M.update()
	if (not COMMON.CONSTANTS.TARGET_IS_EDITOR or COMMON.is_mobile()) then
		M.locked = false
	else
		M.locked = window.get_mouse_lock()
	end
end

return M