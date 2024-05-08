local M = {}

M.GLOBAL = {
	time_init_start = chronos and chronos.nanotime() or socket.gettime()
}

reqf = _G.require -- to fix cyclic dependencies

local COR_RESUME = coroutine.resume
local COR_STATUS = coroutine.status
local COR_YIELD = coroutine.yield

local LOG = require "libs.log"
local CLASS = require "libs.middleclass"

M.HASHES = require "libs.hashes"
M.LUME = require "libs.lume"

M.EVENTS = require "libs.events"
M.CONSTANTS = require "libs.constants"
M.CONTEXT = require "libs_project.contexts_manager"
M.JSON = require "libs.json"
M.LOCALIZATION = require "assets.localization.localization"

M.N28S = require "libs.n28s"
---@type Render set inside render. Used to get buffers outside from render
M.RENDER = nil

--region input
M.INPUT = require "libs.input_receiver"
--endregion

--region LOG
function M.i(message, tag) LOG.i(message, tag, 2) end
function M.w(message, tag) LOG.w(message, tag, 2) end
function M.e(message, tag) LOG.e(message, tag, 2) end
--endregion


--region class
function M.class(name, super)
	return CLASS.class(name, super)
end

function M.new_n28s()
	return CLASS.class("NewN28S", M.N28S.Script)
end
--endregion

function M.is_mobile()
	if html5 then
		local value = html5.run('(typeof window.orientation !== \'undefined\') || (navigator.userAgent.indexOf(\'IEMobile\') !== -1);')
		return value == "true"
	else
		return M.CONSTANTS.PLATFORM_IS_MOBILE
	end
end

function M.get_time()
	if chronos then return chronos.nanotime()
	else return socket.gettime() end
end

---@return coroutine|nil return coroutine if it can be resumed(no errors and not dead)
function M.coroutine_resume(cor, ...)
	local ok, res = COR_RESUME(cor, ...)
	if not ok then
		LOG.w(res .. debug.traceback(cor, "", 1), "Error in coroutine", 1)
	else
		if ((COR_STATUS(cor) ~= "dead")) then return cor end
	end
end

function M.coroutine_wait(time)
	assert(time)
	local dt = 0
	while dt < time do
		dt = dt + COR_YIELD()
	end
end

return M