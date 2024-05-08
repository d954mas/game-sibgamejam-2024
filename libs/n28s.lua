local CLASS = require "libs.middleclass"
local M = {}
--no init. It called when script added to go
local DEFOLD_METHODS_ADD_BASE = { 'final', 'update', 'fixed_update', 'on_reload', "on_message" }
local DEFOLD_METHODS = { 'final', 'update', 'fixed_update', 'on_reload', "on_message", "on_input" }

---@class N28SRegistrator
local Registrator = CLASS.class("N28SRegistrator")

---@class N28SScript
local Script = CLASS.class("N28SScript")
---@field go_self table

function Registrator:initialize()
	self.__register = false
	self.scripts = {}
	---@type N28SScript[]
	self.methods = {}
	for _, m in ipairs(DEFOLD_METHODS) do
		self.methods[m] = {}
	end
end

function Registrator:add_script(script)
	assert(not self.__register)
	assert(script, "script can't be nil")
	assert(script.isInstanceOf, "add instance not class")
	assert(script:isInstanceOf(Script), "can add only script classes")
	table.insert(self.scripts, script)
	for _, m in ipairs(DEFOLD_METHODS) do
		if script[m] then
			table.insert(self.methods[m], script)
		end
	end
end

function Registrator:register()
	assert(not self.__register)
	assert(not _G.init, "already register")
	self.__register = true
	_G.init = function(go_self, ...)
		go_self.scripts = self.scripts
		for _, script in ipairs(self.scripts) do
			script:_set_go(go_self)
		end
	end

	for mi = 1, #DEFOLD_METHODS_ADD_BASE do
		local m = DEFOLD_METHODS_ADD_BASE[mi]
		if #self.methods[m] > 0 then
			local scripts = self.methods[m]
			assert(not _G[m], "already register " .. m)
			if #scripts == 1 then
				local script = scripts[1]
				local fun = script[m]
				_G[m] = function(go_self, ...)
					fun(script, ...)
				end
			else
				local scripts_len = #scripts
				_G[m] = function(go_self, ...)
					for i = 1, scripts_len do
						local script = scripts[i]
						script[m](script, ...)
					end
				end
			end
		end
	end
	if #self.methods["on_input"] > 0 then
		local scripts = self.methods["on_input"]
		assert(not _G["on_input"], "already register " .. "on_input")
		if #scripts == 1 then
			local script = scripts[1]
			local fun = script["on_input"]
			_G["on_input"] = function(go_self, ...)
				return fun(script, ...)
			end
		else
			local scripts_len = #scripts
			_G["on_input"] = function(go_self, ...)
				local inputResult = false
				for i = 1, scripts_len do
					local script = scripts[i]
					inputResult = inputResult or script["on_input"](script, ...)
				end
				return inputResult == true
			end
		end
	end
end


function Script:initialize()
end

function Script:_set_go(go)
	assert(not self._go, "already register")
	self._go = assert(go)
	self:__register()
	self:init()
end

--go should have registered global function
function Script:__register()
	assert(self._go)
	assert(not self.__registered)
	self.__registered = true
end

function Script:init()

end

function M.register(script)
	local registrator = Registrator()
	registrator:add_script(assert(script))
	registrator:register()
end

function M.register_scripts(scripts)
	assert(#scripts > 0)
	local registrator = Registrator()
	for _, script in ipairs(scripts) do
		registrator:add_script(script)
	end
	registrator:register()
end

M.Registrator = Registrator
M.Script = Script

--make register function of n28s(not inherits it)

return M