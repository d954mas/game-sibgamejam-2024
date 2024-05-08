local I18N = require "libs.i18n.init"
local LOG = require "libs.log"
local CONSTANTS = require "libs.constants"
local TAG = "LOCALIZATION"
local EVENTS = require "libs.events"
local DEFAULT = CONSTANTS.LOCALIZATION.DEFAULT
local FALLBACK = DEFAULT

---@class Localization
local M = {

}

function M.load_configs()
	M.config_all = json.decode(sys.load_resource("/assets/custom/configs/localization.json"))
	M.config_tiny = {}
	for k, v in pairs(M.config_all) do
		if k~="ko" and k~="zh" and k~="ja" then
			M.config_tiny[k] = v
		end
	end
	I18N.load(M.config_tiny)
end

M.load_configs()

function M:set_locale(locale)
	LOG.i("set locale:" .. locale , TAG)
	I18N.setLocale(locale)
	EVENTS.LANGUAGE_CHANGED:trigger()
end

function M:locale_get()
	return I18N.getLocale()
end

I18N.setFallbackLocale(FALLBACK)
M:set_locale(DEFAULT)
if (CONSTANTS.LOCALIZATION.FORCE_LOCALE) then
	LOG.i("force locale:" .. CONSTANTS.LOCALIZATION.FORCE_LOCALE, TAG)
	M:set_locale(CONSTANTS.LOCALIZATION.FORCE_LOCALE)
elseif (CONSTANTS.LOCALIZATION.USE_SYSTEM) then
	local system_locale = sys.get_sys_info().language
	LOG.i("system locale:" .. system_locale, TAG)
	M:set_locale(system_locale)
	--	pprint(LOCALES)
end

function M:translate(key, data)
	local translation =  I18N.translate(key, data)
	if not translation then return key end
	return translation
end

function M:on_font_loaded(font_all)
	print("on font loaded")
	self.font_all = assert(font_all)
	I18N.load(self.config_all)
	EVENTS.LANGUAGE_CHANGED:trigger()
	--add trigger to fix some font not changed it metrics
	timer.delay(0.1,false,function()
		EVENTS.LANGUAGE_CHANGED:trigger()
	end)
end



return M
