local M = {}
M.hashes = {}

function M.hash(key)
	local hash_value = M.hashes[key]
	if not hash_value then
		hash_value = hash(key)
		M.hashes[key] = hash_value
	end
	return hash_value
end

M.INPUT = {
	ACQUIRE_FOCUS = M.hash("acquire_input_focus"),
	RELEASE_FOCUS = M.hash("release_input_focus"),
	BACK = M.hash("back"),
	TOUCH = M.hash("touch"),
	TOUCH_MULTI = M.hash("touch_multi"),
	RIGHT_CLICK = M.hash("mouse_button_right"),
	SCROLL_UP = M.hash("scroll_up"),
	SCROLL_DOWN = M.hash("scroll_down"),
	LEFT_CTRL = M.hash("key_lctr"),
	LEFT_SHIFT = M.hash("key_lshift"),
	SPACE = M.hash("key_space"),
	ENTER = M.hash("key_enter"),
	ARROW_LEFT = M.hash("key_left"),
	ARROW_RIGHT = M.hash("key_right"),
	ARROW_UP = M.hash("key_up"),
	ARROW_DOWN = M.hash("key_down"),

	NUMBER_0 = M.hash("key_0"),
	NUMBER_1 = M.hash("key_1"),
	NUMBER_2 = M.hash("key_2"),
	NUMBER_3 = M.hash("key_3"),
	NUMBER_4 = M.hash("key_4"),
	NUMBER_5 = M.hash("key_5"),
	NUMBER_6 = M.hash("key_6"),
	NUMBER_7 = M.hash("key_7"),
	NUMBER_8 = M.hash("key_8"),
	NUMBER_9 = M.hash("key_9"),

	BACKSPACE = M.hash("key_backspace"),

	W = M.hash("key_w"),
	E = M.hash("key_e"),
	S = M.hash("key_s"),
	A = M.hash("key_a"),
	D = M.hash("key_d"),
	F = M.hash("key_f"),
	Z = M.hash("key_z"),
	X = M.hash("key_x"),
	M = M.hash("key_m"),
	R = M.hash("key_r"),
	C = M.hash("key_c"),
	L = M.hash("key_l"),
	P = M.hash("key_p"),
	U = M.hash("key_u"),
	B = M.hash("key_b"),
	F5 = M.hash("key_f5"),
	F8 = M.hash("key_f8"),
	ESCAPE = M.hash("key_esc"),
}

M.MSG = {
	PHYSICS = {
		CONTACT_POINT_RESPONSE = M.hash("contact_point_response"),
		COLLISION_RESPONSE = M.hash("collision_response"),
		TRIGGER_RESPONSE = M.hash("trigger_response"),
		RAY_CAST_RESPONSE = M.hash("ray_cast_response"),
		APPLY_FORCE = M.hash("apply_force")
	},
	ENABLE = M.hash("enable"),
	DISABLE = M.hash("disable"),
	SET_PARENT = M.hash("set_parent"),
	SET_TIME_STEP = M. hash("set_time_step"),
	LOADING = {
		PROXY_LOADED = M.hash("proxy_loaded"),
		ASYNC_LOAD = M.hash("async_load"),
		UNLOAD = M.hash("unload"),
	},
}

M.EMPTY = M.hash("empty")
M.SPRITE = M.hash("sprite")
M.SPINE = M.hash("spine")
M.MESH = M.hash("mesh")
M.MODEL = M.hash("model")
M.EULER_X = M.hash("euler.x")
M.EULER_Y = M.hash("euler.y")
M.EULER_Z = M.hash("euler.z")
M.EULER = M.hash("euler")
M.TINT = M.hash("tint")
M.TINT_W = M.hash("tint.w")

M.MASS = M.hash("mass")

return M
