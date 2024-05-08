local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"

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
	end
end



function Creator:create_location(location_id)
	self:unload_location()
	self.location.id = location_id
	self.location.def = assert(DEFS.LOCATIONS.BY_ID[location_id])

	self.location.urls = collectionfactory.create(self.location.def.factory)
	self.location.level_url = self.location.urls[hash("/location/__root")]
	self.location.physics_url = assert(self.location.urls[hash("/collisions")])
	self.location.other_url = assert(self.location.urls[hash("/other")])


	for _, object in ipairs(self.location.def.objects) do

	end
end

function Creator:create_player(position)
	self.player = self.entities:create_player(position)
	self.ecs:add_entity(self.player)

	self.player.camera.config_portrait = self.location.def.camera.config_portrait
	self.player.camera.config = self.location.def.camera.config
	self.player.movement.type = self.location.def.player_movement
end


return Creator