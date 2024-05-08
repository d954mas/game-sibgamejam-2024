local M = {}

local _createClass

local INSTANCE_METHODS = {
	__tostring = function(self) return "instance of " .. tostring(self.class) end,
	isInstanceOf = function(self, other)
		local super = self.class
		while super do
			if super == other then return true end
			super = super.super
		end
	end,
}

local CLASS_RESERVED_NAMES = {
	name = true,
	super = true,
	subclass = true,
	instance_metatable = true,
	class_table = true,
}

local CLASS_METHODS = {
	tostring = function(self) return "class " .. self.name end,
	new = function(self, ...)
		assert(type(self) == 'table')
		--first time create instance. Prepare instance metatable
		if not self.class_table then
			local class_table = {
				isInstanceOf = INSTANCE_METHODS.isInstanceOf
			}
			local class = self
			for name, method in pairs(class) do
				if not CLASS_RESERVED_NAMES[name] and not class_table[name] then
					class_table[name] = method
				end
			end
			self.class_table = class_table
		end
		local instance = setmetatable({ class = self }, self.instance_metatable)
		for k, v in pairs(self.class_table) do
			instance[k] = v
		end
		if instance.initialize then instance:initialize(...) end
		return instance
	end,
	subclass = function(self, name)
		assert(type(self) == 'table')
		return M.class(name, self)
	end,
}

_createClass = function(name, super)
	local class = { name = name, super = super, subclass = CLASS_METHODS.subclass }
	class.instance_metatable = { __tostring = INSTANCE_METHODS.__tostring }
	setmetatable(class, { __tostring = CLASS_METHODS.tostring, __call = CLASS_METHODS.new })
	if super then
		for method_name, method in pairs(super) do
			if not CLASS_RESERVED_NAMES[method_name] and not class[method_name] then
				class[method_name] = method
			end
		end
	end
	return class
end

function M.class(name, super)
	assert(type(name) == 'string')
	return _createClass(name, super)
end

setmetatable(M, { __call = function(_, ...)
	return M.class(...)
end })

return M
