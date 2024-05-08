local COMMON = require "libs.common"
local ECS = require 'libs.ecs'
local ENUMS = require 'world.enums.enums'
local DEFS = require "world.balance.def.defs"
local GAME_MESH_READER = require "def-mesh.game_mesh_reader"
local LIVEUPDATE = require "libs_project.liveupdate"
local MeshAnimator = require "def-mesh.mesh_animator"

local TEMP_Q = vmath.quat()

local GO_SET_ROTATION = go.set_rotation

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MESH = COMMON.HASHES.hash("/mesh"),
	MODEL = COMMON.HASHES.hash("/model"),
	ORIGIN = COMMON.HASHES.hash("/origin"),
}

local V_LOOK_DIR = vmath.vector3(0, 0, -1)

local TEMP_V = vmath.vector3()

local Q_ROTATION = vmath.quat_rotation_z(0)

local BASE_NO_BLEND_ONCE = { }
local BASE_BLEND_LOOP = { blend_duration = 0.1, loops = -1 }
local BASE_BLEND_ONCE = { blend_duration = 0.1, loops = 1 }
local LONG_BLEND_LOOP = { blend_duration = 0.5, loops = -1 }
local BASE_BLEND_DIE = { blend_duration = 0.1, loops = 1, playback_rate = 2 }
local BASE_LOOP = { loops = -1 }

---@class DrawPlayerSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("player")
System.name = "PlayerDrawSystem"

---@param e EntityGame
function System:get_animation(e)
	if (e.die) then
		return ENUMS.ANIMATIONS.DIE
	end
	if (e.moving) then
		return ENUMS.ANIMATIONS.RUN
	end
	return ENUMS.ANIMATIONS.IDLE
end


function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if (e.skin ~= e.player_go.config.skin) then
			local skin_def = assert(DEFS.SKINS.SKINS_BY_ID[e.skin])
			if skin_def.liveupdate then
				if not LIVEUPDATE.is_ready() then
					skin_def = DEFS.SKINS.SKINS_BY_ID.UNKNOWN
				end
			end
			if e.player_go.config.skin ~= skin_def.id then
				e.player_go.config.skin = skin_def.id
				e.player_go.config.animation = nil
				--DELETE PREV SKIN
				if (e.player_go.model.root) then
					go.delete(e.player_go.model.root, true)
					e.player_go.model.root = nil
					e.player_go.model.mesh_root = nil
					e.player_go.gloves.left.root = nil
					e.player_go.gloves.right.root = nil

					if e.player_go.model.mesh then
						e.player_go.model.mesh:dispose()
						e.player_go.model.mesh = nil
					end
					e.player_go.model.mesh_animator = nil
					e.player_go.config.gloves = nil
				end
			end
		end

		if (e.player_go.model.root == nil) then
			local skin_def = assert(DEFS.SKINS.SKINS_BY_ID[e.player_go.config.skin])
			pprint(skin_def.factory)
			local urls = collectionfactory.create(skin_def.factory, nil, nil, nil,
					skin_def.scale)
			local go_url = msg.url(urls[PARTS.ROOT])
			local mesh_url = msg.url(urls[PARTS.MESH])
			local mesh_origin = msg.url(urls[PARTS.ORIGIN])
			local mesh_comp_url = COMMON.LUME.url_component_from_url(mesh_origin, COMMON.HASHES.MESH)
			go.set_parent(go_url, e.player_go.root, false)
			e.player_go.model.root = go_url
			e.player_go.model.mesh_root = mesh_url
			e.player_go.model.mesh_origin = mesh_origin
			e.player_go.model.mesh = GAME_MESH_READER.get_mesh(skin_def.mesh)
			e.player_go.model.mesh:set_mesh_component(mesh_comp_url)
			e.player_go.model.mesh_animator = MeshAnimator(e.player_go.model.mesh)
			e.player_go.model.mesh.tracks[2].bone_weights = DEFS.ANIMATIONS.BONES_WEIGHS.ARM_ATTACK
			e.player_go.model.mesh.tracks[2].enabled = true
		end

		local anim = self:get_animation(e)
		local skin_def = DEFS.SKINS.SKINS_BY_ID[e.skin]
		local animations = skin_def.animations
		local prev = e.player_go.config.animation

		if (e.player_go.config.animation ~= anim) then

			e.player_go.config.animation = anim
			if (anim == ENUMS.ANIMATIONS.IDLE) then
				e.player_go.model.mesh_animator:play(animations.IDLE[1].id, prev == ENUMS.ANIMATIONS.DIE and LONG_BLEND_LOOP or BASE_BLEND_LOOP)
			elseif (anim == ENUMS.ANIMATIONS.RUN) then
				e.player_go.model.mesh_animator:play(animations.RUN[1].id, prev == ENUMS.ANIMATIONS.DIE and LONG_BLEND_LOOP or BASE_BLEND_LOOP)
			elseif (anim == ENUMS.ANIMATIONS.DIE) then
				e.player_go.model.mesh_animator:play(animations.DIE[1].id, BASE_BLEND_DIE)
			end
		end


		--for ghost fly mode
		--GO_SET_POSITION(e.position, e.player_go.root)
		V_LOOK_DIR.x, V_LOOK_DIR.y, V_LOOK_DIR.z = e.look_dir.x, 0, e.look_dir.z
		xmath.normalize(V_LOOK_DIR, V_LOOK_DIR)

		e.player_go.config.look_dir_smooth_dump:update(e.player_go.config.look_dir, V_LOOK_DIR, dt)

		local angle = COMMON.LUME.angle_vector(e.player_go.config.look_dir.x, -e.player_go.config.look_dir.z) - math.pi / 2
		xmath.quat_rotation_y(Q_ROTATION, angle)

		GO_SET_ROTATION(Q_ROTATION, e.player_go.model.root)
		e.player_go.model.mesh_animator:update(dt)
	end
end


return System