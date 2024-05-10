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

---@class DrawChildSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("child")
System.name = "DrawChildSystem"

---@param e EntityGame
function System:get_animation(e)
	return ENUMS.ANIMATIONS.IDLE
end

function System:play_idle_animation(e)
	local skin_def = DEFS.SKINS.SKINS_BY_ID[e.skin]
	local animations = skin_def.animations
	if not e.child_go.config.idle_count then
		e.child_go.config.idle_count = 0
	end
	e.child_go.config.idle_count = e.child_go.config.idle_count + 1
	local long_idle = (math.random() > 0.96 or e.child_go.config.idle_count % 3 == 0)
	if long_idle then
		e.child_go.config.idle_count = 0
	end

	local anim = long_idle and animations.IDLE_LONG[1].id or animations.IDLE[1].id

	e.child_go.model.mesh_animator:play(anim, { blend_duration = 0.1, loops = 1 }, function()
		if e.child_go.config.animation == ENUMS.ANIMATIONS.IDLE then
			self:play_idle_animation(e)
		else
			e.child_go.config.idle_count = 0
		end

	end)
end

function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if (e.skin ~= e.child_go.config.skin) then
			local skin_def = assert(DEFS.SKINS.SKINS_BY_ID[e.skin])
			if skin_def.liveupdate then
				if not LIVEUPDATE.is_ready() then
					skin_def = DEFS.SKINS.SKINS_BY_ID.UNKNOWN
				end
			end
			if e.child_go.config.skin ~= skin_def.id then
				e.child_go.config.skin = skin_def.id
				e.child_go.config.animation = nil
				--DELETE PREV SKIN
				if (e.child_go.model.root) then
					go.delete(e.child_go.model.root, true)
					e.child_go.model.root = nil
					e.child_go.model.mesh_root = nil
					e.child_go.gloves.left.root = nil
					e.child_go.gloves.right.root = nil

					if e.child_go.model.mesh then
						e.child_go.model.mesh:dispose()
						e.child_go.model.mesh = nil
					end
					e.child_go.model.mesh_animator = nil
					e.child_go.config.gloves = nil
				end
			end
		end

		if (e.child_go.model.root == nil) then
			local skin_def = assert(DEFS.SKINS.SKINS_BY_ID[e.child_go.config.skin])
			local urls = collectionfactory.create(skin_def.factory, nil, nil, nil,
					skin_def.scale)
			local go_url = msg.url(urls[PARTS.ROOT])
			local mesh_url = msg.url(urls[PARTS.MESH])
			local mesh_origin = msg.url(urls[PARTS.ORIGIN])
			local mesh_comp_url = COMMON.LUME.url_component_from_url(mesh_origin, COMMON.HASHES.MESH)
			go.set_parent(go_url, e.child_go.root, false)
			e.child_go.model.root = go_url
			e.child_go.model.mesh_root = mesh_url
			e.child_go.model.mesh_origin = mesh_origin
			e.child_go.model.mesh = GAME_MESH_READER.get_mesh(skin_def.mesh)
			e.child_go.model.mesh:set_mesh_component(mesh_comp_url)
			e.child_go.model.mesh_animator = MeshAnimator(e.child_go.model.mesh)
			e.child_go.model.mesh.tracks[2].bone_weights = DEFS.ANIMATIONS.BONES_WEIGHS.ARM_ATTACK
			e.child_go.model.mesh.tracks[2].enabled = true
		end

		if e.child_go.config.spawn_animation then
			e.child_go.config.spawn_animation = nil
			go.set_scale(vmath.vector3(0.01), e.child_go.model.root)
			local skin_def = assert(DEFS.SKINS.SKINS_BY_ID[e.child_go.config.skin])
			go.animate(e.child_go.model.root, "scale", go.PLAYBACK_ONCE_FORWARD, skin_def.scale, go.EASING_INQUAD, 0.25, 0)
		end

		local anim = self:get_animation(e)
		local skin_def = DEFS.SKINS.SKINS_BY_ID[e.skin]
		local animations = skin_def.animations
		local prev = e.child_go.config.animation

		if (e.child_go.config.animation ~= anim) then

			e.child_go.config.animation = anim
			if (anim == ENUMS.ANIMATIONS.IDLE) then
				self:play_idle_animation(e)
			elseif (anim == ENUMS.ANIMATIONS.RUN) then
				e.child_go.config.idle_count = 0
				e.child_go.model.mesh_animator:play(animations.RUN[1].id, prev == ENUMS.ANIMATIONS.DIE and LONG_BLEND_LOOP or BASE_BLEND_LOOP)
			elseif (anim == ENUMS.ANIMATIONS.DIE) then
				e.child_go.config.idle_count = 0
				--e.child_go.model.mesh_animator:play(animations.DIE[1].id, BASE_BLEND_DIE)
			end
		end

		if e.child_go.config.completed_animation then
			e.child_go.config.completed_animation = nil
			go.animate(e.child_go.model.root, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(0.001), go.EASING_OUTQUAD, 0.4, 0.2)
		end


		--for ghost fly mode
		--GO_SET_POSITION(e.position, e.child_go.root)
		V_LOOK_DIR.x, V_LOOK_DIR.y, V_LOOK_DIR.z = e.look_dir.x, 0, e.look_dir.z
		xmath.normalize(V_LOOK_DIR, V_LOOK_DIR)

		e.child_go.config.look_dir_smooth_dump:update(e.child_go.config.look_dir, V_LOOK_DIR, dt)

		local angle = COMMON.LUME.angle_vector(e.child_go.config.look_dir.x, -e.child_go.config.look_dir.z) - math.pi / 2
		xmath.quat_rotation_y(Q_ROTATION, angle)

		GO_SET_ROTATION(Q_ROTATION, e.child_go.model.root)
		e.child_go.model.mesh_animator:update(dt)
	end
end

return System