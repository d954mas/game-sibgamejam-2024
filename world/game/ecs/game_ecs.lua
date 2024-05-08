local COMMON = require "libs.common"
local ECS = require "libs.ecs"
local SYSTEMS = require "world.game.ecs.game_systems"
local Entities = require "world.game.ecs.entities.entities_game"

---@class GameEcsWorld
local EcsWorld = COMMON.class("EcsWorld")

---@param world World
function EcsWorld:initialize(world)
	self.world = assert(world)

	self.ecs = ECS.world()
	self.ecs.game = self
	self.ecs.game_world = self.world

	self.entities = Entities(world)
	self.ecs.on_entity_added = function(_, ...) self.entities:on_entity_added(...) end
	self.ecs.on_entity_removed = function(_, ...) self.entities:on_entity_removed(...) end

	self.performance = {
		time = { current = 0, max = 0, average = 0, average_count = 0, average_value = 0 }
	}
end

function EcsWorld:add_systems()
	self.ecs:addSystem(SYSTEMS.InputSystem())
	--self.ecs:addSystem(SYSTEMS.ActionsUpdateSystem())
	self.ecs:addSystem(SYSTEMS.TutorialSystem())
	self.ecs:addSystem(SYSTEMS.PlayerCameraSystem())
	self.ecs:addSystem(SYSTEMS.PhysicsUpdateVariablesSystem())
	self.ecs:addSystem(SYSTEMS.PlayerMoveSystem())
	self.ecs:addSystem(SYSTEMS.UpdateDistanceToPlayerSystem())
	self.ecs:addSystem(SYSTEMS.PhysicsUpdateLinearVelocitySystem())
	self.ecs:addSystem(SYSTEMS.UpdateFrustumBoxSystem())
	self.ecs:addSystem(SYSTEMS.OfferSystem())

	self.ecs:addSystem(SYSTEMS.DrawPlayerSystem())
	self.ecs:addSystem(SYSTEMS.AutoDestroySystem())
end

function EcsWorld:update(dt)
	--if dt will be too big. It can create a lot of objects.
	--big dt can be in htlm when change page and then return
	--or when move game window in Windows.
	local max_dt = 0.1
	if (dt > max_dt) then dt = max_dt end

	--#IF DEBUG
	local time = COMMON.get_time()
	--#ENDIF

	self.ecs:update(dt)
	--remove entities in current frame
	self.ecs:refresh()

	--#IF DEBUG
	self.performance.time.current = COMMON.get_time() - time
	self.performance.time.max = math.max(self.performance.time.max, self.performance.time.current)
	self.performance.time.average = self.performance.time.average + self.performance.time.current
	self.performance.time.average_count = self.performance.time.average_count + 1
	--update once a 5 seconds
	if self.performance.time.average_count >= 300 then
		self.performance.time.average_value = self.performance.time.average / self.performance.time.average_count
		self.performance.time.average = 0
		self.performance.time.average_count = 0
	end
	--#ENDIF
end

function EcsWorld:update_not_top(dt)

end

function EcsWorld:clear()
	self.ecs:clear()
	self.ecs:refresh()
end

function EcsWorld:refresh()
	self.ecs:refresh()
end

function EcsWorld:add_entity(e)
	assert(e)
	self.ecs:addEntity(e)
end

function EcsWorld:remove_entity(e)
	assert(e)
	self.ecs:removeEntity(e)
end

return EcsWorld



