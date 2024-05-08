local COMMON = require "libs.common"
local READER = require "def-mesh.reader"
local MESH_TEXTURE = require "def-mesh.texture"
local ANIMATIONS = require "world.balance.def.animations"

local M = {
	animations = {},
	meshes = {}
}

local MESHES_LIST = {
	{ name = "char_base", file = "char_base.bin" },
}

local function load_meshes()
	for _, mesh_data in ipairs(MESHES_LIST) do
		print("load mesh:" .. mesh_data.file)
		READER.init_from_resource("/assets/custom/mesh/" .. mesh_data.file)
		local mesh = READER.read_mesh()[1]
		print(mesh.mesh_data.name .. " " .. #mesh.mesh_data.faces .. " triangles")
		assert(READER.eof(), "file have more than one mesh. Index:" .. READER.index .. " Content:" .. #READER.content .. " diff:" .. #READER.content - READER.index)
		M.meshes[mesh_data.name] = mesh
	end
end

local function load_animations()
	for _, animation in ipairs(ANIMATIONS.LOAD_LIST) do
		print("load animation:" .. animation.file)
		READER.init_from_resource("/assets/custom/mesh/animations/" .. animation.file)
		local mesh = READER.read_mesh()[1]
		assert(READER.eof(), "file have more than one mesh")
		local frames = #mesh.mesh_data.frames_native
		assert(frames > 0)
		animation.frames = frames
		animation.frames_native = mesh.mesh_data.frames_native
		animation.frame_matrices = mesh.mesh_data.frame_matrices

	end
end

function M.load()
	local time_start = COMMON.get_time()
	load_meshes()
	print("mesh load:" .. (COMMON.get_time() - time_start))
	local time = COMMON.get_time()
	load_animations()
	print("animation load:" .. (COMMON.get_time() - time))

	time = COMMON.get_time()
	local mesh_base = assert(M.meshes["char_base"])
	for _, animation in ipairs(ANIMATIONS.LOAD_LIST)do
		mesh_base:add_animation(animation.id, animation.frames_native, animation.frame_matrices)
	end
	mesh_base.mesh_data.texture_animations = MESH_TEXTURE.bake_animation_texture(mesh_base)
	for k, v in pairs(M.meshes) do
		if v ~= mesh_base then
			v.mesh_data.animations = mesh_base.mesh_data.animations
			v.mesh_data.frames_native = mesh_base.mesh_data.frames_native
			v.mesh_data.frame_matrices = mesh_base.mesh_data.frame_matrices
			v.mesh_data.texture_animations = mesh_base.mesh_data.texture_animations
		end
	end
	print("add animations:" .. (COMMON.get_time() - time))
	print("mesh total loading", (COMMON.get_time() - time_start))
end

---@return BinMesh
function M.get_mesh(name)
	local mesh = assert(M.meshes[name], "no mesh with name:" .. name)
	return mesh:clone()
end

return M