local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"
local SmoothDumpV3 = require "libs.smooth_dump_v3"

local TABLE_REMOVE = table.remove
local TABLE_INSERT = table.insert

local FACTORY_URL_PLAYER = msg.url("game_scene:/factory#player")
local FACTORY_URL_CHILD = msg.url("game_scene:/factory#child")
local FACTORY_URL_ENEMY = msg.url("game_scene:/factory#enemy")
local FACTORY_URL_BLOCK_MOVE = msg.url("game_scene:/factory#cell_block_move")

local DIR_UP = vmath.vector3(0, 1, 0)

local CELL_FACTORIES = {
	[ENUMS.CELL_TYPE.BLOCK_STATIC] = msg.url("game_scene:/factory#cell_block_static"),
	[ENUMS.CELL_TYPE.BLOCK_LEVEL] = msg.url("game_scene:/factory#cell_block_level"),
	[ENUMS.CELL_TYPE.BLOCK] = msg.url("game_scene:/factory#cell_block"),
	[ENUMS.CELL_TYPE.BLOCK_SPAWN] = msg.url("game_scene:/factory#cell_block_spawn"),
	[ENUMS.CELL_TYPE.BLOCK_FAKE] = msg.url("game_scene:/factory#cell_block_fake"),
	[ENUMS.CELL_TYPE.EMPTY] = nil,
	[ENUMS.CELL_TYPE.EXIT] = msg.url("game_scene:/factory#cell_block_exit"),
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	BLOCK = COMMON.HASHES.hash("/block"),
}

---@class InputInfo
---@field action_id hash
---@field action table

---@class EntityGame
---@field _in_world boolean is entity in world

---@class ENTITIES
local Entities = COMMON.class("Entities")

---@param world World
function Entities:initialize(world)
	self.world = world
	---@type EntityGame[]
	self.pool_input = {}

	self.childs = {}
end



--region ecs callbacks
---@param e EntityGame
function Entities:on_entity_removed(e)
	e._in_world = false
	if (e.input_info) then
		TABLE_INSERT(self.pool_input, e)
	end

	if (e.child) then
		COMMON.LUME.removei(self.childs, e)
	end

	if (e.frustum_native) then
		e.frustum_native:Destroy()
		e.frustum_native = nil
	end

	if (e.physics_object) then
		game.physics_object_destroy(e.physics_object)
		e.physics_object = nil
	end
	if (e.distance_to_player_object) then
		game.distance_object_destroy(e.distance_to_player_object)
		e.distance_to_player_object = nil
	end

	if e.player_go then
		go.delete(e.player_go.root, true)
		if e.player_go.model.mesh then e.player_go.model.mesh:dispose() end
		e.player_go = nil
	end
	if e.child_go then
		go.delete(e.child_go.root, true)
		if e.child_go.model.mesh then e.child_go.model.mesh:dispose() end
		e.child_go = nil
	end
	if e.level_cells then
		local map = e.level_cells.map
		local w = #map[1]
		for y = 1, #map do
			for x = 1, w do
				local cell = map[y][x]
				if cell.cell_go then
					go.delete(cell.cell_go.root, true)
				end
			end
		end
		e.level_cells = nil
	end
	if e.light then
		self.world.game.lights:remove_light(e.light)
		e.light = nil
	end
	if e.lights then
		for _, l in ipairs(e.lights) do
			self.world.game.lights:remove_light(l)
		end
		e.lights = nil
	end
end

---@param e EntityGame
function Entities:on_entity_added(e)
	e._in_world = true
	if e.child then
		table.insert(self.childs, e)
	end
end
--endregion


--region Entities
--[[
function Entities:__create_frustum_bbox(e, position, size, dynamic, frustum_native_dynamic_delta_pos)
	if (dynamic == true) then
		e.frustum_native_dynamic = true
		e.frustum_native_dynamic_delta_pos = frustum_native_dynamic_delta_pos or vmath.vector3()
		position = position + e.frustum_native_dynamic_delta_pos
	end
	e.frustum_native = game.frustum_object_create()
	e.frustum_native:SetPosition(position)
	e.frustum_native:SetSize(size)
	e.frustum_native:SetDistance(self.world.balance.config.frustum_default_distance)
end
--]]

---@return EntityGame
function Entities:create_input(action_id, action)
	local input = TABLE_REMOVE(self.pool_input)
	if (not input) then
		input = { input_info = {}, auto_destroy = true }
	end
	input.input_info.action_id = action_id
	input.input_info.action = action
	return input
end

---@return EntityGame
function Entities:create_player(position)
	---@type EntityGame
	local e = { }
	e.player = true
	e.position = vmath.vector3(position)
	e.angle = 0
	e.skin = DEFS.SKINS.SKINS_BY_ID.BOXER.id
	e.look_dir = vmath.vector3(0, 0, -1)
	e.camera = {
		position = vmath.vector3(),
		rotation = vmath.quat_rotation_z(0),
		rotation_euler = vmath.vector3(),
		pitch = 0,
		yaw = 0,
		config = {
			position = vmath.vector3(0, 5, 3),
			pitch = { value = math.rad(-35) },
			fov = math.rad(60)
		},
		config_portrait = {
			position = vmath.rotate(vmath.quat_rotation_x(math.rad(-60)), vmath.vector3(0, 0, 1)) * 5,
			pitch = { value = math.rad(-55) },
			fov = math.rad(60)
		},
	}
	e.movement = {
		input = vmath.vector3(0, 0, 0),
		velocity = vmath.vector3(0, 0, 0),
		direction = vmath.vector3(0, 0, 0),
		max_speed = 10,
		max_speed_air_limit = 0.7,
		accel = 8 * 0.016,
		deaccel = 15 * 0.016,
		accel_air = 1.5 * 0.016,
		deaccel_air = 3 * 0.016,
		deaccel_stop = 0.5,
		strafe_power = 1,
		strafe_power_air = 0.8,

		pressed_jump = false,

		air_control_power = 0,
		air_control_power_a = 0
	}

	e.on_ground = false
	e.in_jump = true
	e.ground_normal = vmath.vector3(DIR_UP)
	e.on_ground_time = self.world.game.state.time - 0.15
	e.jump_last_time = -1
	e.physics_reset_y_velocity = 0
	e.jump = {
		power = 335
	}

	local urls = collectionfactory.create(FACTORY_URL_PLAYER, e.position)
	e.player_go = {
		root = msg.url(assert(urls[PARTS.ROOT])),
		collision = nil,
		model = {
			root = nil,
			model = nil,
			mesh_root = nil,
			mesh_origin = nil
		},
		gloves = {
			left = { root = nil, model = nil },
			right = { root = nil, model = nil }
		},
		config = {
			gloves = nil,
			skin = nil,
			animation = nil,
			look_dir = vmath.vector3(0, 0, -1),
			look_dir_smooth_dump = SmoothDumpV3(0.05),
			spawn_animation = true
		},
	}
	e.player_go.collision = COMMON.LUME.url_component_from_url(e.player_go.root, "collision")
	e.physics_linear_velocity = vmath.vector3()
	e.physics_object = game.physics_object_create(e.player_go.root, e.player_go.collision, e.position, e.physics_linear_velocity)
	e.mass = go.get(e.player_go.collision, COMMON.HASHES.MASS)
	return e
end

---@return EntityGame
function Entities:create_child(position)
	---@type EntityGame
	local e = { }
	e.child = true
	e.position = vmath.vector3(position)
	e.angle = 0
	e.skin = DEFS.SKINS.SKINS_BY_ID.CHILD.id
	e.look_dir = vmath.vector3(0, 0, 1)

	local urls = collectionfactory.create(FACTORY_URL_CHILD, e.position)
	e.child_go = {
		root = msg.url(assert(urls[PARTS.ROOT])),
		collision = nil,
		model = {
			root = nil,
			model = nil,
			mesh_root = nil,
			mesh_origin = nil
		},
		gloves = {
			left = { root = nil, model = nil },
			right = { root = nil, model = nil }
		},
		config = {
			gloves = nil,
			skin = nil,
			animation = nil,
			look_dir = vmath.vector3(0, 0, 1),
			look_dir_smooth_dump = SmoothDumpV3(0.05),
			spawn_animation = true
		},
	}
	e.child_go.collision = COMMON.LUME.url_component_from_url(e.child_go.root, "collision")
	e.physics_linear_velocity = vmath.vector3()
	e.physics_object = game.physics_object_create(e.child_go.root, e.child_go.collision, e.position, e.physics_linear_velocity)
	e.mass = go.get(e.child_go.collision, COMMON.HASHES.MASS)
	return e
end

function Entities:create_move_block(level, cfg)
	---@type EntityGame
	local e = {}
	e.move_block = cfg
	e.path_movement = {
		cell_idx = 1,
		pause_time = 0,
		targets = {}
	}
	for _, cell in ipairs(cfg.path) do
		table.insert(e.path_movement.targets, self:cell_to_pos(level, cell.x, cell.y))
	end
	e.position = vmath.vector3(e.path_movement.targets[1])

	local urls = collectionfactory.create(FACTORY_URL_BLOCK_MOVE, e.position)
	local cell_go = {
		root = msg.url(assert(urls[PARTS.ROOT])),
		block = msg.url(urls[PARTS.BLOCK]),
	}
	if cell_go.block then
		local spawn_dy = level.spawn_cell.y - cfg.path[1].y
		local spawn_dx = level.spawn_cell.x - cfg.path[1].x
		local scale = go.get_scale(cell_go.block)
		go.set_scale(vmath.vector3(0.001), cell_go.block)
		local distance = math.sqrt(spawn_dy * spawn_dy + spawn_dx * spawn_dx)
		go.animate(cell_go.block, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTQUAD, 0.2, (distance) * 0.1)
	end
	e.cell_go = cell_go
	e.cell_go.collision = COMMON.LUME.url_component_from_url(e.cell_go.root, "collision")
	e.physics_linear_velocity = vmath.vector3()
	e.physics_object = game.physics_object_create(e.cell_go.root, e.cell_go.collision, e.position, e.physics_linear_velocity)
	e.mass = go.get(e.cell_go.collision, COMMON.HASHES.MASS)

	return e
end

function Entities:cell_to_pos(level, x, y)
	return vmath.vector3(x * level.cell_size.w - level.cell_size.w / 2, 0, y * level.cell_size.h - level.cell_size.h / 2)
end

function Entities:create_level_cells(level)
	---@type EntityGame
	local e = {}

	e.level_cells = {
		level = level,
		map = {},
	}

	local map = e.level_cells.map
	for y = 1, level.size.h do
		map[y] = {}
		local spawn_dy = level.spawn_cell.y - y
		for x = 1, level.size.w do
			map[y][x] = { cell = e.level_cells.level.map[y][x], x = x, y = y }
			local spawn_dx = level.spawn_cell.x - x
			if (map[y][x].cell.type ~= ENUMS.CELL_TYPE.EMPTY) then
				local urls = collectionfactory.create(CELL_FACTORIES[map[y][x].cell.type], vmath.vector3(x * level.cell_size.w - level.cell_size.w / 2, 0, y * level.cell_size.h - level.cell_size.h / 2))
				local cell_go = {
					root = msg.url(assert(urls[PARTS.ROOT])),
					block = msg.url(urls[PARTS.BLOCK]),
				}
				if cell_go.block then
					local scale = go.get_scale(cell_go.block)
					go.set_scale(vmath.vector3(0.001), cell_go.block)
					local distance = math.sqrt(spawn_dy * spawn_dy + spawn_dx * spawn_dx)
					go.animate(cell_go.block, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTQUAD, 0.2, (distance) * 0.1)
				end
				map[y][x].cell_go = cell_go

				--map[y][x].collision = COMMON.LUME.url_component_from_url(map[y][x].root, "collision")
			end
		end
	end

	return e
end



--endregion

return Entities




