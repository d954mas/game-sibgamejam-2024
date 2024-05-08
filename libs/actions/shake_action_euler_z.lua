local COMMON = require "libs.common"
local PERLIN = require "libs.perlin"
local CHECKS = require "libs.checks"
local Action = require "libs.actions.action"
local SmoothDump = require "libs.smooth_dump"

local CHECKS_CONFIG = {
	easing = "function",
	time = "number",
	angle = "number",
	perlin_power = "number",
	object = "userdata",
	smooth_time = "nil|number",
}

---@class ShakeEulerZAction:Action
local ShakeAction = COMMON.class("ShakeAction", Action)

function ShakeAction:config_check(config)
	CHECKS("?", CHECKS_CONFIG)
end

function ShakeAction:initialize(config)
	Action.initialize(self, config)
	self.perlin_seeds = { math.random(128), math.random(128), math.random(128) }
	self.angle = gui.get_rotation(self.config.object)
	self.angle_current = gui.get_rotation(self.config.object)
	self.angle_result = gui.get_rotation(self.config.object)
	self.time = 0
	self.smooth_dump = SmoothDump(config.smooth_time, config.max_speed)
end

function ShakeAction:set_property()
	local a = 1 - self.config.easing(self.time, 0, 1, self.config.time)
	local angle = self.config.angle * a * (PERLIN.noise(self.time * self.config.perlin_power, self.perlin_seeds[1], self.perlin_seeds[1]))
	self.angle_result.z = self.angle.z + angle --for some reason noize is return - more offen
end

function ShakeAction:act(dt)
	if self.config.delay then
		COMMON.coroutine_wait(self.config.delay)
	end

	while (self.time < self.config.time) do
		self:set_property()
		self.time = self.time + dt
		self.angle_current.z = self.smooth_dump:update(self.angle_current.z, self.angle_result.z, dt)
		gui.set_euler(self.config.object, self.angle_current)
		dt = coroutine.yield()

	end

	gui.set_euler(self.config.object, self.angle)
end

return ShakeAction