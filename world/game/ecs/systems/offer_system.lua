local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

local OFFER_LIVE_TIME = 10

---@class OfferSystem:ECSSystem
local System = ECS.system()
System.name = "OfferSystem"

function System:init()

end

function System:onAddToWorld()

end

function System:onRemoveFromWorld()
	if (self.offer_view) then
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		self.offer_view:dispose()
		ctx.data.offer = nil
		ctx:remove()
		self.offer_view = nil
	end
end

---@param e EntityGame
function System:update(dt)
	if not COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME_GUI) then return end
	local top_scene = self.world.game_world.sm:get_top()
	if not top_scene or top_scene._name ~= self.world.game_world.sm.SCENES.GAME then return end
	local offer = self.world.game_world.game.offer
	if (false) then
		offer.prev_offer_time = self.world.game_world.game.state.time
	end
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	if not self.world.game_world.game.offer.resource then
		if (self.offer_view) then
			self.offer_view:dispose()
			self.offer_view = nil
		end

		local delta = self.world.game_world.game.state.time - offer.prev_offer_time
		local offer_delta = self.world.game_world.balance.config.offer.offer_delta[offer.idx]
				or self.world.game_world.balance.config.offer.offer_delta[0]

		if (delta > offer_delta) then
			self.world.game_world.game:generate_offer()
			self.offer_remove_time = OFFER_LIVE_TIME
		end
	end

	if self.world.game_world.game.offer.resource and not self.offer_view then
		self.offer_view = ctx.data:create_offer()
		self.offer_view:set_resource(offer.resource)
		self.offer_view:set_value(offer.value)
		self.offer_view:set_time_max(OFFER_LIVE_TIME)
		self.offer_view:set_time(OFFER_LIVE_TIME, true)
	end
	if (self.offer_view) then
		if not self.offer_remove_time then
			self.offer_remove_time = OFFER_LIVE_TIME
		end
		self.offer_view:set_time(self.offer_remove_time)

		self.offer_remove_time = self.offer_remove_time - dt

		if (self.offer_remove_time <= 0) then
			self.offer_view:dispose()
			self.offer_view = nil
			self.world.game_world.game:offer_remove()
			self.offer_remove_time = OFFER_LIVE_TIME
		end
	end
	ctx:remove()
end

return System