local ECS = require 'libs.ecs'
local ENUMS = require "world.enums.enums"
local COMMON = require "libs.common"

---@class PlayerCheckCellSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player")
System.name = "PlayerAutojumpSystem"

function System:init()
	self.cell = nil
end

---@param e EntityGame
function System:update(dt)
	local entities = self.entities
	local time = self.world.game_world.game.state.time
	for i = 1, #entities do
		local e = entities[i]
		local cell, cell_x, cell_y = nil
		local last_jump_time = time - e.jump_last_time
		if not self.cell and e.position.y < 0.03 and not e.on_ground and e.physics_linear_velocity.y<=0.001 and last_jump_time>1/60 then
			cell, cell_x, cell_y = self.world.game_world.game.level_creator:get_cell(e.position.x, e.position.z)
		end
		if self.cell ~= cell then
			self.cell = cell
			local map_e = self.world.game_world.game.level_creator.level_cells.level_cells.map
			if self.cell then
				print("Cell changed to:" .. tostring(cell.type), "x:" .. cell_x, "y:" .. cell_y)
				if self.cell.type == ENUMS.CELL_TYPE.BLOCK_FAKE then
					local cell_e = map_e[cell_y][cell_x]
					if not cell_e.visited then
						cell_e.visited = true
						msg.post(cell_e.cell_go.block, COMMON.HASHES.MSG.DISABLE)
					end
				end
			else
				print("no cell")
			end
		end
	end
end

return System