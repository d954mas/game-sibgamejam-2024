local COMMON = require "libs.common"
local CHECKS = require "libs.checks"
local TAG = "SceneLoader"
local M = {}

M.scene_load = {} --current loading
M.scene_loaded = {} -- all loading proxy

---@param scene Scene
function M.load(scene, load_cb)
	CHECKS("class:Scene","function")
	assert(not M.scene_load[tostring(scene._url.path)], " scene is loading now:" .. scene._name)
	if M.is_loaded(scene) then
		COMMON.w("scene:" .. scene._name .. " already loaded")
		load_cb()
		return
	end
	M.scene_load[tostring(scene._url.path)] = load_cb
	COMMON.i("start load:" .. scene._url, "SCENE")
	local ctx = COMMON.CONTEXT:set_context_top_main()
	msg.post(scene._url, COMMON.HASHES.MSG.LOADING.ASYNC_LOAD)
	ctx:remove()
end

function M.is_loaded(scene)
	CHECKS("class:Scene")
	return M.scene_loaded[tostring(scene._url.path)]
end

function M.load_done(url)
	local load_cb = M.scene_load[tostring(url.path)]
	if load_cb then
		M.scene_load[tostring(url.path)] = nil
		M.scene_loaded[tostring(url.path)] = true
		load_cb()
	else
		COMMON.w("scene:" .. tostring(url.path) .. " not wait for loading", TAG)
	end
end

function M.unload(scene)
	CHECKS("class:Scene")
	msg.post(scene._url, COMMON.HASHES.MSG.LOADING.UNLOAD)
	M.scene_load[tostring(scene._url.path)] = false
	M.scene_loaded[tostring(scene._url.path)] = false
end

return M