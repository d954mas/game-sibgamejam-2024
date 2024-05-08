local COMMON = require "libs.common"

local VirtualPad = COMMON.class("VirtualPad")

function VirtualPad:initialize(root_name)
	self.root_name = assert(root_name)
	self:bind_vh()
	self:init_view()
	self.enabled = true
	self.touch_id = nil
	self.safe_zone_time = 100
	self.borders = { 0, 0, COMMON.RENDER.config_size.w, COMMON.RENDER.config_size.h }--x,y,x2,y2
end

function VirtualPad:set_enabled(enabled)
	self.enabled = enabled
end

function VirtualPad:is_enabled()
	return self.enabled
end

function VirtualPad:bind_vh()
	self.vh = {
		root = gui.get_node(self.root_name .. "/root"),
		bg = gui.get_node(self.root_name .. "/bg"),
		center = gui.get_node(self.root_name .. "/center"),
		drag = gui.get_node(self.root_name .. "/drag"),
	}
end
function VirtualPad:init_view()
	self.data = {
		position = vmath.vector3(0),
		position_drag = vmath.vector3(0),
		dist_max = 100,
		dist_safe = 10,
	}
	self:visible_set(false)
end

function VirtualPad:visible_set(visible)
	gui.set_enabled(self.vh.root, visible)
end

function VirtualPad:visible_is()
	return gui.is_enabled(self.vh.root)
end

function VirtualPad:pressed(x, y, touch_id)
	self.touch_id = touch_id or 0

	self.data.position.x, self.data.position.y = x, y
	self:visible_set(true)
	gui.set_position(self.vh.root, self.data.position)
end

function VirtualPad:reset()
	self.data.position.x, self.data.position.y = 0, 0
	self.data.position_drag.x, self.data.position_drag.y = 0, 0
	self:visible_set(false)
	self.touch_id = nil
	self.safe_zone_time = 100
end

local ACTIONS = {}
function VirtualPad:on_input(action_id, action_base)
	if (not self.enabled) then return false end

	if (action_id == COMMON.HASHES.INPUT.TOUCH or action_id == COMMON.HASHES.INPUT.TOUCH_MULTI) then
		if (action_id == COMMON.HASHES.INPUT.TOUCH) then
			action_base.id = 0
			COMMON.LUME.cleari(ACTIONS)
			ACTIONS[1] = action_base
			for _, action in ipairs(COMMON.INPUT.TOUCH_MULTI) do
				table.insert(ACTIONS, action)
			end
		end
		local actions = action_base.touch or ACTIONS

		local handled_action = false
		--check current finger
		for _, action in ipairs(actions) do
			local x = action.x
			if (action.id == self.touch_id) then
				handled_action = x <= self.borders[3] and action
				break
			end
		end
		if (not handled_action) then
			--try find new finger
			for _, action in ipairs(actions) do
				local x, y = action.x, action.y
				if (x <= self.borders[3]) then
					self:pressed(x, y, action.id)
					handled_action = action
					break
				end
			end
		end
		if (not handled_action) then
			self:reset()
			return
		end

		local x, y = handled_action.x, handled_action.y
		if (self:visible_is()) then
			self.data.position_drag.x = x - self.data.position.x
			self.data.position_drag.y = y - self.data.position.y
			local dist = vmath.length(self.data.position_drag)
			if (dist > self.data.dist_max) then
				local scale = self.data.dist_max / dist
				self.data.position_drag.x = self.data.position_drag.x * scale
				self.data.position_drag.y = self.data.position_drag.y * scale
			end
			gui.set_position(self.vh.drag, self.data.position_drag)
		end
		if (handled_action.released) then
			self:reset()
		end
	end
end

---@return number x[-1,1]
---@return number y[-1,1]
function VirtualPad:get_data()
	local x = COMMON.LUME.clamp(self.data.position_drag.x / self.data.dist_max, -1, 1)
	local y = COMMON.LUME.clamp(self.data.position_drag.y / self.data.dist_max, -1, 1)
	return x, y
end

function VirtualPad:is_in_safe_area()
	local dist = vmath.length(self.data.position_drag)
	return dist < self.data.dist_safe
end

function VirtualPad:is_safe()
	if (self.safe_zone_time < 0.33) then
		return false
	end
	return self:is_in_safe_area()
end

function VirtualPad:update(dt)
	if (self:visible_is()) then
		if COMMON.INPUT.IGNORE then
			self:reset()
		end
		if (self:is_in_safe_area()) then
			self.safe_zone_time = self.safe_zone_time + dt
		else
			self.safe_zone_time = 0
		end
	end
end

return VirtualPad