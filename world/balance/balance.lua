local COMMON = require "libs.common"

---@class Balance
local Balance = COMMON.class("Balance")

---@param world World
function Balance:initialize(world)
	self.world = world
	self.config = {
		far_z_base = 150,
		far_z_small = 50,
		far_z_shadow = 15,
		hit_distance_far = 1.75,
		hit_distance_near = 1.25,

		--Минимальную награду увеличиваем, чтобы был стимул кликать на рекламу даже если пропустил 5 минут.
		offline_income = {
			rewards = {
				{
					time = 300,
					reward = 0.25
				},
				{
					time = 3600,
					reward = 1,
				},
				{
					time = 3600 * 4,
					reward = 1.25,
				},
				{
					time = 3600 * 12,
					reward = 1.5,
				}
			},
		},

		offer = {
			live_time = 10,
			offer_delta = {
				[0] = 90, -- base delay
				[1] = 30, --first offer
				[2] = 45, --first offer
				[3] = 60,
				[4] = 70,
				[5] = 80,
				[6] = 85,
				[7] = 90,
			},
		},
	}
end

return Balance