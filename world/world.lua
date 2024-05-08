local COMMON = require "libs.common"
local Storage = require "world.storage.storage"
local GameWorld = require "world.game.game_world"
local Sdk = require "libs.sdk.sdk"
local Sounds = require "libs.sounds"
local Balance = require "world.balance.balance"
local Analytics = require "libs_project.analytics"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"

local TAG = "WORLD"
---@class World
local M = COMMON.class("World")

function M:initialize()
	COMMON.i("init", TAG)
	self.storage = Storage(self)
	self.game = GameWorld(self)
	self.sdk = Sdk(self)
	self.sounds = Sounds(self)
	self.balance = Balance(self)
	self.analytics = Analytics(self, {})
	ANALYTICS_HELPER.WORLD = self
	self.time = 0
	---@type SceneManager
	self.sm = nil

	self.storage:check_daily_tasks()
end

function M:update(dt)
	self.sounds:update(dt)
	self.sm:update(dt)
	self.storage:update(dt)
	self.time = self.time + dt
end

return M()