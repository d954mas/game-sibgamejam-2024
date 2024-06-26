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
	EASY_1 = {
		cells = {
			"E",
			"0",
			"B",
			"B",
			"0",
			"P"
		}
	},
	EASY_2 = {
		cells = {
			"00E",
			"00B",
			"0B0",
			"B0B",
			"PB0",
		}
	},
	EASY_3 = {
		cells = {
			"00E",
			"0B0",
			"B00",
			"0B0",
			"P00"
		}
	},
	EASY_4 = {
		cells = {
			"00E00",
			"000B0",
			"B000B",
			"0BBB0",
			"PB0B0"
		}
	},

	MOVE_BLOCK = {
		cells = {
			"E",
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
			"P000E",
		},
		objects = {
			{
				type = "move_block",
				speed = 4,
				path = {
					{ x = 2, y = 2, pause = 0.66 },
					{ x = 4, y = 2, pause = 0.66  },
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
			"B00000u",
			"B00PuuE",
			"B00000U",
			"000000u",
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
			"u0U0UUU0u",
			"uU0000UUU",
			"uU000uuuu",
			"uu0UP0u0u",
			"uUUU0UuUu",
			"uu0u0u00u",
			"uU0U0U0Uu",
			"u0u0u0u0u",
		},
	},
	ADVANCED_MAZE_3 = {
		cells = {
			"000000000",
			"000000000",
			"0U0000B00",
			"0uBu0u0U0",
			"00B000E00",
			"00U000000",
			"0U0U000u0",
			"Bu0U0u0u0",
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
			"BB0000000",
			"BB0000000",
			"B00000000",
			"B000P0B00",
			"Bu0000000",
			"B00000B00",
			"B0E0000U0",
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