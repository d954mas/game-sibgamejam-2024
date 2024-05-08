local M = {}
M.water = {
	idx = 0,
	free = {},
}



local function water_create_default_native_buffer()
	return buffer.create(1, {
		{ name = hash("position"), type = buffer.VALUE_TYPE_FLOAT32, count = 3 },
		{ name = hash("normal"), type = buffer.VALUE_TYPE_FLOAT32, count = 3 },
		{ name = hash("texcoord0"), type = buffer.VALUE_TYPE_FLOAT32, count = 2 },
	})
end

---@return BufferResourceData
function M.water_get_buffer()
	local buffer = table.remove(M.water.free)
	if not buffer then
		buffer = M.water_create_new_buffer()
	end
	buffer.free = false
	return buffer
end

function M.water_create_new_buffer()
	M.water.idx = M.water.idx + 1
	local name = "/runtime_buffer_water_" .. M.water.idx .. ".bufferc"
	local new_buffer = resource.create_buffer(name, { buffer = water_create_default_native_buffer() })

	---@class BufferResourceData
	local buffer_resource = {}
	buffer_resource.name = name
	buffer_resource.buffer = new_buffer
	buffer_resource.free = false

	return buffer_resource
end

function M.water_free(buffer_data)
	assert(buffer_data)
	assert(type(buffer_data.buffer), "userdata")
	assert(not buffer_data.free)
	buffer_data.free = true
	resource.set_buffer(buffer_data.buffer, water_create_default_native_buffer())
	table.insert(M.free_buffers, buffer_data)
end

return M