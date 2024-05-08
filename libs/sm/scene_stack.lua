local CLASS = require "libs.middleclass"
local CHECKS = require "libs.checks"

---@class SceneStack
local M = CLASS.class("SceneStack")

function M:initialize()
	self.stack = {}
end

---Pushes a value at the head of the heap
---@param value Scene
function M:push(value)
	CHECKS("?", "class:Scene")
	table.insert(self.stack, value)
end

---Remove and return the value at the head of the heap
---@return Scene
function M:pop() return table.remove(self.stack) end

---Looks at the object of this stack without removing it from the stack.
---@return Scene
function M:peek(value)
	return self.stack[#self.stack - (value or 0)]
end

function M:find_scene(scene)
	for id = #self.stack,1,-1 do
		local value = self.stack[id]
		if value == scene then
			return #self.stack - id + 1
		end
	end
end

return M
