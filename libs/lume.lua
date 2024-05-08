-- lume
-- Copyright (c) 2018 rxi

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert = type, assert
local tonumber = tonumber
local string_format = string.format
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2
local math_abs = math.abs
local table_remove = table.remove
local math_random = math.random

function lume.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function lume.round(x, increment)
	if increment then return lume.round(x / increment) * increment end
	return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end
function lume.ceil(x, increment)
	if increment then return math.ceil(x / increment) * increment end
	return math.ceil(x)
end
function lume.floor(x, increment)
	if increment then return math.floor(x / increment) * increment end
	return math.floor(x)
end

function lume.sign(x)
	return x < 0 and -1 or 1
end

function lume.angle_vector(x, y)
	return math_atan2(y, x)
end

function lume.angle_two_vectors(x1, y1, x2, y2)
	local angle1 = lume.angle_vector(x1, y1)
	local angle2 = lume.angle_vector(x2, y2)
	local angle = angle2 - angle1

	-- Normalize the angle to be within -π to π
	if angle > math.pi then
		angle = angle - 2 * math.pi
	elseif angle < -math.pi then
		angle = angle + 2 * math.pi
	end

	return angle
end

function lume.angle_min_deg(deg)
	deg = deg % 360;
	if (deg < 0) then deg = deg + 360 end
	--if deg > 180 then deg = deg - 360 end
	return deg
end

function lume.randomchoice(t)
	return t[math_random(#t)]
end
function lume.randomchoice_remove(t)
	return table_remove(t, math_random(#t))
end

function lume.random(a, b)
	if not a then
		a, b = 0, 1
	end
	if not b then
		b = 0
	end
	return a + math_random() * (b - a)
end

function lume.weightedchoice_nil(t)
	local sum = 0
	for _, v in pairs(t) do
		assert(v >= 0, "weight value less than zero")
		sum = sum + v
	end
	if (sum == 0) then return nil end
	local rnd = lume.random(sum)
	for k, v in pairs(t) do
		if rnd < v then
			return k
		end
		rnd = rnd - v
	end
end
function lume.weightedchoice(t)
	local result = lume.weightedchoice_nil(t)
	assert(result, "all weights are zero")
end

function lume.removei(t, value)
	for k, v in ipairs(t) do
		if v == value then
			return table_remove(t, k)
		end
	end
end

function lume.clearp(t)
	for k, v in pairs(t) do t[k] = nil end
	return t
end
function lume.cleari(t)
	for i = 1, #t do t[i] = nil end
	return t
end

function lume.shuffle(t)
	local rtn = {}
	for i = 1, #t do
		local r = math_random(i)
		if r ~= i then
			rtn[i] = rtn[r]
		end
		rtn[r] = t[i]
	end
	return rtn
end

function lume.find(t, value)
	for k, v in pairs(t) do
		if v == value then return k end
	end
	return nil
end
function lume.findi(t, value)
	for k, v in ipairs(t) do
		if v == value then return k end
	end
	return nil
end

---@generic T
---@param t T
---@return T
function lume.clone_shallow(t)
	local rtn = {}
	for k, v in pairs(t) do rtn[k] = v end
	return rtn
end
function lume.clone_deep(t)
	local orig_type = type(t)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, t, nil do
			copy[lume.clone_deep(orig_key)] = lume.clone_deep(orig_value)
		end
	else
		-- number, string, boolean, etc
		copy = t
	end
	return copy
end

function lume.lerp(a, b, amount)
	return a + (b - a) * lume.clamp(amount, 0, 1)
end

function lume.color_parse_hexRGBA(hex)
	local r, g, b, a = hex:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
	if a == "" then a = "ff" end
	if r and g and b and a then
		return vmath.vector4(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255)
	end
	return nil
end

function lume.rgbToHsv(r, g, b, a)
	r, g, b, a = r , g , b , a
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v, a
end

function lume.hsvToRgb(h, s, v, a)
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return r , g , b , a
end

---@param url url
function lume.url_component_from_url(url, component)
	return msg.url(url.socket, url.path, component)
end

function lume.get_human_time(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		local hours = string_format("%02.f", math_floor(seconds / 3600));
		local mins = string_format("%02.f", math_floor(seconds / 60 - (hours * 60)));
		local secs = string_format("%02.f", math_floor(seconds - hours * 3600 - mins * 60));
		if hours == '00' then
			return mins .. ":" .. secs
		else
			return hours .. ":" .. mins .. ":" .. secs
		end
	end
end

local units = { "k", "m", "b", "t" }
-- Function to generate the sequence of units
local function generateAlphabetUnits()
	-- Add single letters A-Z
	for i = 65, 90 do
		-- ASCII values for A-Z
		table.insert(units, string.char(i))
	end

	-- Generate double letters AA, AB, ..., AZ, BA, ..., ZZ
	for i = 65, 90 do
		for j = 65, 90 do
			table.insert(units, string.char(i) .. string.char(j))
		end
	end
end
generateAlphabetUnits()  -- Call the function to fill the rest of the unit

function lume.formatIdleNumber(num, precision)
	local threshold = 99999 -- Set the minimum number to start formatting

	if num <= threshold then
		if precision then
			local decimalPart = num - math_floor(num)
			if decimalPart > 0.05 then
				return string_format("%." .. precision .. "f", num)
			else
				return tostring(num)
			end
		else
			num = math.floor(num)
			return tostring(num)
		end
	end

	num = math.floor(num)

	local logBase1000 = math.log(num) / math.log(1000)
	local unitIndex = math.floor(logBase1000)

	-- Calculate formatted number
	local formattedNum = num / (1000 ^ unitIndex)

	-- Check for boundary condition where formattedNum should transition to the next unit
	if formattedNum >= 1000 and unitIndex < #units then
		unitIndex = unitIndex + 1
		formattedNum = formattedNum / 1000
	end

	-- Manually format the number to include one decimal place
	local integerPart = math.floor(formattedNum)
	local decimalPart = formattedNum - integerPart

	local formattedStr
	if decimalPart == 0 then
		formattedStr = string.format("%d.0%s", integerPart, units[unitIndex])
	else
		-- Ensure only one digit after the decimal point
		local decimalStr = tostring(math.floor(decimalPart * 10))
		formattedStr = tostring(integerPart) .. "." .. decimalStr .. units[unitIndex]
	end

	return formattedStr
end

function lume.equals_float(a, b, epsilon)
	epsilon = epsilon or 0.0001
	return (math_abs(a - b) < epsilon)
end

function lume.LookRotation(forward, up)
	local mag = vmath.length(forward)
	if mag < 1e-6 then
		error("Error input forward to Quaternion.LookRotation" .. tostring(forward))
		return nil
	end

	forward = forward / mag
	up = up or vmath.vector3(0, 1, 0)
	local right = vmath.normalize(vmath.cross(up, forward))
	up = vmath.cross(forward, right)

	local t = right.x + up.y + forward.z

	if t > 0 then
		t = t + 1
		local s = 0.5 / math.sqrt(t)
		local w = s * t
		local x = (up.z - forward.y) * s
		local y = (forward.x - right.z) * s
		local z = (right.y - up.x) * s

		return vmath.quat(x, y, z, w)
	else
		local q = { 0, 0, 0 }
		local i, j, k
		local rot = {
			{ right.x, up.x, forward.x },
			{ right.y, up.y, forward.y },
			{ right.z, up.z, forward.z }
		}
		local next = { 2, 3, 1 }

		if up.y > right.x then
			i = 2
		else
			i = 1
		end

		if forward.z > rot[i][i] then
			i = 3
		end

		j = next[i]
		k = next[j]

		local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
		local s = 0.5 / math.sqrt(t)
		q[i] = s * t
		local w = (rot[k][j] - rot[j][k]) * s
		q[j] = (rot[j][i] + rot[i][j]) * s
		q[k] = (rot[k][i] + rot[i][k]) * s

		return vmath.quat(q[1], q[2], q[3], w)
	end
end

function lume.merge_table(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				lume.merge_table(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

return lume