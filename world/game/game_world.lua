local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ACTIONS = require "libs.actions.actions"
local ENUMS = require "world.enums.enums"
local LIVEUPDATE = require "libs_project.liveupdate"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"
local EcsGame = require "world.game.ecs.game_ecs"
local Lights = require "illumination.illumination"
local LevelCreator = require "world.game.level_creator"

---@class GameWorld
local GameWorld = COMMON.class("GameWorld")

---@param world World
function GameWorld:initialize(world)
	self.world = assert(world)
	self.ecs_game = EcsGame(self.world)
	self.lights = Lights(self)
	self:reset_state()
end

function GameWorld:reset_state()
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
	self.state = {
		time = 0,
		time_location = 0,
		first_move = false,
		completed = false,
	}
	self.offer = {
		idx = 1, resource = nil, value = nil, prev_offer_time = 0
	}
	self.lights:dispose()
	self.lights:reset()
end

function GameWorld:load_location(location_id, level_id)
	print("LOAD LOCATION:" .. location_id)
	print("LOAD LEVEL:" .. level_id)
	local time = chronos.nanotime()
	local location_def = DEFS.LOCATIONS.BY_ID[location_id]
	if location_def.liveupdate and not LIVEUPDATE.is_ready() then
		COMMON.e("can't load location. Wait for liveupdate to be ready")
		return
	end

	local ctx = COMMON.CONTEXT:set_context_top_game()
	self.ecs_game.ecs:clear()
	self.state.time_location = 0
	self.state.completed = false
	if self.level_creator then
		self.level_creator:unload_location()
	end

	self.level_creator = LevelCreator(self.world)
	self.level_creator:create_location(location_id, level_id)

	self.level_creator:create_player(self.level_creator.player_spawn_position)

	self.ecs_game:add_systems()
	self.ecs_game:refresh()

	self.ecs_game:update(0)
	--fixed first frame T-pose
	self.ecs_game:update(1 / 60)
	self.ecs_game:update(1 / 60)

	ctx:remove()

	self.lights:reset_shadows()

	--fixed blink after loading before game
	if (html_utils) then
		timer.delay(0, false, function()
			html_utils.hide_bg()
		end)
	end
	print("LOAD LOCATION TIME:" .. (chronos.nanotime() - time))
end

function GameWorld:game_loaded()
	self:liveupdate_ready()
	local def = DEFS.LOCATIONS.BY_ID[DEFS.LOCATIONS.BY_ID.ZONE_1.id]
	local level_def = DEFS.LEVELS.BY_ID[self.world.storage.levels:levels_get_last_opened()]
	if def.liveupdate and not LIVEUPDATE.is_ready() then
		self.actions:add_action(function()
			while (not LIVEUPDATE.is_ready()) do coroutine.yield() end
			self:load_location(def.id, level_def.id)
		end)
	else
		self:load_location(def.id, level_def.id)
	end
	if html_utils then
		html_utils.focus()
	end
	--call gc while loading bg is still on screen
	collectgarbage("collect")
end

function GameWorld:update(dt)
	self.ecs_game:update(dt)
	self.world.storage.timers:update(dt)
	self.world.storage.powerups:update(dt)
	self.state.time = self.state.time + dt
	self.state.time_location = self.state.time_location + dt
	if (self.actions) then self.actions:update(dt) end

end

function GameWorld:final()
	self:reset_state()
	self.ecs_game:clear()
end

function GameWorld:on_input(action_id, action)
	if (action_id == COMMON.HASHES.INPUT.ESCAPE and action.pressed) then
		self.world.sm:show(self.world.sm.MODALS.SETTINGS)
		return true
	end
end

function GameWorld:offer_get_value(resource)
	local max_value = 100
	return max_value
end

function GameWorld:generate_offer()
	assert(not self.offer.resource)
	local resource = DEFS.RESOURCES.GOLD.id
	local max_value = self:offer_get_value(resource)

	self.offer.resource = resource
	self.offer.value = max_value
	self.offer.prev_offer_time = self.world.game.state.time
end

function GameWorld:offer_remove()
	self.offer.idx = self.offer.idx + 1
	self.offer.resource = nil
	self.offer.value = nil
	self.offer.prev_offer_time = self.world.game.state.time
end

function GameWorld:take_offer()
	assert(self.offer)
	--self.offer can be removed if used when time is over
	local offer = COMMON.LUME.clone_shallow(self.offer)
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	ctx.data.views.virtual_pad:reset()
	ctx:remove()
	self.world.sdk:ads_rewarded(function(success)
		if (success) then
			self.world.storage.resources:add(offer.resource, offer.value, ENUMS.RESOURCE_ADD_PLACEMENT.GAME_OFFER)
			self:offer_remove()
		end
	end, "offer_" .. offer.resource)
end

local HASH_LIVEUPDATE_SOCKET = hash("liveupdate_proxy")
local HASH_PROTOTYPE = hash("prototype")
local FACTORY_LU = msg.url(HASH_LIVEUPDATE_SOCKET, nil, nil)
local PROTOTYPE_FROM_HASH = {

}

local OTHER_URLS = {

}

local function prototype_set(factory_url)
	FACTORY_LU.path = factory_url.path
	FACTORY_LU.fragment = factory_url.fragment
	local ctx = COMMON.CONTEXT:set_context_top_liveupdate_collection()
	local prototype = go.get(FACTORY_LU, HASH_PROTOTYPE)
	ctx:remove()
	local result = PROTOTYPE_FROM_HASH[prototype]
	if not result then
		COMMON.w("no prototype from hash:" .. prototype)
	else
		collectionfactory.set_prototype(factory_url, result)
	end
end

function GameWorld:liveupdate_ready()
	print("liveupdate_ready")
	print("game", COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME), "liveupdate", COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.LIVEUPDATE_COLLECTION))
	if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME) and COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.LIVEUPDATE_COLLECTION) then
		local ctx = COMMON.CONTEXT:set_context_top_game()
		for _, url in ipairs(OTHER_URLS) do
			prototype_set(url)
		end
		ctx:remove()
	end
end

function GameWorld:generate_daily_tasks()
	local result = {
		{ type = ENUMS.DAILY_TASK_TYPE.TIME_TO_PLAY, state = ENUMS.DAILY_TASK_STATE.IN_PROGRESS, value = 0, need = 60 * 25 }
	}

	return result
end

---@param e EntityGame
function GameWorld:teleport(e, position, cb)
	local obj = e.player and e.player_go or e.enemy_go

	msg.post(assert(obj.collision), COMMON.HASHES.MSG.DISABLE)
	coroutine.yield()

	go.set(assert(obj.collision), COMMON.HASHES.hash("linear_velocity"), vmath.vector3(0, 0, 0))
	go.set_position(position, assert(obj.root))
	msg.post(obj.collision, COMMON.HASHES.MSG.ENABLE)
	coroutine.yield()
	if cb then cb() end

end

---@param e EntityGame
function GameWorld:die(e)
	assert(e.player or e.enemy)
	if not e.die then
		e.die = true
		COMMON.INPUT.IGNORE = true
		self.actions:add_action(function()
			self.world.sounds:play_sound(self.world.sounds.sounds.lose)
			COMMON.coroutine_wait(e.position.y < -6 and 0.5 or 2.5)
			while (self.world.sm:is_working() or self.world.sm:get_top()._name ~= self.world.sm.SCENES.GAME) do
				coroutine.yield()
			end
			go.set_scale(vmath.vector3(0.01),e.player_go.model.root)
			self:teleport(e, self.level_creator.player_spawn_position, function()
				e.die = false
				e.moving = false
				COMMON.INPUT.IGNORE = false
				e.player_go.config.spawn_animation = true
			end)
		end)
	end
end

function GameWorld:player_jump()
	local player = self.level_creator.player
	if (player.die) then return end
	player.movement.pressed_jump = true
end

return GameWorld



