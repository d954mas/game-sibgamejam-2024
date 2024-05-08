local lume = require "libs.lume"

local M = {}

M.SYSTEM_INFO = sys.get_sys_info({ignore_secure = true})
M.PLATFORM = M.SYSTEM_INFO.system_name
M.PLATFORM_IS_WEB = M.PLATFORM == "HTML5"
M.PLATFORM_IS_WINDOWS = M.PLATFORM == "Windows"
M.PLATFORM_IS_LINUX = M.PLATFORM == "Linux"
M.PLATFORM_IS_MACOS = M.PLATFORM == "Darwin"
M.PLATFORM_IS_ANDROID = M.PLATFORM == "Android"
M.PLATFORM_IS_IPHONE = M.PLATFORM == "iPhone OS"

M.PLATFORM_IS_PC = M.PLATFORM_IS_WINDOWS or M.PLATFORM_IS_LINUX or M.PLATFORM_IS_MACOS
M.PLATFORM_IS_MOBILE = M.PLATFORM_IS_ANDROID or M.PLATFORM_IS_IPHONE

M.PROJECT_VERSION = sys.get_config("project.version")

M.GAME_VERSION = sys.get_config("game.version")

M.VERSION_IS_DEV = M.GAME_VERSION == "dev"
M.VERSION_IS_RELEASE = M.GAME_VERSION == "release"

M.GAME_TARGET = sys.get_config("game.target")

M.TARGETS = {
	EDITOR = "editor",
	OTHER = "other",
	PLAY_MARKET = "play_market",
	POKI = "poki",
}

assert(lume.find(M.TARGETS, M.GAME_TARGET), "unknown target:" .. M.GAME_TARGET)

M.TARGET_IS_EDITOR = M.GAME_TARGET == M.TARGETS.EDITOR
M.TARGET_IS_PLAY_MARKET = M.GAME_TARGET == M.TARGETS.PLAY_MARKET
M.TARGET_IS_POKI = M.GAME_TARGET == M.TARGETS.POKI
M.TARGET_OTHER = M.GAME_TARGET == M.TARGETS.OTHER

M.CRYPTO_KEY = "6soZqsCXY4"

M.GUI_ORDER = {
	GAME = 2,
	MODAL = 4,
	TOP_PANEL = 5,
	SETTINGS = 6,
	DEBUG = 15,
}

M.COLORS = {
	EMPTY = vmath.vector4(1,1,1,0),
	WHITE = vmath.vector4(1,1,1,1),
	NOT_ENOUGH = lume.color_parse_hexRGBA("#ff0000"),
	ENOUGH = lume.color_parse_hexRGBA("#ffffff")
}

M.LOCALIZATION = {
	DEFAULT = sys.get_config("localization.default") or "en",
	USE_SYSTEM = (sys.get_config("localization.use_system") or "false") == "true",
	FORCE_LOCALE = sys.get_config("localization.force_locale")
}

M.ADMOB = {
	TEST = {
		interstitial = "ca-app-pub-3940256099942544/1033173712",
		rewarded = "ca-app-pub-3940256099942544/5224354917"
	},
	BASE = {
		interstitial = "ca-app-pub-3940256099942544/1033173712",
		rewarded = "ca-app-pub-3940256099942544/5224354917"
	}
}


return M
