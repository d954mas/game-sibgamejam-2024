local COMMON = require "libs.common"
local ECS = require 'libs.ecs'
local DEFS = require "world.balance.def.defs"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"

local TEMP_DIR = vmath.vector3()
local TEMP_DIR_NORMALIZE = vmath.vector3()
local TEMP_Q = vmath.quat_rotation_z(0)

local POINTER_CFG = {
	INIT_SCALE_START = vmath.vector3(0.8, 0.8, 1), -- Initial smaller scale for compression
	INIT_SCALE_END = vmath.vector3(1, 1, 1), -- End scale back to normal
	MOVE_DOWN = vmath.vector3(0, -4, 0), -- Movement down to simulate tap
	MOVE_UP = vmath.vector3(0, 0, 0), -- Movement up back to original position
	TAP_ANIM_TIME = 0.25, -- Duration of the tap part of the animation
	PAUSE_CLICK = 0.1,
	PAUSE_TIME = 0.5, -- Duration of the pause between taps
}


local V_UP = vmath.vector3(0, 1, 0)

local FACTORY_URL = msg.url("game_scene:/factory#arrow")
local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
}

local Arrow = COMMON.class("Arrow")

function Arrow:initialize()
	self.pos_start = vmath.vector3()
	self.pos_end = vmath.vector3()
	self.length = 0

	self.shader_arrow = vmath.vector4(1, 1, 0, 0)

	local urls = collectionfactory.create(FACTORY_URL)
	self.go = {
		root = msg.url(assert(urls[PARTS.ROOT])),
		mesh = nil
	}
	self.go.mesh = COMMON.LUME.url_component_from_url(self.go.root, COMMON.HASHES.MESH)
	self.scale = go.get_scale(self.go.root)

	self:set_visible(true)
end

function Arrow:set_position_start(x, y, z)
	self.pos_start.x = x
	self.pos_start.y = y
	self.pos_start.z = z
end

function Arrow:set_visible(visible)
	self.visible = visible
	msg.post(self.go.root, self.visible and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE)
end

function Arrow:set_position_end(x, y, z)
	self.pos_end.x = x
	self.pos_end.y = y
	self.pos_end.z = z
end

function Arrow:refresh()
	xmath.sub(TEMP_DIR, self.pos_end, self.pos_start)
	local length = vmath.length(TEMP_DIR) - 0.2
	if length > 0 then
		xmath.normalize(TEMP_DIR_NORMALIZE, TEMP_DIR)
		self.shader_arrow.y = length * self.scale.z
	else
		length = 0
	end

	if self.length ~= length then
		local delta = length - self.length
		self.shader_arrow.w = self.shader_arrow.w - delta * self.scale.z
		self.length = length
	end

	-- Calculate midpoint using the differences
	local cx = self.pos_start.x + TEMP_DIR.x / 2
	local cy = self.pos_start.y + TEMP_DIR.y / 2
	local cz = self.pos_start.z + TEMP_DIR.z / 2
	local midpoint = vmath.vector3(cx, cy, cz)

	-- Update arrow's position to the midpoint
	go.set_position(midpoint, self.go.root)

	-- Scale the arrow in the y-axis to match the distance
	-- Assuming the arrow's length corresponds to its local y-axis

	self.scale.x = math.max(length / 2, 0.0001)
	go.set_scale(self.scale, self.go.root)

	if length < 0.3 then
		msg.post(self.go.root, COMMON.HASHES.MSG.DISABLE)
		return
	end
	msg.post(self.go.root, COMMON.HASHES.MSG.ENABLE)

	if length > 0 then
		xmath.quat_from_to(TEMP_Q, V_UP, TEMP_DIR_NORMALIZE)

		go.set_rotation(TEMP_Q, self.go.root)

		local angle = COMMON.LUME.angle_vector(TEMP_DIR.x, -TEMP_DIR.z)
		xmath.quat_rotation_y(TEMP_Q, angle)
		go.set_rotation(TEMP_Q, self.go.root)

		go.set(self.go.mesh, "arrow", self.shader_arrow)
	end
end

function Arrow:dispose()
	if self.go then
		go.delete(self.go.root)
	end
	self.go = nil
end

function Arrow:update(dt)
	local arrow_w = self.shader_arrow.w - 1 * dt
	if arrow_w < -1 then
		arrow_w = arrow_w + 1
	end
	self.shader_arrow.w = arrow_w
	if self.visible then
		self:refresh()
	end
end

local Pointer = COMMON.class("Pointer")

function Pointer:initialize(nodes, context_name)
	self.nodes = assert(nodes)
	self.vh = {
		root = nodes[hash("tutorial_pointer/root")],
		pointer = nodes[hash("tutorial_pointer/pointer")],
		glow = nodes[hash("tutorial_pointer/glow")],
	}
	self.rotation = vmath.vector3(0)
	self.context_name = assert(context_name)
	self.actions = ACTIONS.Sequence()
	self.initial_start_pos = gui.get_position(self.vh.pointer)
end

function Pointer:dispose()
	local ctx = COMMON.CONTEXT:set_context_top_by_name(self.context_name)
	if self.vh then
		gui.delete_node(self.vh.root)
	end
	ctx:remove()
	self.vh = nil
end
function Pointer:set_visible(visible)
	self.visible = visible
	local ctx = COMMON.CONTEXT:set_context_top_by_name(self.context_name)
	gui.set_enabled(self.vh.root, visible)
	ctx:remove()
end

function Pointer:set_target_node(node, node_context_name)
	self.target = {
		node = assert(node),
		node_context_name = node_context_name
	}
end

function Pointer:update(dt)
	if self.target then
		local ctx
		if self.target.node_context_name then
			ctx = COMMON.CONTEXT:set_context_top_by_name(self.target.node_context_name)
		end

		local position = gui.get_screen_position(self.target.node)
		gui.set_screen_position(self.vh.root, position)

		if ctx then
			ctx:remove()
		end
	end
	self.rotation.z = self.rotation.z - 33 * dt
	local ctx = COMMON.CONTEXT:set_context_top_by_name(self.context_name)
	gui.set_euler(self.vh.glow, self.rotation)
	self.actions:update(dt)
	ctx:remove()
end

function Pointer:on_resize()
	local ctx = COMMON.CONTEXT:set_context_top_by_name(self.context_name)
	gui.set_adjust_mode(self.vh.root, COMMON.RENDER.gui_scale.mode)
	gui.set_scale(self.vh.root, COMMON.RENDER.gui_scale.scale2)
	ctx:remove()
end

function Pointer:tap_animation(loop)
	print("tap animation")
	local action = ACTIONS.Sequence()
	local start_pos = vmath.vector3(self.initial_start_pos)

	-- Compress down (scale down and move down)
	action:add_action(ACTIONS.Parallel.array {
		ACTIONS.TweenGui {
			object = self.vh.pointer, property = "scale", v3 = true,
			to = POINTER_CFG.INIT_SCALE_START, time = POINTER_CFG.TAP_ANIM_TIME, easing = TWEEN.easing.inQuad
		},
		ACTIONS.TweenGui {
			object = self.vh.pointer, property = "position", v3 = true,
			from = start_pos - POINTER_CFG.MOVE_DOWN,
			to = start_pos, time = POINTER_CFG.TAP_ANIM_TIME, easing = TWEEN.easing.inQuad
		}
	})

	-- Pause before repeating the tap
	action:add_action(ACTIONS.Wait {
		time = POINTER_CFG.PAUSE_CLICK
	})

	-- Move back up (scale back to normal and move up)
	action:add_action(ACTIONS.Parallel.array {
		ACTIONS.TweenGui {
			object = self.vh.pointer, property = "scale", v3 = true,
			to = POINTER_CFG.INIT_SCALE_END, time = POINTER_CFG.TAP_ANIM_TIME, easing = TWEEN.easing.outQuad
		},
		ACTIONS.TweenGui {
			object = self.vh.pointer, property = "position", v3 = true,
			from = start_pos - POINTER_CFG.MOVE_DOWN,
			to = start_pos, time = POINTER_CFG.TAP_ANIM_TIME, easing = TWEEN.easing.outQuad
		}
	})

	-- Pause before repeating the tap
	action:add_action(ACTIONS.Wait {
		time = POINTER_CFG.PAUSE_TIME
	})

	-- Restart the animation if looping is enabled
	action:add_action(function()
		if loop then
			self:tap_animation(true)
		end
	end)

	self.actions:add_action(action)
end
---@class TutorialSystem:ECSSystem
local System = ECS.system()
System.name = "TutorialSystem"

function System:create_arrow()
	local arrow = Arrow()
	table.insert(self.arrows, arrow)
	return arrow
end

function System:create_pointer_game_gui()
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	local nodes = gui.clone_tree(gui.get_node("tutorial_pointer/root"))
	local pointer = Pointer(nodes, COMMON.CONTEXT.NAMES.GAME_GUI)
	ctx:remove()
	table.insert(self.pointers, pointer)

	return pointer
end

function System:coroutine_f()
	local tutorial = self.world.game_world.storage.tutorial
	coroutine.yield()
end

function System:onAddToWorld()
	self.arrows = {}
	self.pointers = {}

	self.cor = coroutine.create(System.coroutine_f)
	self.cor = COMMON.coroutine_resume(self.cor, self)

	self.subscriptions = {}
	table.insert(self.subscriptions, COMMON.EVENTS.WINDOW_RESIZED:subscribe(false, function()
		self:on_resize()
	end))

	self:on_resize()
end

function System:onRemoveFromWorld()
	for _, arrow in ipairs(self.arrows) do
		arrow:dispose()
	end
	self.arrows = nil
	for _, pointer in ipairs(self.pointers) do
		pointer:dispose()
	end
	self.pointers = nil

	for _, subscription in ipairs(self.subscriptions) do
		subscription()
	end
	self.subscriptions = nil
end

---@param e EntityGame
function System:update(dt)
	if self.cor then
		self.cor = COMMON.coroutine_resume(self.cor, dt)
	else
		self.world:removeSystem(self)
	end

	for i = #self.arrows, 1, -1 do
		local arrow = self.arrows[i]
		if (arrow.go == nil) then
			table.remove(self.arrows, i)
		else
			arrow:update(dt)
		end
	end

	for i = #self.pointers, 1, -1 do
		local pointer = self.pointers[i]
		if (pointer.vh == nil) then
			table.remove(self.pointers, i)
		else
			pointer:update(dt)
		end
	end
end

function System:on_resize()
	for _, pointer in ipairs(self.pointers) do
		pointer:on_resize()
	end
end

return System