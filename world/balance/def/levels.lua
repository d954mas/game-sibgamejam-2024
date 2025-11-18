local M = {}

M.BY_ID = {
	TUTORIAL_1 = {
		cells = {
			"E",
			"0",
			"B",
			"0",
			"B",
			"0",
			"B",
			"0",
			"P",
		},
	},
	TUTORIAL_2 = {
		cells = {
			"0E",
			"00",
			"0B",
			"00",
			"0B",
			"00",
			"B0",
			"00",
			"B0",
			"00",
			"P0",
		},
	},
	TUTORIAL_3 = {
		cells = {
			"E0",
			"00",
			"00",
			"00",
			"B0",
			"00",
			"00",
			"00",
			"P0",
		},
	},
	EASY_1 = {
		cells = {
			"E",
			"0",
			"0",
			"0",
			"B",
			"0",
			"B",
			"0",
			"0",
			"0",
			"P"
		}
	},
	EASY_2 = {
		cells = {
			"00E",
			"000",
			"00B",
			"000",
			"0B0",
			"000",
			"B0B",
			"000",
			"PB0",
		}
	},
	EASY_3 = {
		cells = {
			"00E",
			"000",
			"0B0",
			"000",
			"B00",
			"000",
			"0B0",
			"000",
			"P00"
		}
	},
	EASY_4 = {
		cells = {
			"00E00",
			"00000",
			"000B0",
			"00000",
			"B000B",
			"00000",
			"0BBB0",
			"00000",
			"PB0B0"
		}
	},

	MOVE_BLOCK = {
		cells = {
			"E",
			"0",
			"0",
			"0",
			"0",
			"0",
			"0",
			"0",
			"P",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 1, y = 2, pause = 0.66 },
					{ x = 1, y = 4, pause = 0.66 },
				},
			}
		}
	},

	MOVE_BLOCK_2_LINES = {
		cells = {
			"00E00",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00P00",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 1, y = 2, pause = 0 },
					{ x = 5, y = 2, pause = 0 },
				},
			},
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 5, y = 4, pause = 0 },
					{ x = 1, y = 4, pause = 0 },
				},
			}
		}
	},
	MOVE_BLOCK_GPT1 = {
		cells = {
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"00000",
			"P000E",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 2, y = 2, pause = 0.66 },
					{ x = 4, y = 2, pause = 0.66 },
				},
			},
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 5, y = 4, pause = 0.66 },
					{ x = 5, y = 2, pause = 0.66 },
				},
			},
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 1, y = 2, pause = 0.66 },
					{ x = 1, y = 4, pause = 0.66 },
				},
			}
		}
	},
	CENTRAL = {
		cells = {
			"000000u",
			"0000000",
			"B00000u",
			"0000000",
			"B00PuuE",
			"0000000",
			"B00000U",
			"0000000",
			"000000u",
			"0000000",
			"000000B"
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 1, y = 1, pause = 0.66 },
					{ x = 6, y = 1, pause = 0.66 },
				},
			},
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 6, y = 5, pause = 0.66 },
					{ x = 1, y = 5, pause = 0.66 },
				},
			}
		}

	},

	SQUAD_GAME_BIG = {
		cells = {
			"uuUUUuuuE",
			"000000000",
			"u0U0UUU0u",
			"000000000",
			"uU0000UUU",
			"000000000",
			"uU000uuuu",
			"000000000",
			"uu0UP0u0u",
			"000000000",
			"uUUU0UuUu",
			"000000000",
			"uu0u0u00u",
			"000000000",
			"uU0U0U0Uu",
			"000000000",
			"u0u0u0u0u",
		},
	},
	ADVANCED_MAZE_3 = {
		cells = {
			"000000000",
			"000000000",
			"000000000",
			"000000000",
			"0U0000B00",
			"000000000",
			"0uBu0u0U0",
			"000000000",
			"00B000E00",
			"000000000",
			"00U000000",
			"000000000",
			"0U0U000u0",
			"000000000",
			"Bu0U0u0u0",
			"000000000",
			"B00000P00",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 2, y = 9, pause = 0.5 },
					{ x = 6, y = 9, pause = 0.5 },
				},
			},
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 2, y = 2, pause = 0.5 },
					{ x = 9, y = 2, pause = 0.5 },
				},
			}
		}
	},
	FINAL_CHALLENGE_15 = {
		cells = {
			"BB0000000",
			"000000000",
			"BB0000000",
			"000000000",
			"BB0000000",
			"000000000",
			"B00000000",
			"000000000",
			"B000P0B00",
			"000000000",
			"Bu0000000",
			"000000000",
			"B00000B00",
			"000000000",
			"B0E0000U0",
			"000000000",
			"BBB000000",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				loop = true,
				path = {
					{ x = 4, y = 4, pause = 0.25 },
					{ x = 6, y = 4, pause = 0.25 },
					{ x = 6, y = 6, pause = 0.25 },
					{ x = 4, y = 6, pause = 0.25 },
				},
			},

			{
				type = "move_block",
				speed = 4,
				loop = true,
				path = {
					{ x = 5, y = 1, pause = 0.25 },
					{ x = 3, y = 1, pause = 0.25 },
					{ x = 3, y = 3, pause = 0.25 },
					{ x = 5, y = 3, pause = 0.25 },



				},
			},

			{
				type = "move_block",
				speed = 4,
				loop = true,
				path = {
					{ x = 6, y = 1, pause = 0.25 },
					{ x = 6, y = 3, pause = 0.25 },
					{ x = 8, y = 3, pause = 0.25 },
					{ x = 8, y = 1, pause = 0.25 },


				},
			},

		}
	},


	SQUAD_GAME = {
		cells = {
			"0E",
			"00",
			"Uu",
			"00",
			"uU",
			"00",
			"uU",
			"00",
			"Uu",
			"00",
			"Uu",
			"00",
			"Uu",
			"00",
			"uU",
			"00",
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
	M.BY_ID.EASY_1.id,
	M.BY_ID.EASY_2.id,
	M.BY_ID.EASY_3.id,
	M.BY_ID.EASY_4.id,
	M.BY_ID.MOVE_BLOCK.id,
	M.BY_ID.MOVE_BLOCK_2_LINES.id,
	M.BY_ID.SQUAD_GAME.id,
	M.BY_ID.MOVE_BLOCK_GPT1.id,
	M.BY_ID.CENTRAL.id,
	M.BY_ID.SQUAD_GAME_BIG.id,
	M.BY_ID.ADVANCED_MAZE_3.id,
	M.BY_ID.FINAL_CHALLENGE_15.id,
}

return M
