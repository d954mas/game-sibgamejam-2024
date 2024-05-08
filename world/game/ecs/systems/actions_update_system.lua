local ECS = require 'libs.ecs'
---@class ActionsUpdateSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.filter("actions")
System.name = "ActionsUpdateSystem"

function System:update(dt)
    local entities = self.entities
    for ei=1,#entities do
        local e = entities[ei]
        local i=1
        if(e.actions)then
            local len = #e.actions
            while(i<=len)do
                local action = e.actions[i]
                action:update(dt)
                if(action:is_finished())then
                    table.remove(e.actions,i)
                    i=i-1
                    len = len-1
                end
                i = i + 1
            end
        end
    end
end

return System