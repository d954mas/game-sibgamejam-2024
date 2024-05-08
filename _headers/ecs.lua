
---@class ECSSystem
---@field world ECSWorld
---@field active boolean
---@field interval number
---@field nocache boolean
---@field entities EntityGame[]
local systemClass = {}
function systemClass:init() end
function systemClass:update(dt) end
function systemClass:onModify() end
function systemClass:onAddToWorld() end
function systemClass:onRemoveFromWorld() end
---@param e EntityGame
function systemClass:onAdd(e) end
---@param e EntityGame
function systemClass:onRemove(e) end

---@class ECSWorld
---@field game_world World
---@field entitiesToRemove table
---@field entitiesToChange table
---@field systemsToAdd table
---@field systemsToRemove table
---@field entities EntityGame[]
---@field systems table
local World = {}
function World:addEntity(entity) end
function World:addSystem(system) end
function World:removeEntity(entity) end
function World:removeSystem(system) end
function World:refresh() end
function World:update(dt, filter) end
function World:clearEntities() end
function World:clearSystems(system) end
function World:getSystemCount(system) end
function World:setSystemIndex(system) end
function World:clear() end

function World:on_entity_removed(e) end
function World:on_entity_updated(e) end
function World:on_entity_added(e) end