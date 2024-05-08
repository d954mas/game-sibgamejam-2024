
local ANALYTICS_HELPER = require "libs_project.analytics_helper"

local M = {}
M.print_f = print
M.use_tag_blacklist = true

M.tag_blacklist = {

}

M.DEBUG = 20
M.INFO = 30
M.WARNING = 40
M.ERROR = 50

M.log_level_names = {
	[20] = "DEBUG ",
	[30] = "INFO ",
	[40] = "WARN ",
	[50] = "ERROR ",
}


function M.add_to_blacklist(tag, state)
	state = state or true
	M.tag_blacklist[tag] = state
end

function M.save_log_line(line, level, tag, debug_level)
	if line == nil then return end

	line = tostring(line)

	debug_level = debug_level or 1

	level = level or M.DEBUG

	tag = tag or "none"

	if M.use_tag_blacklist then
		if M.tag_blacklist[tag] then
			return false
		end
	end

	local level_string = M.log_level_names[level]

	local timestamp = os.time()
	local timestamp_string = os.date('%H:%M:%S', timestamp)

	local head = "[" .. level_string .. timestamp_string .. "]"
	local body = ""

	if tag then
		head = head .. " " .. tag .. ":"
	end

	if debug then
		local info = debug.getinfo(2 + debug_level, "Sl") -- https://www.lua.org/pil/23.1.html
		local short_src = info.short_src
		local line_number = info.currentline
		body = short_src .. ":" .. line_number .. ":"
	end

	local complete_line = head .. " " .. body .. " " .. line
	if level >= M.WARNING then
		if poki_sdk then
			poki_sdk.capture_error(complete_line)
		end
		ANALYTICS_HELPER.error(complete_line)
	end
	M.print_f(complete_line)
end

M.add_to_blacklist("Sound")

function M.w(message, tag, debug_level)
	M.save_log_line(message, M.WARNING, tag, debug_level)
end
function M.e(message, tag, debug_level)
	M.save_log_line(message, M.ERROR, tag, debug_level)
end

--#IF RELEASE
function M.i() end
--#ELSE
function M.i(message, tag, debug_level)
	M.save_log_line(message, M.INFO, tag, debug_level)
end


--override print
print = function(...)
	local arg = { ... }
	local result = arg[1]
	for i = 2, #arg do
		result = result .. "\t" .. tostring(arg[i])
	end
	M.i(result, nil, 2)
end
--#ENDIF


return M