local COMMON = require "libs.common"

local OLD_MOUNTS = {
	"liveupdate",
	"liveupdate_resources1.zip",
}

local VERSION = 1
local M = {}

local external_data = {
	name = "liveupdate_resources2.zip", ---Name for zip archive
	path = "./"  ---Here we indicate the path to the file. I set root folder
}

M.cb = nil

local function on_error(data, error)
	COMMON.e("liveupdate error:" .. tostring(error))
	M.cb(false)
	M.cb = nil
end

local function on_success()
	M.cb(true)
	M.cb = nil
end

---Check if the data already mounted
---@param archive_name string
---@return boolean
local function is_in_mount(archive_name)
	local mounts = liveupdate.get_mounts()
	for _, mount in pairs(mounts) do
		if archive_name == mount.name then
			return true
		end
	end
	return false
end

---Save file and mount data
---@param data external_data
---@param response string
---@param priority number
local function on_file_received(data, response, priority, cb)
	local new_path = sys.get_save_file("blocky_universe", data.name)
	---Create a file object to work with IndexedDB
	local file, err = io.open(new_path, "w+")
	if err then
		on_error(data, err)
		return
	end
	---Write our received data to IndexedDB
	local _, err2 = file:write(response)
	if err2 then
		cb(false)
		return
	end
	---Close connection
	file:close()
	---Add new mount
	liveupdate.add_mount(data.name, "zip:" .. new_path, priority, function()
		---Our data loaded. Now we can load proxy.
		on_success()
	end)
end

local ATTEMPT_COUNT = 50

---We make requests for data until we receive it
---@param data external_data
---@param index number
---@param attempt number|nil
local function request_data(data, index, attempt)
	attempt = attempt or 1
	http.request(data.path .. data.name, "GET", function(self, id, response)
		if (response.status == 200 or response.status == 304) and response.error == nil and response.response ~= nil then
			on_file_received(data, response.response, index)
		elseif attempt <= ATTEMPT_COUNT then
			---If unsuccessful, I make several attempts to load the data.
			attempt = attempt + 1
			timer.delay(0.1, false, function()
				request_data(data, index, attempt)
			end)
		else
			on_error(data, response.error)
		end
	end)
end

function M.remove_old()
	--remove all current mounts\
	if liveupdate then
		local mounts = liveupdate.get_mounts()
		for _, mount in ipairs(mounts) do
			if COMMON.LUME.findi(OLD_MOUNTS, mount.name) then
				liveupdate.remove_mount(mount.name)
			end
		end
	end
end

function M.load_proxy(proxy_url, cb)
	assert(not M.cb)
	M.cb = cb
	---I check that it is a web and check the created mounts
	if not liveupdate or not html5 or is_in_mount(external_data.name) then
		on_success()
	else
		request_data(external_data, VERSION)
	end
end

function M.is_loaded()
	return not liveupdate or not html5 or is_in_mount(external_data.name)
end

function M.is_ready()
	return COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.LIVEUPDATE_COLLECTION)
end

return M