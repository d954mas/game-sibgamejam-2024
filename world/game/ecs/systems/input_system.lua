local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local TWEEN = require "libs.tween"
local ENUMS = require "world.enums.enums"

local HASHES_INPUT = COMMON.HASHES.INPUT
local PRESSED = COMMON.INPUT.PRESSED_KEYS

---@class InputSystem:ECSSystem
local System = ECS.system()
System.name = "InputSystem"

function System:init()
	self.movement = vmath.vector4(0) --forward/back/left/right
	self.movement_up = vmath.vector4(0) --up/down for ghost
end

function System:movement_f(dt)
	--check movement input
	if COMMON.INPUT.IGNORE or self.world.game_world.game.state.completed then
		self.movement.x = 0
		self.movement.y = 0
		self.movement.w = 0
		self.movement.z = 0
		self.movement_up.x = 0
		self.movement_up.y = 0
	else
		self.movement.x = (PRESSED[HASHES_INPUT.ARROW_UP] or PRESSED[HASHES_INPUT.W]) and 1 or 0
		self.movement.y = (PRESSED[HASHES_INPUT.ARROW_DOWN] or PRESSED[HASHES_INPUT.S]) and 1 or 0
		self.movement.w = (PRESSED[HASHES_INPUT.ARROW_LEFT] or PRESSED[HASHES_INPUT.A]) and 1 or 0
		self.movement.z = (PRESSED[HASHES_INPUT.ARROW_RIGHT] or PRESSED[HASHES_INPUT.D]) and 1 or 0
		self.movement_up.x = PRESSED[HASHES_INPUT.SPACE] and 1 or 0
		self.movement_up.y = PRESSED[HASHES_INPUT.LEFT_SHIFT] and 1 or 0
	end

	local player = self.world.game_world.game.level_creator.player
	local movement = player.movement
	movement.input.x = self.movement.z - self.movement.w --right left
	movement.input.y = self.movement_up.x - self.movement_up.y
	movement.input.z = self.movement.y - self.movement.x-- forward back

	movement.max_speed_limit = 1

	if (COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME_GUI)) then
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		local pad = ctx.data.views.virtual_pad
		if (pad:visible_is()) then
			if (not pad:is_safe()) then
				movement.input.x, movement.input.z = pad:get_data()
				movement.input.z = -movement.input.z
				movement.input.y = 0

				local min = 0.2
				local a = math.max(math.abs(movement.input.z), math.abs(movement.input.x))
				movement.max_speed_limit = min + (1 - min) * TWEEN.easing.outQuad(a, 0, 1, 1)
			end
		end
		ctx:remove()
	end

	if not self.world.game_world.game.state.first_move then
		if (movement.input.x ~= 0 or movement.input.z ~= 0) then
			if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME_GUI) then
				self.world.game_world.game.state.first_move = true
				local ctx = COMMON.CONTEXT:set_context_top_game_gui()
				ctx.data:hide_input_tooltip()
				ctx:remove()
			end
		end
	end

	local move_x = movement.input.x
	if player.movement.type == ENUMS.PLAYER_MOVEMENT.FIXED_CAMERA then
		if move_x ~= 0 then
			local min = 0
			local a = math.abs(move_x)
			a = min + (1 - min) * TWEEN.easing.outQuad(a, 0, 1, 1)
			player.angle = (player.angle - math.pi * move_x * a * dt) % (2 * math.pi)
		end
	end
end

function System:update(dt)
	self:movement_f(dt)
end

return System