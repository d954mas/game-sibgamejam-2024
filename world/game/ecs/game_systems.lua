local M = {}

--ecs systems created in require.
--so do not cache then

-- luacheck: push ignore require

local require_old = require
local require_no_cache
local require_no_cache_name
require_no_cache = function(k)
	require = require_old
	local m = require_old(k)
	if (k == require_no_cache_name) then
		--        print("load require no_cache_name:" .. k)
		package.loaded[k] = nil
	end
	require_no_cache_name = nil
	require = require_no_cache
	return m
end

local creator = function(name)
	return function(...)
		require_no_cache_name = name
		local system = require_no_cache(name)
		if (system.init) then system.init(system, ...) end
		return system
	end
end

require = creator

--M.ActionsUpdateSystem = require "world.game.ecs.systems.actions_update_system"
M.AutoDestroySystem = require "world.game.ecs.systems.auto_destroy_system"
M.InputSystem = require "world.game.ecs.systems.input_system"

M.PhysicsUpdateVariablesSystem = require "world.game.ecs.systems.physics_update_variables"
M.PhysicsUpdateLinearVelocitySystem = require "world.game.ecs.systems.physics_update_linear_velocity"
M.UpdateDistanceToPlayerSystem = require "world.game.ecs.systems.update_distance_to_player_system"
M.UpdateFrustumBoxSystem = require "world.game.ecs.systems.update_frustum_box"
M.TutorialSystem = require "world.game.ecs.systems.tutorial_system"
M.SkyUpdateSystem = require "world.game.ecs.systems.sky_update_system"

M.PlayerCameraSystem = require "world.game.ecs.systems.player_camera_system"
M.PlayerMoveSystem = require "world.game.ecs.systems.player_move_system"
M.PlayerGroundCheckSystem = require "world.game.ecs.systems.player_ground_check_system"
M.FallSystem = require "world.game.ecs.systems.fall_system"
M.PlayerAutoJumpSystem = require "world.game.ecs.systems.player_auto_jump_system"
M.PlayerCheckCellSystem = require "world.game.ecs.systems.player_check_cell_system"


M.DrawPlayerSystem = require "world.game.ecs.systems.draw_player_system"



--#IF DEBUG

--#ENDIF


require = require_old

-- luacheck: pop

return M