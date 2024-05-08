local HASHES = require "libs.hashes"
local CLASS = require "libs.middleclass"
local LOG = require "libs.log"

local M = CLASS.class("InputReceiver")
M.HASH_NIL = hash("nil") --used for mouse movement

M.PRESSED_KEYS = {}
M.TOUCH = {}
M.MOUSE_POS = nil
M.TOUCH_MULTI = {}

M.IGNORE = false

M.INPUT_LISTENERS = {}
local function ensure_hash(string_or_hash)
	return type(string_or_hash) == "string" and hash(string_or_hash) or string_or_hash
end

function M:initialize()
	self.action_funs = {}
end

function M:add_mouse(fun)
	assert(fun, "function can't be null")
	local action_id = M.HASH_NIL
	assert(not self.action_funs[action_id], action_id .. " already used")
	self.action_funs[action_id] = { fun = fun, other = true }
end

function M:add(action_id, fun, is_pressed, is_repeated, is_released, other)
	assert(action_id, "action_id can't be null")
	assert(fun, "function can't be null")
	action_id = ensure_hash(action_id)
	assert(not self.action_funs[action_id], action_id .. " already used")
	self.action_funs[action_id] = { fun = fun, other = other, is_pressed = is_pressed,
									is_repeated = is_repeated, is_released = is_released }
end

function M:on_input(go_self, action_id, action)
	action_id = action_id or M.HASH_NIL
	local fun = self.action_funs[action_id]
	if fun then
		if (fun.other or (fun.is_pressed and action.pressed)
				or (fun.is_repeated and action.repeated) or (fun.is_released and action.released)) then
			return fun.fun(go_self, action_id, action)
		end
	end
	return false
end

function M.clear()
	M.PRESSED_KEYS = {}
end

function M.handle_pressed_keys(action_id, action)
	if (action_id == nil) then
		M.MOUSE_POS = action
	elseif (action_id == HASHES.INPUT.TOUCH) then
		M.TOUCH[1] = action
		if (action.released) then
			M.TOUCH[1] = nil
		end
	elseif (action_id == HASHES.INPUT.TOUCH_MULTI and action.touch) then
		for i, touchdata in ipairs(action.touch) do
			M.TOUCH_MULTI[i] = touchdata
			if (touchdata.released) then
				M.TOUCH_MULTI[i] = nil
			end
		end
		for i = #M.TOUCH_MULTI, #action.touch + 1, -1 do
			M.TOUCH_MULTI[i] = nil
		end
	end

	if action.pressed then
		M.PRESSED_KEYS[action_id] = true
	elseif action.released then
		M.PRESSED_KEYS[action_id] = false
	end
end

function M.release(instance)
	instance = assert(instance)
	for i = 1, #M.INPUT_LISTENERS do
		local listener = M.INPUT_LISTENERS[i]
		if listener.instance == instance then
			table.remove(M.INPUT_LISTENERS, i)
			return
		end
	end
end

function M.acquire(instance, priority, scene)
	instance = assert(instance)
	priority = priority or 1
	assert(instance.on_input)
	local inserted = false
	local object = { instance = instance, priority = priority, script_instance = lua_script_instance.Get(), scene = scene }
	for i = 1, #M.INPUT_LISTENERS do
		local listener = M.INPUT_LISTENERS[i]
		if listener.instance == instance then error("listener already registered") end
		if not inserted and listener.priority <= object.priority then
			inserted = true
			table.insert(M.INPUT_LISTENERS, i, object)
		end
	end
	if not inserted then
		table.insert(M.INPUT_LISTENERS, object)
	end
end

function M.global_on_input(action_id, action)
	if M.IGNORE then return end
	local listeners = M.INPUT_LISTENERS
	local current_script_instance = lua_script_instance.Get()
	for i = 1, #listeners do
		local listener = listeners[i]
		local handle_input = true
		if listener.scene then
			handle_input = listener.scene.handle_input
		end
		if handle_input then
			if listener.script_instance ~= current_script_instance then
				lua_script_instance.Set(listener.script_instance)
			end

			local ok, error = pcall(listener.instance.on_input, listener.instance, action_id, action)
			if not ok then LOG.e(error) end
			if ok and error then return end

			if listener.script_instance ~= current_script_instance then
				lua_script_instance.Set(current_script_instance)
			end
		end
	end
end

return M
