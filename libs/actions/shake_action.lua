local COMMON = require "libs.common"
local PERLIN = require "libs.perlin"
local CHECKS = require "libs.checks"
local SmoothDumpV3 = require "libs.smooth_dump_v3"
local Action = require "libs.actions.action"

local CHECKS_CONFIG = {
	easing = "function",
	time = "number",
	x = "number",
	y = "number",
	perlin_power = "number",
	object = "userdata",
	smooth_time = "nil|number",
	max_speed = "nil|number",
	max_distance = "nil|number",
}

---@class ShakeAction:Action
local ShakeAction = COMMON.class("ShakeAction", Action)

function ShakeAction:config_check(config)
	CHECKS("?", CHECKS_CONFIG)
end

function ShakeAction:initialize(config)
	Action.initialize(self, config)
	self.perlin_seeds = { math.random(128), math.random(128), math.random(128) }
	self.position = gui.get_position(self.config.object)
	self.position_result = gui.get_position(self.config.object)
	self.position_current = gui.get_position(self.config.object)
	self.time = 0
	self.smooth_dump_v3 = SmoothDumpV3(config.smooth_time, config.max_speed, config.max_distance)

end

function ShakeAction:set_property()
	local a = 1 - self.config.easing(self.time, 0, 1, self.config.time)

	local lposition_x = self.config.x * a * (PERLIN.noise(self.time * self.config.perlin_power, self.perlin_seeds[1], self.perlin_seeds[1]))
	local lposition_y = self.config.y * a * (PERLIN.noise(self.time * self.config.perlin_power, self.perlin_seeds[1], self.perlin_seeds[2]))
	self.position_result.x = self.position.x + lposition_x
	self.position_result.y = self.position.y + lposition_y
end

function ShakeAction:act(dt)
	if self.config.delay then
		COMMON.coroutine_wait(self.config.delay)
	end

	while (self.time < self.config.time) do
		self:set_property()
		self.smooth_dump_v3:update(self.position_current, self.position_result, dt)
		gui.set_position(self.config.object, self.position_current)
		dt = coroutine.yield()
		self.time = self.time + dt
	end

	gui.set_position(self.config.object, self.position)
end

return ShakeAction