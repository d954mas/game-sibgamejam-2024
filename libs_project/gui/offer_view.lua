local COMMON = require "libs.common"
local WORLD = require "world.world"
local DEFS = require "world.balance.def.defs"
local ProgressBar = require "libs_project.gui.progress_bar"

---@class OfferView
local View = COMMON.class("TaskView")

function View:initialize(nodes)
	self.nodes = assert(nodes)
	self.vh = {
		root = assert(self.nodes[hash("offer/root")]),
		icon = assert(self.nodes[hash("offer/icon")]),
		glow = assert(self.nodes[hash("offer/glow")]),
		lbl = assert(self.nodes[hash("offer/lbl")]),
		click_area = assert(self.nodes[hash("offer/click_area")]),
	}
	local progress_vh = {
		root = assert(self.nodes[hash("offer/bar/root")]),
		bg = assert(self.nodes[hash("offer/bar/bg")]),
		progress = assert(self.nodes[hash("offer/bar/progress")]),
		lbl = assert(self.nodes[hash("offer/bar/lbl")]),
	}
	self.views = {
		progress = ProgressBar(progress_vh),
	}
	gui.set_enabled(self.vh.root, true)

	self.views.progress.lbl_format_value = function(bar)
		local f = bar.animation.value > bar.value_max / 2 and math.ceil or math.floor
		return f(bar.animation.value)
	end
	gui.animate(self.vh.glow, "euler.z", -360, gui.EASING_LINEAR, 15, 0, nil, gui.PLAYBACK_LOOP_FORWARD)

	self.time = 0
end

function View:set_time_max(value)
	self.views.progress:set_value_max(value)
end

function View:set_time(value)
	self.time = value
	self.views.progress:set_value(value, true)
end

function View:set_resource(id)
	local def = assert(DEFS.RESOURCES[id])
	gui.play_flipbook(self.vh.icon, def.icon)
	gui.set_color(self.vh.lbl,def.font_color)
	gui.set_outline(self.vh.lbl,def.font_outline_color)
end

function View:set_value(value)
	gui.set_text(self.vh.lbl, COMMON.LUME.formatIdleNumber(value))
end

function View:update(dt)
end

function View:on_input(action_id, action)
	if self.vh and action_id == COMMON.HASHES.INPUT.TOUCH
			and gui.pick_node(self.vh.click_area, action.x, action.y) and action.pressed then
		WORLD.game:take_offer()
		return true
	end
end

function View:dispose()
	gui.delete_node(self.vh.root)
	self.vh = nil
	self.views.progress:destroy()
end

return View