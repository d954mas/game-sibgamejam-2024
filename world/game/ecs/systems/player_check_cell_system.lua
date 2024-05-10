local ECS = require 'libs.ecs'
local ENUMS = require "world.enums.enums"
local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"

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
	local level = self.world.game_world.game.level_creator.location.level
	for i = 1, #entities do
		local e = entities[i]
		local cell, cell_x, cell_y = nil
		local last_jump_time = time - e.jump_last_time
		if ((e.position.y < 0.05 and e.physics_linear_velocity.y <= 0.05) or e.on_ground) and last_jump_time > 1 / 60 then
			cell, cell_x, cell_y = self.world.game_world.game.level_creator:get_cell(e.position.x, e.position.z)
		end
		if cell then
			local dx = e.position.x - (cell_x * level.cell_size.w - level.cell_size.w / 2)
			local dy = e.position.z - (cell_y * level.cell_size.h - level.cell_size.h / 2)
			if math.abs(dx) > 0.90 * level.cell_size.w or math.abs(dy) > 0.90 * level.cell_size.h then
				cell, cell_x, cell_y = nil, nil, nil
			end
		end

		if cell and not e.on_ground and cell.type ~= ENUMS.CELL_TYPE.BLOCK_FAKE then
			cell, cell_x, cell_y = nil, nil, nil
		end
		if self.cell ~= cell then
			self.cell = cell
			local map_e = self.world.game_world.game.level_creator.level_cells.level_cells.map
			if self.cell then
				local cell_e = map_e[cell_y][cell_x]
				print("Cell changed to:" .. tostring(cell.type), "x:" .. cell_x, "y:" .. cell_y)
				if self.cell.type == ENUMS.CELL_TYPE.BLOCK_FAKE then
					if not cell_e.visited then
						cell_e.visited = true
						msg.post(cell_e.cell_go.block, COMMON.HASHES.MSG.DISABLE)
					end
				elseif self.cell.type == ENUMS.CELL_TYPE.BLOCK_LEVEL then
					self.world.game_world.game:load_location(DEFS.LOCATIONS.BY_ID.ZONE_1.id, DEFS.LEVELS.LEVELS_LIST[cell_e.cell.level])
				elseif self.cell.type == ENUMS.CELL_TYPE.EXIT and not self.world.game_world.game.state.completed then
					self.world.game_world.game.state.completed = true
					local level_idx = self.world.game_world.game.level_creator.location.level.id
					self.world.game_world.game.actions:add_action(function()
						COMMON.INPUT.IGNORE = true
						local player = self.world.game_world.game.level_creator.player
						msg.post(assert(player.player_go.collision), COMMON.HASHES.MSG.DISABLE)

						self.world.game_world.storage.levels:level_completed(level_idx, 0, 0)
						COMMON.coroutine_wait(0.5)
						while (self.world.game_world.sm:is_working() or
								self.world.game_world.sm:get_top()._name ~= self.world.game_world.sm.SCENES.GAME) do
							coroutine.yield()
						end
						COMMON.INPUT.IGNORE = false
						self.world.game_world.sm:show(self.world.game_world.sm.MODALS.COMPLETED)
					end)
				end

			else
				print("no cell")
			end
		end
	end
end

return System