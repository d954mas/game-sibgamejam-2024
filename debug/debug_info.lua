local M = {}

M.ecs_update_dt = 0
M.ecs_update_dt_max_second= 0


function M.update_ecs_dt(dt)
    if(M.need_update)then
        M.ecs_update_dt_max_second = dt
    end
    M.ecs_update_dt = dt
    if(dt > M.ecs_update_dt_max_second)then
        M.ecs_update_dt_max_second = dt
    end
end

return M