local M = {}

M.BY_ID = {
	TUTORIAL_1 = {
		cells = {
			"E",
			"B",
			"B",
			"B",
			"P",
		},
	},
	TUTORIAL_2 = {
		cells = {
			"0E",
			"0B",
			"0B",
			"B0",
			"B0",
			"P0",
		},
	},
	TUTORIAL_3 = {
		cells = {
			"E0",
			"00",
			"B0",
			"00",
			"P0",
		},
	},
	SQUAD_GAME = {
		cells = {
			"0E",
			"Uu",
			"uU",
			"uU",
			"Uu",
			"Uu",
			"Uu",
			"uU",
			"P0",
		},
	},
}

for k, v in pairs(M.BY_ID) do
	v.id = k
end

M.LEVELS_LIST = {
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_2.id,
	M.BY_ID.TUTORIAL_3.id,
	M.BY_ID.SQUAD_GAME.id,
}

return M