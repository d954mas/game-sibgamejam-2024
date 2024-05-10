local M = {}

M.BY_ID = {
	TUTORIAL_1 = {
		cells = {
			"0E",
			"0B",
			"0B",
			"B0",
			"B0",
			"P0",
		},
	},
	TUTORIAL_2 = {
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
}

return M