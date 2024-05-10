local ANIM = require "world.balance.def.animations"
local ENUMS = require "world.enums.enums"

local M = {}

M.SKINS_BY_ID = {}

M.SKINS_BY_ID.UNKNOWN = {
	mesh = "char_base",
	factory = msg.url("game_scene:/factory#char_unknown"),
	scale = vmath.vector3(1),
	hp_bar_pos = vmath.vector3(0, 2.1, 0),
	icon = hash("char_unknown"),
	animations = {
		IDLE = { ANIM.BY_ID.IDLE },
		IDLE_LONG = { ANIM.BY_ID.LOOK_AROUND },
		RUN = { ANIM.BY_ID.RUN_BASE },
		PUNCH = { ANIM.BY_ID.PUNCH },
		DIE = { ANIM.BY_ID.DIE },
		LOOK_AROUND = { ANIM.BY_ID.LOOK_AROUND },
	}
}

M.SKINS_BY_ID.BOXER = {
	mesh = "char_base",
	factory = msg.url("game_scene:/factory#char_boxer"),
	scale = vmath.vector3(1),
	hp_bar_pos = vmath.vector3(0, 2.1, 0),
	icon = hash("char_boxer"),
	animations = {
		IDLE = { ANIM.BY_ID.IDLE },
		IDLE_LONG = { ANIM.BY_ID.LOOK_AROUND },
		RUN = { ANIM.BY_ID.RUN_BASE },
		PUNCH = { ANIM.BY_ID.PUNCH },
		DIE = { ANIM.BY_ID.DIE },
		LOOK_AROUND = { ANIM.BY_ID.LOOK_AROUND },
	}
}

M.SKINS_BY_ID.CHILD = {
	mesh = "char_base",
	factory = msg.url("game_scene:/factory#char_boxer"),
	scale = vmath.vector3(0.5),
	hp_bar_pos = vmath.vector3(0, 2.1, 0),
	icon = hash("char_boxer"),
	animations = {
		IDLE = { ANIM.BY_ID.IDLE },
		IDLE_LONG = { ANIM.BY_ID.LOOK_AROUND },
		RUN = { ANIM.BY_ID.RUN_BASE },
		PUNCH = { ANIM.BY_ID.PUNCH },
		DIE = { ANIM.BY_ID.DIE },
		LOOK_AROUND = { ANIM.BY_ID.LOOK_AROUND },
	}
}

M.LIVEUPDATE = {

}

--[[
mesh = "char_base",
factory = msg.url("game_scene:/factory#char_cyborg"),
factory_gui = msg.url("game_scene:/factory#char_cyborg_gui"),
scale = vmath.vector3(1),
hp_bar_pos = vmath.vector3(0, 2.1, 0),
icon = hash("icon_skin_default"),
animations = {
IDLE = { ANIM.BY_ID.IDLE_BASE },
RUN = { ANIM.BY_ID.RUN_BASE },
PUNCH = { ANIM.BY_ID.PUNCH },
DIE = { ANIM.BY_ID.DIE },
LOOK_AROUND = { ANIM.BY_ID.LOOK_AROUND },
}--]]

for k, v in ipairs(M.LIVEUPDATE) do
	v.liveupdate = true
end

for k, v in pairs(M.SKINS_BY_ID) do
	v.id = k
	local lower_case = string.lower(v.id)
	v.mesh = v.mesh or "char_base"
	v.factory = v.factory or msg.url("game_scene:/" .. (v.liveupdate and "factory_liveupdate" or "factory") .. "#char_" .. lower_case)
	v.scale = v.scale or vmath.vector3(1)
	v.hp_bar_pos = v.hp_bar_pos or vmath.vector3(0, 2.05, 0)
	v.icon = v.icon or hash("char_" .. lower_case)
	v.animations = v.animations or {
		IDLE = { ANIM.BY_ID.LOOK_AROUND },
		RUN = { ANIM.BY_ID.RUN_BASE },
		PUNCH = { ANIM.BY_ID.PUNCH },
		DIE = { ANIM.BY_ID.DIE },
		LOOK_AROUND = { ANIM.BY_ID.LOOK_AROUND },
	}
end

return M