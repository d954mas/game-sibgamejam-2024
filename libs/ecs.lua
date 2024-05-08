---@class ECSTiny
local tiny = {}

local tremove = table.remove
local type = type
local select = select

-- Local versions of the library functions
local tiny_manageEntities
local tiny_manageSystems
local tiny_removeEntity
local tiny_removeSystem

--- Filter functions.
-- A Filter is a function that selects which Entities apply to a System.
-- Filters take two parameters, the System and the Entity, and return a boolean
-- value indicating if the Entity should be processed by the System. A truthy
-- value includes the entity, while a falsey (nil or false) value excludes the
-- entity.
--
-- Filters must be added to Systems by setting the `filter` field of the System.
-- Filter's returned by tiny-ecs's Filter functions are immutable and can be
-- used by multiple Systems.
--
--    local f1 = tiny.requireAll("position", "velocity", "size")
--    local f2 = tiny.requireAny("position", "velocity", "size")
--
--    local e1 = {
--        position = {2, 3},
--        velocity = {3, 3},
--        size = {4, 4}
--    }
--
--    local entity2 = {
--        position = {4, 5},
--        size = {4, 4}
--    }
--
--    local e3 = {
--        position = {2, 3},
--        velocity = {3, 3}
--    }
--
--    print(f1(nil, e1), f1(nil, e2), f1(nil, e3)) -- prints true, false, false
--    print(f2(nil, e1), f2(nil, e2), f2(nil, e3)) -- prints true, true, true
--
-- Filters can also be passed as arguments to other Filter constructors. This is
-- a powerful way to create complex, custom Filters that select a very specific
-- set of Entities.
--
--    -- Selects Entities with an "image" Component, but not Entities with a
--    -- "Player" or "Enemy" Component.
--    filter = tiny.requireAll("image", tiny.rejectAny("Player", "Enemy"))
--
-- @section Filter

-- A helper function to compile filters.
local filterJoin

-- A helper function to filters from string
local filterBuildString

do

	local loadstring = loadstring or load
	local function getchr(c)
		return "\\" .. c:byte()
	end
	local function make_safe(text)
		return ("%q"):format(text):gsub('\n', 'n'):gsub("[\128-\255]", getchr)
	end

	local function filterJoinRaw(prefix, seperator, ...)
		local accum = {}
		local build = {}
		for i = 1, select('#', ...) do
			local item = select(i, ...)
			if type(item) == 'string' then
				accum[#accum + 1] = ("(e[%s] ~= nil)"):format(make_safe(item))
			elseif type(item) == 'function' then
				build[#build + 1] = ('local subfilter_%d_ = select(%d, ...)')
						:format(i, i)
				accum[#accum + 1] = ('(subfilter_%d_(system, e))'):format(i)
			else
				error 'Filter token must be a string or a filter function.'
			end
		end
		local source = ('%s\nreturn function(system, e) return %s(%s) end')
				:format(
				table.concat(build, '\n'),
				prefix,
				table.concat(accum, seperator))
		local loader, err = loadstring(source)
		if err then error(err) end
		return loader(...)
	end

	function filterJoin(...)
		local state, value = pcall(filterJoinRaw, ...)
		if state then return value else return nil, value end
	end

	local function buildPart(str)
		local accum = {}
		local subParts = {}
		str = str:gsub('%b()', function(p)
			subParts[#subParts + 1] = buildPart(p:sub(2, -2))
			return ('\255%d'):format(#subParts)
		end)
		for invert, part, sep in str:gmatch('(%!?)([^%|%&%!]+)([%|%&]?)') do
			if part:match('^\255%d+$') then
				local partIndex = tonumber(part:match(part:sub(2)))
				accum[#accum + 1] = ('%s(%s)')
						:format(invert == '' and '' or 'not', subParts[partIndex])
			else
				accum[#accum + 1] = ("(e[%s] %s nil)")
						:format(make_safe(part), invert == '' and '~=' or '==')
			end
			if sep ~= '' then
				accum[#accum + 1] = (sep == '|' and ' or ' or ' and ')
			end
		end
		return table.concat(accum)
	end

	function filterBuildString(str)
		local source = ("return function(_, e) return %s end")
				:format(buildPart(str))
		local loader, err = loadstring(source)
		if err then
			error(err)
		end
		return loader()
	end
end

--- Makes a Filter from a string. Syntax of `pattern` is as follows.
--
--   * Tokens are alphanumeric strings including underscores.
--   * Tokens can be separated by |, &, or surrounded by parentheses.
--   * Tokens can be prefixed with !, and are then inverted.
--
-- Examples are best:
--    'a|b|c' - Matches entities with an 'a' OR 'b' OR 'c'.
--    'a&!b&c' - Matches entities with an 'a' AND NOT 'b' AND 'c'.
--    'a|(b&c&d)|e - Matches 'a' OR ('b' AND 'c' AND 'd') OR 'e'
-- @param pattern
function tiny.filter(pattern)
	local state, value = pcall(filterBuildString, pattern)
	if state then return value else return nil, value end
end

--- Creates a new System or System class from the supplied table. If `table` is
-- nil, creates a new table.
---@return ECSSystem
function tiny.system(table)
	table = table or {}
	table._time = { current = 0, max = 0, average = 0, average_count = 0, average_value = 0 }
	return table
end

local empty = function() end

--- Creates a new World.
-- Can optionally add default Systems and Entities. Returns the new World along
-- with default Entities and Systems.
---@return ECSWorld
function tiny.world()
	---@type ECSWorld
	local world = {
		frame = 0,
		-- List of Entities to remove
		entitiesToRemove = {},
		-- List of Entities to change
		entitiesToChange = {},
		-- List of Entities to add
		systemsToAdd = {},
		-- List of Entities to remove
		systemsToRemove = {},
		-- Set of Entities
		entities = {},
		-- List of Systems
		systems = {},

		addEntity = tiny.addEntity,
		addSystem = tiny.addSystem,
		remove = tiny.remove,
		removeEntity = tiny.removeEntity,
		removeSystem = tiny.removeSystem,
		refresh = tiny.refresh,
		update = tiny.update,
		clearEntities = tiny.clearEntities,
		clearSystems = tiny.clearSystems,
		on_entity_added = empty,
		on_entity_updated = empty,
		on_entity_removed = empty,
		clear = tiny.clear
	}

	tiny_manageSystems(world)
	tiny_manageEntities(world)

	return world
end

--- Adds an Entity to the world.
-- Also call this on Entities that have changed Components such that they
-- match different Filters. Returns the Entity.
function tiny.addEntity(world, entity)
	local e2c = world.entitiesToChange
	e2c[#e2c + 1] = entity
	return entity
end

--- Adds a System to the world. Returns the System.
function tiny.addSystem(world, system)
	assert(system.world == nil, "System already belongs to a World.")
	local s2a = world.systemsToAdd
	s2a[#s2a + 1] = system
	system.world = world
	return system
end

--- Removes an Entity from the World. Returns the Entity.
function tiny.removeEntity(world, entity)
	local e2r = world.entitiesToRemove
	e2r[#e2r + 1] = entity
	return entity
end
tiny_removeEntity = tiny.removeEntity

--- Removes a System from the world. Returns the System.
function tiny.removeSystem(world, system)
	assert(system.world == world, "System does not belong to this World.")
	local s2r = world.systemsToRemove
	s2r[#s2r + 1] = system
	return system
end
tiny_removeSystem = tiny.removeSystem


-- Adds and removes Systems that have been marked from the World.
function tiny_manageSystems(world)
	local s2a, s2r = world.systemsToAdd, world.systemsToRemove

	-- Early exit
	if #s2a == 0 and #s2r == 0 then
		return
	end

	world.systemsToAdd = {}
	world.systemsToRemove = {}

	local worldEntityList = world.entities
	local systems = world.systems

	-- Remove Systems
	for i = 1, #s2r do
		local system = s2r[i]
		local index = system.index
		local onRemove = system.onRemove
		if onRemove and not system.nocache then
			local entityList = system.entities
			for j = 1, #entityList do
				onRemove(system, entityList[j])
			end
		end
		tremove(systems, index)
		for j = index, #systems do
			systems[j].index = j
		end
		local onRemoveFromWorld = system.onRemoveFromWorld
		if onRemoveFromWorld then
			onRemoveFromWorld(system, world)
		end
		s2r[i] = nil

		-- Clean up System
		system.world = nil
		system.entities = nil
		system.indices = nil
		system.index = nil
	end

	-- Add Systems
	for i = 1, #s2a do
		local system = s2a[i]
		if systems[system.index or 0] ~= system then
			if not system.nocache then
				system.entities = {}
				system.indices = {}
			end
			if system.active == nil then
				system.active = true
			end
			system.modified = true
			system.world = world
			local index = #systems + 1
			system.index = index
			systems[index] = system
			local onAddToWorld = system.onAddToWorld
			if onAddToWorld then
				onAddToWorld(system, world)
			end

			-- Try to add Entities
			if not system.nocache then
				local entityList = system.entities
				local entityIndices = system.indices
				local onAdd = system.onAdd
				local filter = system.filter
				if filter then
					for j = 1, #worldEntityList do
						local entity = worldEntityList[j]
						if filter(system, entity) then
							local entityIndex = #entityList + 1
							entityList[entityIndex] = entity
							entityIndices[entity] = entityIndex
							if onAdd then
								onAdd(system, entity)
							end
						end
					end
				end
			end
		end
		s2a[i] = nil
	end
end

-- Adds, removes, and changes Entities that have been marked.
function tiny_manageEntities(world)

	local e2r = world.entitiesToRemove
	local e2c = world.entitiesToChange

	-- Early exit
	if #e2r == 0 and #e2c == 0 then
		return
	end

	world.entitiesToChange = {}
	world.entitiesToRemove = {}

	local entities = world.entities
	local systems = world.systems

	-- Change Entities
	for i = 1, #e2c do
		local entity = e2c[i]
		-- Add if needed
		--if not entities[entity] then
		if not entity._in_world then
			local index = #entities + 1
			entities[entity] = index
			entities[index] = entity
			world:on_entity_added(entity)
		else
			world:on_entity_updated(entity)
		end
		for j = 1, #systems do
			local system = systems[j]
			if not system.nocache then
				local ses = system.entities
				local seis = system.indices
				local index = seis[entity]
				local filter = system.filter
				if filter and filter(system, entity) then
					if not index then
						system.modified = true
						index = #ses + 1
						ses[index] = entity
						seis[entity] = index
						local onAdd = system.onAdd
						if onAdd then
							onAdd(system, entity)
						end
					end
				elseif index then
					system.modified = true
					local tmpEntity = ses[#ses]
					ses[index] = tmpEntity
					seis[tmpEntity] = index
					seis[entity] = nil
					ses[#ses] = nil
					local onRemove = system.onRemove
					if onRemove then
						onRemove(system, entity)
					end
				end
			end
		end
		e2c[i] = nil
	end

	-- Remove Entities
	for i = 1, #e2r do
		local entity = e2r[i]
		e2r[i] = nil
		local listIndex = entities[entity]
		if listIndex then
			-- Remove Entity from world state
			local lastEntity = entities[#entities]
			entities[lastEntity] = listIndex
			entities[entity] = nil
			entities[listIndex] = lastEntity
			entities[#entities] = nil
			world:on_entity_removed(entity)
			-- Remove from cached systems
			for j = 1, #systems do
				local system = systems[j]
				if not system.nocache then
					local ses = system.entities
					local seis = system.indices
					local index = seis[entity]
					if index then
						system.modified = true
						local tmpEntity = ses[#ses]
						ses[index] = tmpEntity
						seis[tmpEntity] = index
						seis[entity] = nil
						ses[#ses] = nil
						local onRemove = system.onRemove
						if onRemove then
							onRemove(system, entity)
						end
					end
				end
			end
		end
	end
end

--- Manages Entities and Systems marked for deletion or addition. Call this
-- before modifying Systems and Entities outside of a call to `tiny.update`.
-- Do not call this within a call to `tiny.update`.
function tiny.refresh(world)
	tiny_manageSystems(world)
	tiny_manageEntities(world)
end

local get_time = function()
	if chronos then
		return chronos.nanotime()
	else
		return socket.gettime()
	end
end
local max = math.max

--- Updates the World by dt (delta time).
function tiny.update(world, dt)
	--#IF DEBUG
	if profiler then
		profiler.scope_begin("ECS world update")
	end
	--#ENDIF

	tiny_manageSystems(world)
	tiny_manageEntities(world)

	local systems = world.systems
	world.frame = world.frame + 1
	world.odd = world.frame % 2 == 0

	--  Iterate through Systems IN ORDER
	for i = 1, #systems do
		local system = systems[i]
		if system.active then
			-- Update Systems that have an update method (most Systems)
			local update = system.update
			if update then
				--#IF DEBUG
				if profiler then
					profiler.scope_begin(system.name or "unknown system")
				end
				--#ENDIF
				local start_time = get_time()
				local interval = system.interval
				if interval then
					local bufferedTime = (system.bufferedTime or 0) + dt
					while bufferedTime >= interval do
						bufferedTime = bufferedTime - interval
						update(system, dt)
					end
					system.bufferedTime = bufferedTime
				elseif (system.odd) then
					if (world.odd) then
						update(system, dt)
					end
				elseif (system.even) then
					if (not world.odd) then
						update(system, dt)
					end
				else
					update(system, dt)
				end
				--#IF DEBUG
				system._time.current = get_time() - start_time
				system._time.max = max(system._time.max, system._time.current)
				--average bad. For 0,0,0,0,0,1 average will be 0.5
				system._time.average = system._time.average + system._time.current
				system._time.average_count = system._time.average_count + 1
				if system._time.average_count > 1800 then
					--update once a minute
					system._time.average_value = system._time.average
					system._time.average = 0
					system._time.average_count = 0
				end
				if profiler then
					profiler.scope_end()
				end
				--#ENDIF

			end

			system.modified = false
		end
	end
	--#IF DEBUG
	if profiler then
		profiler.scope_end()
	end
	--#ENDIF
end

--- Removes all Entities from the World.
function tiny.clearEntities(world)
	local el = world.entities
	for i = 1, #el do
		tiny_removeEntity(world, el[i])
	end
end

--- Removes all Systems from the World.
function tiny.clearSystems(world)
	local systems = world.systems
	for i = #systems, 1, -1 do
		tiny_removeSystem(world, systems[i])
	end
end

function tiny.clear(world)
	tiny.clearEntities(world)
	tiny.clearSystems(world)
	tiny.refresh(world)
end

return tiny