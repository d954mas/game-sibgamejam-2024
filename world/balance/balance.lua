local COMMON = require "libs.common"

---@class Balance
local Balance = COMMON.class("Balance")

---@param world World
function Balance:initialize(world)
	self.world = world
	self.config = {
		far_z_base = 150,
		far_z_small = 50,
		far_z_shadow = 25,
	}
end

return Balance