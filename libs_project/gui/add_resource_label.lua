local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"
local GUI = require "libs_project.gui.gui"
local DEFS = require "world.balance.def.defs"

local INIT_SCALE = vmath.vector3(0.012)
local INIT_SCALE_START = INIT_SCALE * 0.02

local COLOR_HIDE = vmath.vector4(1, 1, 1, 0)


local CFG_DEFAULT = {
	dpos = vmath.vector3(0, 1, 0)
}

local TEMP_V = vmath.vector3()

local View = COMMON.class("PowerLabel")

function View:initialize(vh)
	self.vh = {
		root = assert(vh.root),
		lbl = assert(vh.lbl),
		icon = assert(vh.icon),
		origin = assert(vh.origin)
	}
	gui.set_scale(self.vh.origin, INIT_SCALE)
	gui.set_enabled(self.vh.root, true)
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
	self.position = vmath.vector3()
	self.position_anim_camera = vmath.vector3()
	self.position_anim_current = vmath.vector3()
end

function View:set_value(value)
	gui.set_text(self.vh.lbl, COMMON.LUME.formatIdleNumber(value, 1))
	GUI.set_nodes_to_center(self.vh.icon, false, self.vh.lbl, true, 4)
end

function View:set_resource(id)
	self.resource_id = assert(id)
	gui.play_flipbook(self.vh.icon, DEFS.RESOURCES[id].icon)
	gui.set_color(self.vh.lbl, DEFS.RESOURCES[id].font_color)
	gui.set_outline(self.vh.lbl, DEFS.RESOURCES[id].font_outline_color)
end

function View:set_position(position)
	xmath.vector(self.position, position)
	gui.set_position(self.vh.root, position)
end

---@param e EntityGame
function View:set_follow_e(e)
	self.follow_e = e
end

function View:show(cfg)
	cfg = cfg or CFG_DEFAULT
	if self.follow_e then
		xmath.vector(self.position_anim_camera, self.follow_e.camera.position)
		xmath.vector(self.position_anim_current, self.position)
	end

		local action = ACTIONS.Parallel()
		local start_scale = INIT_SCALE_START
		local target_scale = INIT_SCALE
		gui.set_scale(self.vh.origin, start_scale)
		local pos = gui.get_position(self.vh.origin)
		action:add_action(ACTIONS.TweenGui {
			object = self.vh.origin, property = "scale", v3 = true,
			to = target_scale, time = 0.15, easing = TWEEN.easing.inBounce
		})
		action:add_action(ACTIONS.TweenGui {
			object = self.vh.origin, property = "position", v3 = true,
			to = pos + cfg.dpos, time = 0.5, easing = TWEEN.easing.inCubic
		})

		action:add_action(ACTIONS.TweenGui {
			object = self.vh.origin, property = "position", v3 = true,
			from = pos + cfg.dpos,
			to = pos + cfg.dpos * 3, time = 0.5, easing = TWEEN.easing.inCubic, delay = 0.5
		})
		action:add_action(ACTIONS.TweenGui {
			object = self.vh.origin, property = "color", v4 = true,
			to = COLOR_HIDE, time = 0.5, easing = TWEEN.easing.inCubic, delay = 0.5
		})
		action:add_action(function()
			COMMON.coroutine_wait(1)
			self:destroy()
		end)

		self.actions:add_action(action)

end

function View:update(dt)
	self.actions:update(dt)
	if self.follow_e then
		xmath.sub(TEMP_V, self.follow_e.camera.position, self.position_anim_camera)
		xmath.add(self.position, self.position_anim_current, TEMP_V)
		gui.set_position(self.vh.root, self.position)
	end

end

function View:destroy()
	gui.delete_node(self.vh.root)
	self.vh = nil
	self.follow_e = false
end

return View