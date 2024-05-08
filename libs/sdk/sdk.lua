local COMMON = require "libs.common"
local INPUT = require "libs.input_receiver"
local CHECKS = require "libs.checks"
local ANALYTICS_HELPER = require "libs_project.analytics_helper"
local AdmobSdk = require "libs.sdk.admob_sdk"
local TAG = "SDK"

---@class Sdks
local Sdk = COMMON.class("Sdk")

---@param world World
function Sdk:initialize(world)
	CHECKS("?", "class:World")
	self.world = world
	self.is_poki = COMMON.CONSTANTS.TARGET_IS_POKI or poki_sdk
	self.is_admob = COMMON.CONSTANTS.TARGET_IS_PLAY_MARKET and admob
	self.data = {
		gameplay_start = false,
		gameplay_start_send = false,
		prev_rewarded = 0
	}
	self.poki  = {
		show_ad = false
	}
	if self.is_admob then
		self.sdk = AdmobSdk(self.world, self)
	end

	if self.is_poki then
		html5.run("navigator.sendBeacon('https://leveldata.poki.io/loaded', '63309b2f-ae49-4653-be9b-bb8c68ef0610')")
	end

end

function Sdk:init(cb)
	if self.sdk then
		self.sdk:init()
		cb()
	else
		cb()
	end
end

function Sdk:gameplay_start()
	if (not self.data.gameplay_start) then
		COMMON.i("gameplay start", TAG)
		self.data.gameplay_start = true
		if not self.data.gameplay_start_send then
			self.data.gameplay_start_send = true
			ANALYTICS_HELPER.gameplay_start()
		end
		if (self.is_poki) then
			poki_sdk.gameplay_start()
		end
	end
end

function Sdk:gameplay_stop()
	if (self.data.gameplay_start) then
		COMMON.i("gameplay stop", TAG)
		self.data.gameplay_start = false
		if (self.is_poki) then
			poki_sdk.gameplay_stop()
		end
	end
end

function Sdk:__ads_start()
	--	self:gameplay_stop()
	self.world.sounds:pause()
	INPUT.IGNORE = true
end

function Sdk:__ads_stop()
	self.world.sounds:resume()
	INPUT.IGNORE = false
	if html_utils then
		html_utils.focus()
	end
end

function Sdk:ads_rewarded(cb, placement)
	print("ads_rewarded")
	placement = placement or "unknown"
	ANALYTICS_HELPER.ads_start(placement)
	if (self.is_poki) then
		if self.poki.show_ad then
			cb(false)
			return
		end
		self.poki.show_ad = true
		self:__ads_start()
		poki_sdk.rewarded_break(function(_, success)
			print("ads_rewarded success:" .. tostring(success))
			ANALYTICS_HELPER.ads_result(placement, success)
			self:__ads_stop()
			if (success) then
				self.data.prev_rewarded = socket.gettime()
			end
			if (cb) then cb(success) end
			self.poki.show_ad = false
		end)
	elseif self.sdk then
		self.sdk:show_rewarded_ad(cb,placement)
	else
		self.data.prev_rewarded = socket.gettime()
		self:__ads_start()
		self:__ads_stop()
		if (cb) then cb(true) end
	end
end

function Sdk:preload_ads()
	if self.sdk and self.sdk.preload_ads then
		self.sdk:rewarded_load()
	end
end

function Sdk:ads_commercial(cb)
	print("ads_commercial")
	--local dt = socket.gettime()-self.data.prev_rewarded
	--if(dt<4*60)then
	--	print("skip commercial user see rewarded")
	--	if(cb)then cb() end
	--	return
	--end

	if (self.is_poki) then
		if self.poki.show_ad then
			cb(false)
			return
		end
		self:__ads_start()
		self.poki.show_ad = true
		poki_sdk.commercial_break(function(_)
			self:__ads_stop()
			if (cb) then cb() end
			self.poki.show_ad = false
		end)
	elseif (self.sdk) then
		self.sdk:show_interstitial_ad(cb)
	else
		self:__ads_start()
		self:__ads_stop()
		if (cb) then cb() end
	end
end

return Sdk
