local checkbox = require "gooey.internal.checkbox"
local button = require "gooey.internal.button"
local list = require "gooey.internal.list"

local M = {}

-- no-operation
-- empty function to use when no component callback function was provided
local function nop() end


function M.button(node_id, fn, refresh_fn)
	return button.new_button(node_id, fn or nop, refresh_fn)
end

function M.checkbox(node_id, fn, refresh_fn)
	return checkbox.checkbox_new(node_id, fn or nop, refresh_fn)
end

function M.dynamic_list(list_id, stencil_id, item_id, data, action_id, action, config, fn, refresh_fn)
	return list.dynamic(list_id, stencil_id, item_id, data, action_id, action, config, fn, refresh_fn)
end


return M