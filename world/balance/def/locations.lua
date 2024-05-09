local ENUMS = require "world.enums.enums"

local M = {}

local CAMERA_HUB = {
	config = {
		position = vmath.rotate(vmath.quat_rotation_x(math.rad(-55)), vmath.vector3(0, 0, 1)) * 6,
		pitch = { value = math.rad(-40) },
		fov = math.rad(60),
		yaw = { value = math.rad(-90)
		}
	},
	config_portrait = {
		position = vmath.rotate(vmath.quat_rotation_x(math.rad(-66)), vmath.vector3(0, 0, 1)) * 4.5,
		pitch = { value = math.rad(-50) },
		fov = math.rad(95),
		yaw = { value = math.rad(-90) }
	},
}

M.BY_ID = {
	ZONE_1 = {
		id = "ZONE_1",
		factory = msg.url("game_scene:/factory#location_zone_1"),
		player_spawn_position = vmath.vector3(11*4-4/2, 0.1, -11*4-4/2),
		objects = {},
		camera = CAMERA_HUB,
		player_movement = ENUMS.PLAYER_MOVEMENT.FIXED_CAMERA,

	},

	ZONE_2 = {
		id = "ZONE_2",
		factory = msg.url("game_scene:/factory#location_zone_1"),
		player_spawn_position = vmath.vector3(0, 1.1, 0),
		objects = {},
		liveupdate = true,
		camera = CAMERA_HUB,
		player_movement = ENUMS.PLAYER_MOVEMENT.FIXED_CAMERA,
	}
}

for k, v in pairs(M.BY_ID) do
	v.id = k
end

return M