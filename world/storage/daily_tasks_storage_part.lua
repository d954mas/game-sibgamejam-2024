local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"

local StoragePart = require "world.storage.storage_part_base"

---@class DailyTaskStoragePart:StoragePartBase
local Storage = COMMON.class("DailyTaskStoragePart", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.daily_tasks = self.storage.data.daily_tasks
end

function Storage:get_state(idx)
	return assert(self.daily_tasks.tasks[idx].state)
end

function Storage:task_add_value(task, value)
	if task.state == ENUMS.DAILY_TASK_STATE.IN_PROGRESS then
		task.value = task.value + value
		if task.value >= task.need then
			task.state = ENUMS.DAILY_TASK_STATE.DONE
			ANALYTICS_HELPER.daily_task_done(task.type, self.daily_tasks.day)


			--check if all task completed
			local have_task_in_progress = false
			for _, check_task in ipairs(self.daily_tasks.tasks) do
				if check_task.state == ENUMS.DAILY_TASK_STATE.IN_PROGRESS then
					have_task_in_progress = true
					break
				end
			end
			if not have_task_in_progress then
				self.daily_tasks.state = ENUMS.DAILY_TASKS_STATE.NEED_COLLECT
			end
			self:save_and_changed()
		end

	end
end

function Storage:collect()
	--if self.daily_tasks.state == ENUMS.DAILY_TASKS_STATE.NEED_COLLECT then
	self.daily_tasks.state = ENUMS.DAILY_TASKS_STATE.COLLECTED
	self.daily_tasks.total_collected = self.daily_tasks.total_collected + 1
	ANALYTICS_HELPER.daily_tasks_collect(self.daily_tasks.total_collected)
	local reward_gold = self.world.game:offer_get_value(DEFS.RESOURCES.GOLD.id) * 3
	self.storage.resources:add(DEFS.RESOURCES.GOLD.id, reward_gold, ENUMS.RESOURCE_ADD_PLACEMENT.TASK_REWARD)
	self:save_and_changed()
	--	end
end

function Storage:update_time(dt)
	self:task_add_value(self.daily_tasks.tasks[1], dt)
end

function Storage:get_day()
	return self.daily_tasks.day
end

function Storage:update(dt)
	self:update_time(dt)
end

return Storage