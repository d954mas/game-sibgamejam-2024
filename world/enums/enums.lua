local ENUMS = {}

ENUMS.ANIMATIONS = {
	IDLE = "IDLE",
	RUN = "RUN",
	DIE = "DIE",
}
ENUMS.WORLD_STATE = {
	CLOSED = "CLOSED",
	OPENED = "OPENED",
}

ENUMS.RESOURCE_ADD_PLACEMENT = {
	GAME = "GAME",
	OTHER = "OTHER",
	GAME_OFFER = "GAME_OFFER",
	DEBUG = "DEBUG",
	LEVEL_UP = "LEVEL_UP",
	OFFLINE_PROGRESS = "OFFLINE_PROGRESS",
}

ENUMS.DAILY_TASKS_STATE = {
	IN_PROGRESS = "IN_PROGRESS",
	NEED_COLLECT = "NEED_COLLECT",
	COLLECTED = "COLLECTED",
}
ENUMS.DAILY_TASK_TYPE = {
	TIME_TO_PLAY = "TIME_TO_PLAY",
}
ENUMS.DAILY_TASK_STATE = {
	IN_PROGRESS = "IN_PROGRESS",
	DONE = "DONE",
}

ENUMS.POWERUP_STATE = {
	ACTIVE = "ACTIVE",
	IDLE = "IDLE"
}

ENUMS.PLAYER_MOVEMENT = {
	FIXED_CAMERA = "FIXED_CAMERA",
	BATTLE = "BATTLE"
}

ENUMS.CELL_TYPE = {
	EXIT = "EXIT",
	EMPTY = "EMPTY",
	BLOCK = "BLOCK",
	BLOCK_STATIC = "BLOCK_STATIC",
	BLOCK_FAKE = "BLOCK_FAKE",
	BLOCK_LEVEL = "BLOCK_LEVEL",
}
return ENUMS