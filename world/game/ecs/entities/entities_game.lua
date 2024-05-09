local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"
local SmoothDumpV3 = require "libs.smooth_dump_v3"

local TABLE_REMOVE = table.remove
local TABLE_INSERT = table.insert

local FACTORY_URL_PLAYER = msg.url("game_scene:/factory#player")
local FACTORY_URL_ENEMY = msg.url("game_scene:/factory#enemy")

local CELL_FACTORIES = {
	[ENUMS.CELL_TYPE.BLOCK_STATIC] = msg.url("game_scene:/factory#cell_block_static"),
	[ENUMS.CELL_TYPE.BLOCK] = msg.url("game_scene:/factory#cell_block"),
	[ENUMS.CELL_TYPE.BLOCK_FAKE] = msg.url("game_scene:/factory#block_fake"),
	[ENUMS.CELL_TYPE.EMPTY] = nil,
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
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
end



--region ecs callbacks
---@param e EntityGame
function Entities:on_entity_removed(e)
	e._in_world = false
	if (e.input_info) then
		TABLE_INSERT(self.pool_input, e)
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
		max_speed_limit = 1, --[0,1] for virtual pad to make movement more easy
		accel = 8 * 0.016,
		deaccel = 15 * 0.016,
		deaccel_stop = 0.5,
		strafe_power = 1,
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
		},
	}
	e.player_go.collision = COMMON.LUME.url_component_from_url(e.player_go.root, "collision")
	e.physics_linear_velocity = vmath.vector3()
	e.physics_object = game.physics_object_create(e.player_go.root, e.player_go.collision, e.position, e.physics_linear_velocity)

	return e
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
		for x = 1, level.size.w do
			map[y][x] = { cell = e.level_cells.level.map[y][x], x = x, y = y }
			if (map[y][x].cell.type ~= ENUMS.CELL_TYPE.EMPTY) then
				local urls = collectionfactory.create(CELL_FACTORIES[map[y][x].cell.type], vmath.vector3(x*level.cell_size.w-level.cell_size.w/2, 0, -y*level.cell_size.h-level.cell_size.h/2))
				map[y][x].root = msg.url(assert(urls[PARTS.ROOT]))
				--map[y][x].collision = COMMON.LUME.url_component_from_url(map[y][x].root, "collision")
			end
		end
	end

	return e
end



--endregion

return Entities




