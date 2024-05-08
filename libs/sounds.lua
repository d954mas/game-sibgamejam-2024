local COMMON = require "libs.common"

local HASH_MASTER = hash("master")
local HASH_SOUND = hash("sound")
local HASH_MUSIC = hash("music")

local EMPTY_CONFIG = {}

local TAG = "Sound"
---@class Sounds
local Sounds = COMMON.class("Sounds")

--gate https://www.defold.com/manuals/sound/
---@param world World
function Sounds:initialize(world)
	self.world = assert(world)
	self.gate_time = 0.1
	self.gate_sounds = {}
	self.fade_in = {}
	self.fade_out = {}
	self.sounds = {
		slider = { name = "slider", url = msg.url("main:/sounds#slider"), skip_play = true },
		btn_1 = { name = "btn_1", url = msg.url("main:/sounds#btn_1"), skip_play = true },
	}

	self.music = {
		main = { name = "main", url = msg.url("liveupdate_proxy:/music#main"), fade_in = 3, fade_out = 3 },
	}

	COMMON.EVENTS.STORAGE_CHANGED:subscribe(false, function()
		self:on_storage_changed()
	end)
	COMMON.EVENTS.WINDOW_EVENT:subscribe(false, function(_, window_event)
		if window_event == window.WINDOW_EVENT_FOCUS_LOST then
			self.focus = false
			sound.set_group_gain(HASH_MASTER, 0)
		elseif window_event == window.WINDOW_EVENT_FOCUS_GAINED then
			self.focus = true
			if (not self.paused) then
				sound.set_group_gain(HASH_MASTER, 1)
			end
		end
	end)

	self.paused = false
	self.focus = true
	self.master_gain = 1
	self.current_music = nil
end

function Sounds:liveupdate_ready()
	local sounds = {
		self.sounds.slider,
		self.sounds.btn_1,
	}
	local socket = hash("liveupdate_proxy")
	for _, s in ipairs(sounds) do
		s.url = msg.url(socket, s.url.path, s.url.fragment)
		s.skip_play = nil
	end
	self.liveupdate_loaded = true
end

function Sounds:on_storage_changed()
	sound.set_group_gain(HASH_SOUND, self.world.storage.options:sound_get() and 1 or 0)
	sound.set_group_gain(HASH_MUSIC, self.world.storage.options:music_get() and 1 or 0)
end

function Sounds:pause()
	COMMON.i("pause", TAG)
	self.paused = true
	sound.set_group_gain(HASH_MASTER, 0)
end

function Sounds:resume()
	COMMON.i("resume", TAG)
	self.paused = false
	if (self.focus) then
		sound.set_group_gain(HASH_MASTER, self.master_gain)
	end
end

function Sounds:update(dt)
	for k, v in pairs(self.gate_sounds) do
		self.gate_sounds[k] = v - dt
		if self.gate_sounds[k] < 0 then
			self.gate_sounds[k] = nil
		end
	end
	for k, v in pairs(self.fade_in) do
		local a = 1 - v.time / v.music.fade_in
		a = COMMON.LUME.clamp(a, 0, 1)
		sound.set_gain(v.music.url, a)
		v.time = v.time - dt
		--        print("Fade in:" .. a)
		if (a == 1) then
			self.fade_in[k] = nil
		end
	end

	for k, v in pairs(self.fade_out) do
		local a = v.time / v.music.fade_in
		a = COMMON.LUME.clamp(a, 0, 1)
		sound.set_gain(v.music.url, a)
		v.time = v.time - dt
		--      print("Fade out:" .. a)
		if (a == 0) then
			self.fade_out[k] = nil
			sound.stop(v.url)
		end
	end
end

function Sounds:play_sound(sound_obj, config)
	assert(sound_obj)
	assert(type(sound_obj) == "table")
	assert(sound_obj.url)
	config = config or EMPTY_CONFIG

	if not self.gate_sounds[sound_obj] or sound_obj.no_gate then
		self.gate_sounds[sound_obj] = sound_obj.gate_time or self.gate_time

		if sound_obj.skip_play then
			if config.on_complete then config.on_complete() end
		else
			sound.play(sound_obj.url, config.play_properties, config.on_complete)
		end
		COMMON.i("play sound:" .. sound_obj.name, TAG)
	else
		COMMON.i("gated sound:" .. sound_obj.name .. "time:" .. self.gate_sounds[sound_obj], TAG)
	end
end

function Sounds:play_music(music_obj)
	assert(music_obj)
	assert(type(music_obj) == "table")
	assert(music_obj.url)

	if (self.current_music) then
		if (self.current_music.fade_out) then
			self.fade_out[self.current_music] = { music = self.current_music, time = self.current_music.fade_out }
			self.fade_in[self.current_music] = nil
		else
			sound.stop(self.current_music.url)
		end
	end
	sound.stop(music_obj.url)
	sound.play(music_obj.url)

	if (music_obj.fade_in) then
		sound.set_gain(music_obj.url, 0)
		self.fade_in[music_obj] = { music = music_obj, time = music_obj.fade_in }
		self.fade_out[music_obj] = nil
	end
	self.current_music = music_obj

	COMMON.i("play music:" .. music_obj.name, TAG)
end

function Sounds:play_step_sound()
	self:play_sound(self.sounds.steps[math.random(1, self.liveupdate_loaded and 6 or 2)])
end

function Sounds:play_punch_bag_sound()
	self:play_sound(self.sounds.punch_bag[math.random(1, self.liveupdate_loaded and 3 or 1)])
end

function Sounds:play_punch_battle_sound()
	if self.world.game.state.in_battle then
		self:play_sound(self.sounds.punch_battle[math.random(1, self.liveupdate_loaded and 3 or 1)])
	end
end

--pressed M to enable/disable
function Sounds:toggle()
	local music = self.world.storage.options:music_get()
	if (music) then
		-- music priority
		self.world.storage.options:music_set(false)
		self.world.storage.options:sound_set(false)
	else
		self.world.storage.options:music_set(true)
		self.world.storage.options:sound_set(true)
	end
end

return Sounds