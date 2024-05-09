local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"

---@class LevelCreator
local Creator = COMMON.class("LevelCreator")

---@param world World
function Creator:initialize(world)
	self.world = world
	self.ecs = world.game.ecs_game
	self.entities = world.game.ecs_game.entities
	self.location = {
		id = nil,
		def = nil,
		level_url = nil,
		physics_url = nil,
		urls = nil
	}
end

function Creator:unload_location()
	if self.location.id then
		self.location.id = nil
		self.location.def = nil
		self.location.urls = nil

		if self.location.level_url then
			go.delete(self.location.level_url, true)
			self.location.level_url = nil
		end
		go.delete(self.location.physics_url, true)
		go.delete(self.location.other_url, true)

		self.location.physics_url = nil
		self.location.other_url = nil
		self.location.level = nil
	end
end

function Creator:level_fill_row(level, row, type)
	for i = 1, level.size.w do
		level.map[row][i].type = type
	end
end

function Creator:level_fill_column(level, column, type)
	for i = 1, level.size.h do
		level.map[i][column].type = type
	end
end

function Creator:level_set_cell(level, x, y, type)
	assert(x >= 1 and x <= level.size.w)
	assert(y >= 1 and y <= level.size.h)
	level.map[y][x].type = type
end

function Creator:create_level()
	self.player_spawn_position = nil
	local level_cells = {
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",--5
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",
		"0000000000B0000000000",
		"0000000000B0000000000",--10
		"00000000BBPFB00000000",--center
		"0000000000B0000000000",--12
		"0000000000B0000000000",
		"000000000000000000000",
		"000000000000000000000",--15
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",
		"000000000000000000000",--20
		"000000000000000000000",
	}

	local level = {
		size = { w = 0, h = 0 },
		cell_size = {w =4, h = 4},
		map = {

		}
	}

	level.size.h =  #level_cells
	level.size.w =  string.len(level_cells[1])
	for y = 1, level.size.h do
		level.map[y] = {}
		for x = 1, level.size.w do
			level.map[y][x] = { type = ENUMS.CELL_TYPE.EMPTY }
		end
	end

	for y = 1, #level_cells do
		local row = level_cells[y]
		assert(string.len(row) == level.size.w, "Row " .. y .. " size is not equal to first row size")
		for x=1, level.size.w do
			local cell = string.sub(row, x, x)
			if cell == "0" then
				--pass
			elseif cell == "P" then
				self.player_spawn_position = vmath.vector3(x*level.cell_size.w-level.cell_size.w/2, 0.1, -y*level.cell_size.h-level.cell_size.h/2)
				level.map[y][x] = { type = ENUMS.CELL_TYPE.BLOCK_STATIC }
			elseif cell == "B" then
				level.map[y][x] = { type = ENUMS.CELL_TYPE.BLOCK }
			elseif cell == "F" then
				level.map[y][x] = { type = ENUMS.CELL_TYPE.BLOCK_FAKE }
			elseif cell == "S" then
				level.map[y][x] = { type = ENUMS.CELL_TYPE.BLOCK_STATIC }
			end
		end
	end
	assert(self.player_spawn_position)
	return level
end

function Creator:create_location(location_id)
	self:unload_location()
	self.location.id = location_id
	self.location.def = assert(DEFS.LOCATIONS.BY_ID[location_id])

	self.location.urls = collectionfactory.create(self.location.def.factory)
	self.location.level_url = self.location.urls[hash("/location/__root")]
	self.location.physics_url = assert(self.location.urls[hash("/collisions")])
	self.location.other_url = assert(self.location.urls[hash("/other")])

	self.location.level = self:create_level()
	self:load_level()

	for _, object in ipairs(self.location.def.objects) do

	end


end

function Creator:load_level()
	self.level_cells = self.entities:create_level_cells(assert(self.location.level))
	self.ecs:add_entity(self.level_cells)
end

function Creator:create_player(position)
	self.player = self.entities:create_player(position)
	self.ecs:add_entity(self.player)

	self.player.camera.config_portrait = self.location.def.camera.config_portrait
	self.player.camera.config = self.location.def.camera.config
	self.player.movement.type = self.location.def.player_movement
end

return Creator