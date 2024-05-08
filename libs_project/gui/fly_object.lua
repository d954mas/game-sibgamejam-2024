local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local COLOR_INVISIBLE = vmath.vector4(1, 1, 1, 0)
local COLOR_WHITE = vmath.vector4(1, 1, 1, 1)

local GUI_SET_SCREEN_POSITION = gui.set_screen_position
local COROUTINE_YIELD = coroutine.yield

--@class FlyObjectGui
local FlyObject = COMMON.class("FlyObject")

function FlyObject:initialize(nodes)
	self.vh = {
		root = nodes["root"],
		icon = nodes["icon"],
	}
	self.action = ACTIONS.Sequence()
	self.alive = true
end

function FlyObject:reset()
	self.action = ACTIONS.Sequence()
	gui.set_enabled(self.vh.root, false)
	self.alive = false
end

function FlyObject:destroy()
	if self.vh then
		gui.delete_node(self.vh.root)
		self.vh = nil
	end
end

function FlyObject:fly(config)
	local from = config.from
	--if (config.from_world) then
	--	from = CAMERAS.game_camera:world_to_screen(assert(config.from_world))
	--end
	GUI_SET_SCREEN_POSITION(self.vh.root, assert(from))
	gui.set_enabled(self.vh.root, true)

	local function_move = function()
		from = config.from
		if (config.from_world) then
			from = CAMERAS.game_camera:world_to_screen(assert(config.from_world))
		end
		local gui_pos_x, gui_pos_y = from.x, from.y

		local target = config.to
		local target_gui_x, target_gui_y = target.x, target.y

		local dx = target_gui_x - gui_pos_x
		local dy = target_gui_y - gui_pos_y

		local tween_table = { dx = 0, dy = 0 }
		local dx_time = math.abs(dx / config.speed_x or 500)
		local dy_time = math.abs(dy / config.speed_y or 500)
		local time = math.max(dx_time, dy_time)
		local tween_x = ACTIONS.TweenTable { delay = 0.1, object = tween_table, property = "dx", from = { dx = 0 },
											 to = { dx = dx }, time = time, easing = TWEEN.easing.linear }
		local tween_y = ACTIONS.TweenTable { delay = 0.1, object = tween_table, property = "dy", from = { dy = 0 },
											 to = { dy = dy }, time = time + 0.1, easing = TWEEN.easing.outQuad }
		local move_action = ACTIONS.Parallel()
		move_action:add_action(tween_x)
		move_action:add_action(tween_y)
		move_action:add_action(function()
			local v = vmath.vector3(0)
			while (tween_table.dx ~= dx and tween_table.dy ~= dy) do
				v.x, v.y = gui_pos_x + tween_table.dx, gui_pos_y + tween_table.dy
				GUI_SET_SCREEN_POSITION(self.vh.root, v)
				COROUTINE_YIELD()
			end
			GUI_SET_SCREEN_POSITION(self.vh.root, config.to)
		end)
		while (not move_action:is_finished()) do
			move_action:update(COROUTINE_YIELD())
		end
	end

	local action_appear = ACTIONS.Parallel()
	if (config.appear) then
		gui.set_color(self.vh.root, COLOR_INVISIBLE)
		local tint = ACTIONS.TweenGui { object = self.vh.root, property = "color", v4 = true,
										from = COLOR_INVISIBLE, to = COLOR_WHITE, time = 0.15,
										easing = TWEEN.easing.inQuad }
		action_appear:add_action(tint)
		action_appear:add_action(function()
			while (not tint:is_finished()) do
				if (config.from_world) then
					GUI_SET_SCREEN_POSITION(self.vh.root, CAMERAS.game_camera:world_to_screen(assert(config.from_world)))
				end
				COROUTINE_YIELD()
			end
		end)
		local sequenceAction = ACTIONS.Sequence()
		sequenceAction:add_action(ACTIONS.Wait { time = 0.1 })
		sequenceAction:add_action(function_move)
		action_appear:add_action(sequenceAction)
	else
		action_appear:add_action(function_move)
	end

	if (config.delay) then
		self.action:add_action(ACTIONS.Wait { time = config.delay })
	end
	self.action:add_action(action_appear)
	if config.disappear then
		self.action:add_action(ACTIONS.TweenGui { object = self.vh.root, property = "color", v4 = true,
												  from = COLOR_WHITE, to = COLOR_INVISIBLE , time = 0.15,
												  easing = TWEEN.easing.inQuad }
		)
	end
	self.action:add_action(function()
		if (config.cb) then
			config.cb()
		end
		COMMON.coroutine_wait(0.1)
		self.alive = false
	end)
end

function FlyObject:update(dt)
	self.action:update(dt)
end

function FlyObject:is_animated()
	return self.action:is_running()
end

return FlyObject