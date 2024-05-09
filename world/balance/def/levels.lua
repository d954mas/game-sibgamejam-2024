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
	}

}

for k, v in pairs(M.BY_ID) do
	v.id = k

	-- y_down
	local cells = {}
	for i = #v.cells, 1, -1 do
		table.insert(cells, v.cells[i])
	end
	v.cells = cells
end

return M