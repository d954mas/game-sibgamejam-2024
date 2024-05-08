local COMMON = require "libs.common"
local WORLD = require "world.world"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"
local SmoothDump = require "libs.smooth_dump"

local View = COMMON.class("ResourcePanel")

function View:initialize(root_name, resource)
	self.root_name = assert(root_name)
	self.resource = resource
	self.def = assert(DEFS.RESOURCES[resource])
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		icon = gui.get_node(root_name .. "/icon"),
		lbl = gui.get_node(root_name .. "/lbl"),
	}
	self.value = 0
	self.value_visual = 0
	self.smooth_dump = SmoothDump(0.166, math.huge)
	self:set_value(WORLD.storage.resources:get(resource), true)
	gui.play_flipbook(self.vh.icon, self.def.icon)

end

function View:event_add_resource(resource, value, placement)
	if (resource == self.resource) then
		if (placement == ENUMS.RESOURCE_ADD_PLACEMENT.GAME) then
			self:add_value(value)
		elseif (placement == ENUMS.RESOURCE_ADD_PLACEMENT.GAME_OFFER) then
			---@type TopPanelGuiScript
			local gui_script = COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.TOP_PANEL).data
			local from = gui.get_screen_position(gui_script.vh.offer_fly_point)
			local to = gui.get_screen_position(self.vh.icon)
			gui_script:fly_resource(self.resource, value, from, to, 0, 1.5)
		elseif (placement == ENUMS.RESOURCE_ADD_PLACEMENT.TASK_REWARD) then
			local gui_script = COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.TOP_PANEL).data
			local from = gui.get_screen_position(gui_script.vh.offer_fly_point)
			local to = gui.get_screen_position(self.vh.icon)
			if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.QUEST_GUI) then
				local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.QUEST_GUI)
				if resource == DEFS.RESOURCES.GOLD.id then
					from = gui.get_screen_position(ctx.data.vh.reward_icon_gold)
				end
				ctx:remove()
			end
			gui_script:fly_resource(self.resource, value, from, to, 0, 1.5)
		elseif (placement == ENUMS.RESOURCE_ADD_PLACEMENT.OFFLINE_PROGRESS) then
			local gui_script = COMMON.CONTEXT:get(COMMON.CONTEXT.NAMES.TOP_PANEL).data
			local from = gui.get_screen_position(gui_script.vh.offer_fly_point)
			local to = gui.get_screen_position(self.vh.icon)
			if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.OFFLINE_INCOME_GUI) then
				local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.OFFLINE_INCOME_GUI)
				if resource == DEFS.RESOURCES.GOLD.id then
					from = gui.get_screen_position(ctx.data.vh.reward.gold.icon)
				end
				ctx:remove()
			end
			gui_script:fly_resource(self.resource, value, from, to, 0, 1.5)
		elseif (placement == ENUMS.RESOURCE_ADD_PLACEMENT.BATTLE_WIN) then
			self:add_value(value)
		else
			self:add_value(value)
		end
	end
end

function View:event_spend_resource(resource, value, placement)
	if (resource == self.resource) then
		self:spend_value(value)
	end
end

function View:set_value(value, forced)
	self.value = value
	if forced then
		self.value_visual = value
		self:refresh_lbl()
	end
end

function View:add_value(value)
	self:set_value(self.value + value)
end

function View:spend_value(value)
	self:set_value(self.value - value)
end

function View:refresh_lbl()
	gui.set_text(self.vh.lbl, COMMON.LUME.formatIdleNumber(self.value_visual))
end

function View:update(dt)
	self.smooth_dump.maxDelta = math.min(self.value_visual, self.value) * 0.001
	local new_value = self.smooth_dump:update(self.value_visual, self.value, dt)

	if new_value ~= self.value_visual then
		self.value_visual = new_value
		self:refresh_lbl()
	end
end

function View:dispose()
	gui.delete_node(self.vh.root)
	self.vh = nil
end

return View