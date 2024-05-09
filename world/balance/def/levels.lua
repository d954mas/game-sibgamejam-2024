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
	CHOOSE_LEVEL = {
		cells = {
			"12345",
			"BBBBB",
			"0BBB0",
			"0BPB0",
			"0BBB0",
		},
	}
}

for k, v in pairs(M.BY_ID) do
	v.id = k
end

M.LEVELS_LIST = {
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
	M.BY_ID.TUTORIAL_1.id,
}

return M