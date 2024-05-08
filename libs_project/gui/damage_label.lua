local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local INIT_SCALE = vmath.vector3(0.0075)
local INIT_SCALE_START = INIT_SCALE * 0.02
local CRIT_SCALE = INIT_SCALE * 1.5
local CRIT_SCALE_START = CRIT_SCALE * 0.02

local COLOR_HIDE = vmath.vector4(1, 1, 1, 0)

local COLORS = {
	--damage on player
	PLAYER_DAMAGE = COMMON.LUME.color_parse_hexRGBA("#526D82"),
	ENEMY_DAMAGE = COMMON.LUME.color_parse_hexRGBA("#EF6262"),
	ENEMY_CRIT_DAMAGE = COMMON.LUME.color_parse_hexRGBA("#B70404"),
}

local View = COMMON.class("DamageGui")

function View:initialize(vh)
	self.vh = {
		root = assert(vh.root),
		lbl = assert(vh.lbl)
	}
	gui.set_scale(self.vh.root, INIT_SCALE)
	gui.set_enabled(self.vh.root, true)
	self:set_enemy_damage()
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
end

function View:set_position(position)
	gui.set_position(self.vh.root, position)
end

function View:set_player_damage()
	gui.set_color(self.vh.lbl, COLORS.PLAYER_DAMAGE)
end
function View:set_enemy_damage()
	gui.set_color(self.vh.lbl, COLORS.ENEMY_DAMAGE)
end
function View:set_enemy_crit_damage()
	self.crit = true
	gui.set_color(self.vh.lbl, COLORS.ENEMY_CRIT_DAMAGE)
end

function View:show(cfg)
	local action = ACTIONS.Parallel()
	local start_scale = self.crit and CRIT_SCALE_START or INIT_SCALE_START
	local target_scale = self.crit and CRIT_SCALE or INIT_SCALE
	gui.set_scale(self.vh.root, start_scale)
	local pos = gui.get_position(self.vh.root)
	action:add_action(ACTIONS.TweenGui {
		object = self.vh.root, property = "scale", v3 = true,
		to = target_scale, time = 0.1, easing = TWEEN.easing.inBounce
	})
	action:add_action(ACTIONS.TweenGui {
		object = self.vh.root, property = "position", v3 = true,
		to = pos + cfg.dpos, time = 0.33, easing = TWEEN.easing.inCubic
	})

	action:add_action(ACTIONS.TweenGui {
		object = self.vh.root, property = "position", v3 = true,
		from = pos + cfg.dpos,
		to = pos + cfg.dpos * 3, time = 0.33, easing = TWEEN.easing.inCubic, delay = 0.5
	})
	action:add_action(ACTIONS.TweenGui {
		object = self.vh.root, property = "color", v4 = true,
		to = COLOR_HIDE, time = 0.33, easing = TWEEN.easing.inCubic, delay = 0.5
	})
	action:add_action(function()
		COMMON.coroutine_wait(1)
		self:destroy()
	end)

	self.actions:add_action(action)
end

function View:update(dt)
	self.actions:update(dt)
end

function View:set_damage(damage)
	gui.set_text(self.vh.lbl, damage)
end

function View:destroy()
	gui.delete_node(self.vh.root)
	self.vh = nil
end

return View