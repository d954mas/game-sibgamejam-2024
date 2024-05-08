local CLASS = require "libs.middleclass"
local LOG = require "libs.log"
local TAG = "ContextManager"

local TABLE_REMOVE = table.remove
local TABLE_INSERT = table.insert

---@class ContextData
---@field context userdata
---@field data table
---@field name string

---@class ContextStackData
---@field context userdata
---@field id number


local CONTEXT_DATA_WRAPPER_POOL = {}
local CONTEXT_IDS_POOL = {}

---@class ContextStackWrapper
local ContextDataWrapper = CLASS.class("ContextDataWrapper")

---@param id number
---@param data ContextStackData
---@param manager ContextManager
function ContextDataWrapper:initialize(id, ctx, manager)
	self.id = assert(id)
	self.ctx = assert(ctx)
	self.data = self.ctx.data
	self.manager = assert(manager)
	self.removed = false
end

function ContextDataWrapper:remove()
	if not self.removed then
		self.manager:remove_context_top(self.id)
	end
	self.removed = true
	TABLE_INSERT(CONTEXT_DATA_WRAPPER_POOL, self)
end

local function getContextDataWrapper(id, ctx, manager)
	local wrapper = TABLE_REMOVE(CONTEXT_DATA_WRAPPER_POOL)
	if wrapper then
		wrapper.id = assert(id)
		wrapper.ctx = assert(ctx)
		wrapper.data = ctx.data
		wrapper.removed = false
		return wrapper
	else
		return ContextDataWrapper(id, ctx, manager)
	end
end

local function getContextIdTable(id,context)
	local result = TABLE_REMOVE(CONTEXT_IDS_POOL)
	if not result then
		result = {}
	end

	result.id = id
	result.context = context
	return result
end

---@class ContextManager
local Manager = CLASS.class("ContextManager")

function Manager:initialize()
	---@type ContextData[]
	self.context_map = {}
	---@type ContextStackData[]
	self.contexts_stack = {}
	self.id = 0
end

function Manager:register(name, data)
	assert(name)
	assert(not self.context_map[name], "context:" .. tostring(name) .. " already registered")
	self.context_map[name] = {
		context = lua_script_instance.Get(),
		data = data,
		name = name,
	}
	LOG.i("Context register:" .. name, TAG)
end

function Manager:unregister(name)
	assert(name)
	local ctx = self:get(name)
	assert(ctx.context == lua_script_instance.Get(), "can't unregister.Different context instances")
	for i = #self.contexts_stack, 1, -1 do
		if self.contexts_stack[i].context == ctx.context then
			table.insert(CONTEXT_IDS_POOL, table.remove(self.contexts_stack, i))
		end
	end
	self.context_map[name] = nil
	LOG.i("Context unregister:" .. name, TAG)
end

function Manager:exist(name)
	return self.context_map[name] ~= nil
end

---@return ContextData
function Manager:get(name)
	return assert(self.context_map[name], "no context with name:" .. name)
end

---@return ContextStackWrapper
function Manager:set_context_top_by_name(name)
	assert(name)
	--LOG.i("set_context:" .. name,TAG,2)
	local ctx = self:get(name)
	local id = self:set_context_top_by_instance(ctx.context)
	return getContextDataWrapper(id, ctx, self)
end

function Manager:set_context_top_by_instance(new)
	--assert(new)
	--assert(type(new) == "userdata")
	local current = lua_script_instance.Get()
	self.id = self.id + 1
	table.insert(self.contexts_stack, getContextIdTable(self.id, current))
	if new ~= current then
		lua_script_instance.Set(new)
	end
	return self.id
end

function Manager:remove_context_top(id)
	assert(id)
	local remove = false
	for i = #self.contexts_stack, 1, -1 do
		local value = self.contexts_stack[i]
		if value.id == id then
			for idx = i, #self.contexts_stack do
				table.insert(CONTEXT_IDS_POOL, self.contexts_stack[idx])
				self.contexts_stack[idx] = nil
			end
			if value.context ~= lua_script_instance.Get() then
				lua_script_instance.Set(value.context)
			end
			remove = true
		end
	end
	if not remove then
		LOG.w("no context for id:" .. id, TAG)
	end
end

return Manager