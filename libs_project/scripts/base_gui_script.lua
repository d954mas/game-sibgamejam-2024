local COMMON = require "libs.common"
local CHECKS = require "libs.checks"

---@class GuiScriptConfig
local ConfigTypeDef = {
	context_name = "?string",
	input = "?boolean", --true by default
	scene = "?class:Scene",
	input_priority = "?number"
}

---@class GuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
	self.vh = {}
	self.view = {}
end

function Script:init_gui()

end

---@param config GuiScriptConfig
function Script:init(config)
	CHECKS("?", ConfigTypeDef)
	self.config = config or {}
	if (self.config.input == nil) then self.config.input = true end
	if (self.config.context_name) then COMMON.CONTEXT:register(self.config.context_name, self) end
	self:bind_vh()
	self:init_gui()

	self.subscriptions = {}
	if self.on_storage_changed then
		table.insert(self.subscriptions, COMMON.EVENTS.STORAGE_CHANGED:subscribe(true, function()
			self:on_storage_changed()
		end))
		self:on_storage_changed()
	end
	if self.on_resize then
		table.insert(self.subscriptions, COMMON.EVENTS.WINDOW_RESIZED:subscribe(true, function()
			self:on_resize()
		end))
		self:on_resize()
	end
	if self.on_language_changed then
		table.insert(self.subscriptions, COMMON.EVENTS.LANGUAGE_CHANGED:subscribe(true, function()
			self:on_language_changed()
		end))
		self:on_language_changed()

		--fixed font changed by script
		timer.delay(0,false,function()
			self:on_language_changed()
		end)
	end

	if (self.config.input) then COMMON.INPUT.acquire(self, self.config.input_priority, self.config.scene) end
end

function Script:final()
	for _, subscription in ipairs(self.subscriptions) do
		subscription()
	end
	if (self.config.context_name) then COMMON.CONTEXT:unregister(self.config.context_name) end
	if (self.config.input) then COMMON.INPUT.release(self) end
end

return Script