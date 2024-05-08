local Helper = {}
---@type World
Helper.WORLD = nil

function Helper.game_loaded()
	Helper.WORLD.analytics:eventCustom("game:loaded")
end

function Helper.gameplay_start()
	Helper.WORLD.analytics:eventCustom("game:gameplay_start")
end

function Helper.error(error)
	if Helper.WORLD then
		Helper.WORLD.analytics:error(error)
	end
end

function Helper.scene_load_start(name)
	Helper.WORLD.analytics:eventCustom("scene:" .. name .. ":load_start")
end

function Helper.scene_load_end(name)
	Helper.WORLD.analytics:eventCustom("scene:" .. name .. ":load_end")
end

function Helper.scene_show(name)
	Helper.WORLD.analytics:eventCustom("scene:" .. name .. ":show")
end

function Helper.scene_hide(name)
	Helper.WORLD.analytics:eventCustom("scene:" .. name .. ":hide")
end

function Helper.scene_unload(name)
	Helper.WORLD.analytics:eventCustom("scene:" .. name .. ":unload")
end

function Helper.ads_start(name)
	name = name or "unknown"
	Helper.WORLD.analytics:eventCustom("ads:" .. name .. ":start")
end

function Helper.ads_result(name, success)
	name = name or "unknown"
	Helper.WORLD.analytics:eventCustom("ads:" .. name .. ":" .. (success and "success" or "fail"))
end

function Helper.performance_scene_load_time(name, time)
	Helper.WORLD.analytics:eventCustom("performance:scene:" .. name .. ":load_time", time)
end

function Helper.tutorial_completed(name)
	Helper.WORLD.analytics:eventCustom("tutorial:" .. name .. ":completed")
end

function Helper.world_battle_win(world_id, battle_idx)
	Helper.WORLD.analytics:eventCustom("world:" .. world_id .. ":battle:" .. battle_idx .. ":win")
end

function Helper.world_unlocked(world_id)
	Helper.WORLD.analytics:eventCustom("world:" .. world_id .. ":unlocked")
end

function Helper.daily_task_done(task_id, day)
	Helper.WORLD.analytics:eventCustom("tasks:daily:" .. task_id .. ":done", day)
end

function Helper.daily_tasks_collect(day)
	Helper.WORLD.analytics:eventCustom("tasks:daily:collect:" .. day)
end

function Helper.rebirth(rebirth_idx)
	Helper.WORLD.analytics:eventCustom("game:rebirth:" .. rebirth_idx)
end

function Helper.offline_income_show(duration)
	if Helper.WORLD then
		--Helper.WORLD.analytics:eventCustom("game:line_opened:" .. level)
		Helper.WORLD.analytics:eventCustom("game:offline_income", duration)
	end
end

function Helper.powerup_activate(id, is_ads)
	Helper.WORLD.analytics:eventCustom("game:powerup:" .. id .. ":activate:" .. (is_ads and "ads" or "free"))
end

return Helper