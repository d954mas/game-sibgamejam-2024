local COMMON = require "libs.common"
local SequenceAction = require "libs.actions.sequence_action"

local TABLE_REMOVE = table.remove
local COROUTINE_YIELD = coroutine.yield

---@class ParallelAction:SequenceAction
local Action = COMMON.class("ParallelAction",SequenceAction)

Action.__can_add_action_while_run = true

function Action.array(array)
	local action = Action()
	for _,v in ipairs(array) do
		action:add_action(v)
	end
	return action
end

function Action:act(dt)
	local current
	while(self.childs[1] ~= nil or not self.drop_empty) do
		for i=#self.childs,1,-1 do
			current = self.childs[i]
			current:update(dt)
			if current:is_finished() then
				TABLE_REMOVE(self.childs,i)
			end
		end
		dt = COROUTINE_YIELD()
	end
end

return Action